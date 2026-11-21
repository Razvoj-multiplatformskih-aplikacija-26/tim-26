import 'dart:convert';
import 'dart:io';

Future<void> main(List<String> args) async {
  final base = Uri.parse(args.isNotEmpty ? args.first : 'http://localhost:8080');
  final password = Platform.environment['DEMO_PASSWORD'] ?? 'cartmap-demo';
  final client = HttpClient();

  Future<(int, Object?)> send(
    String method,
    String path, {
    String? token,
    Object? body,
  }) async {
    final request = await client.openUrl(method, base.replace(path: path));
    request.headers.contentType = ContentType.json;
    if (token != null) request.headers.set('Authorization', 'Bearer $token');
    if (body != null) request.write(jsonEncode(body));
    final response = await request.close();
    final text = await response.transform(utf8.decoder).join();
    return (response.statusCode, text.isEmpty ? null : jsonDecode(text));
  }

  Future<String> logIn(String username) async {
    final (status, json) = await send(
      'POST',
      '/api/v1/sessions',
      body: {'username': username, 'password': password},
    );
    if (status != 201 || json is! Map<String, Object?>) {
      throw StateError('Prijava $username nije uspela: $status $json');
    }
    return json['token']! as String;
  }

  final first = await logIn('kupac1');
  final second = await logIn('kupac2');
  final add = {'productId': 'mleko', 'quantity': 60};

  stdout.writeln('kupac1 i kupac2 istovremeno dodaju 60 x mleko na listu l1...');
  final results = await Future.wait([
    send('POST', '/api/v1/lists/l1/items', token: first, body: add),
    send('POST', '/api/v1/lists/l1/items', token: second, body: add),
  ]);
  for (final (index, (status, json)) in results.indexed) {
    final who = index == 0 ? 'kupac1' : 'kupac2';
    final summary = switch (json) {
      {'code': final code, 'value': final value, 'max': final max} =>
        'odbijen: $code (bilo bi $value, granica $max)',
      {'items': final List<Object?> items} => 'prihvaćen, mleko: ${[
          for (final item in items)
            if (item case {'product': {'id': 'mleko'}, 'quantity': final quantity})
              quantity,
        ].join()}',
      _ => '$json',
    };
    stdout.writeln('$who -> $status $summary');
  }
  client.close();
}
