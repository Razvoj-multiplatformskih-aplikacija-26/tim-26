import 'dart:async';
import 'dart:convert';

import 'package:api_contract/api_contract.dart';
import 'package:api_mapping/api_mapping.dart';
import 'package:domain/domain.dart';
import 'package:http/http.dart' as http;
import 'package:use_cases/use_cases.dart';

import 'platform_client.dart';
import 'token_store.dart';

/// Odgovor servera, pre nego sto ga repozitorijum pretvori u domen.
sealed class ApiAnswer {
  const ApiAnswer();
}

final class ApiAccepted extends ApiAnswer {
  const ApiAccepted(this.json);

  final Object? json;
}

/// Server je odbio poziv po pravilu koje klijent poznaje.
final class ApiRejected extends ApiAnswer {
  const ApiRejected(this.error);

  final DomainError error;
}

/// Server je odbio poziv kodom koji ova verzija klijenta ne poznaje.
final class ApiRefused extends ApiAnswer {
  const ApiRefused(this.problem);

  final ProblemDto problem;
}

final class ApiClient {
  ApiClient({
    required this.baseUri,
    TokenStore? tokens,
    http.Client? httpClient,
    this.keepsSessionInCookie = platformKeepsSessionInCookie,
    this.timeout = const Duration(seconds: 10),
  }) : tokens = tokens ?? MemoryTokenStore(),
       _http = httpClient ?? platformHttpClient();

  final Uri baseUri;
  final TokenStore tokens;

  /// U pregledacu prijava je u HttpOnly kolacicu, pa je JavaScript ne vidi.
  final bool keepsSessionInCookie;
  final Duration timeout;
  final http.Client _http;
  final _expirations = StreamController<void>.broadcast();

  Stream<void> get expirations => _expirations.stream;

  Future<ApiAnswer> get(String path, {Map<String, String>? query}) =>
      _send('GET', path, query: query);

  Future<ApiAnswer> post(String path, {Map<String, Object?>? body}) =>
      _send('POST', path, body: body);

  Future<ApiAnswer> delete(String path) => _send('DELETE', path);

  Future<ApiAnswer> _send(
    String method,
    String path, {
    Map<String, String>? query,
    Map<String, Object?>? body,
  }) async {
    final request = http.Request(
      method,
      baseUri.replace(path: path, queryParameters: query),
    )..headers['Accept'] = 'application/json';
    if (!keepsSessionInCookie) {
      if (await tokens.read() case final token?) {
        request.headers['Authorization'] = 'Bearer $token';
      }
    }
    if (body != null) {
      request
        ..headers['Content-Type'] = 'application/json'
        ..body = jsonEncode(body);
    }
    final http.Response response;
    try {
      response = await _http
          .send(request)
          .then(http.Response.fromStream)
          .timeout(timeout);
    } on http.ClientException catch (cause) {
      throw RepositoryException(
        'Server unreachable',
        failure: RepositoryFailure.unreachable,
        cause: cause,
      );
    } on TimeoutException catch (cause) {
      throw RepositoryException(
        'Server did not answer',
        failure: RepositoryFailure.unreachable,
        cause: cause,
      );
    }
    return _answerOf(response);
  }

  ApiAnswer _answerOf(http.Response response) {
    final status = response.statusCode;
    final json = readJson(
      () => response.body.isEmpty
          ? null
          : jsonDecode(utf8.decode(response.bodyBytes)),
    );
    if (status >= 200 && status < 300) return ApiAccepted(json);
    if (status >= 400 && status < 500 && json is Map<String, Object?>) {
      final problem = readJson(() => ProblemDto.fromJson(json));
      if (problem.code case ErrorCodes.sessionExpired || ErrorCodes.signInRequired) {
        _expirations.add(null);
        throw const RepositoryException(
          'Session expired',
          failure: RepositoryFailure.sessionExpired,
        );
      }
      return switch (problem.toDomainError()) {
        final error? => ApiRejected(error),
        null => ApiRefused(problem),
      };
    }
    throw RepositoryException(
      'Server answered $status',
      failure: RepositoryFailure.serverError,
    );
  }
}

T readJson<T>(T Function() read) {
  try {
    return read();
  } on FormatException catch (cause) {
    throw RepositoryException('Unreadable answer', cause: cause);
  } on ArgumentError catch (cause) {
    throw RepositoryException('Unreadable answer', cause: cause);
  }
}

/// Za pozive koji ne mogu biti odbijeni po pravilu (citanje).
T accepted<T>(ApiAnswer answer, T Function(Object? json) read) => switch (answer) {
  ApiAccepted(:final json) => readJson(() => read(json)),
  ApiRejected(:final error) => throw RepositoryException(
    'Unexpected rejection $error',
    failure: RepositoryFailure.refused,
  ),
  ApiRefused(:final problem) => throw RepositoryException(
    'Refused: ${problem.code}',
    failure: RepositoryFailure.refused,
  ),
};

/// Za akcije: odbijanje po poznatom pravilu postaje Failure sa domenskom greskom.
Result<T> resultOf<T>(ApiAnswer answer, T Function(Object? json) read) =>
    switch (answer) {
      ApiAccepted(:final json) => Success(readJson(() => read(json))),
      ApiRejected(:final error) => Failure(error),
      ApiRefused(:final problem) => throw RepositoryException(
        'Refused: ${problem.code}',
        failure: RepositoryFailure.refused,
      ),
    };

Map<String, Object?> object(Object? json) => jsonObject(json);

List<Map<String, Object?>> objects(Object? json) => switch (json) {
  final List<Object?> list => [for (final item in list) jsonObject(item)],
  _ => throw FormatException('Expected a JSON list', json),
};

/// Katalog i sve cene koje uloga sme da vidi, deo po deo (offset/limit).
Future<Catalog> loadCatalog(ApiClient api) async {
  final catalog = accepted(
    await api.get(ApiPaths.catalog),
    (json) => CatalogDto.fromJson(object(json)),
  );
  final prices = <PriceDto>[];
  var offset = 0;
  while (true) {
    final page = accepted(
      await api.get(
        ApiPaths.prices,
        query: {
          ApiQuery.offset: '$offset',
          ApiQuery.limit: '${ApiPaging.maxLimit}',
        },
      ),
      (json) => PricePageDto.fromJson(object(json)),
    );
    prices.addAll(page.items);
    offset += page.limit;
    if (page.items.isEmpty || offset >= page.total) break;
  }
  return readJson(() => catalogFromDto(catalog, prices));
}
