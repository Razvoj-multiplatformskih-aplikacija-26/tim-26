import 'json.dart';

/// Greska sa servera (RFC 9457). Nosi kod i podatke pravila, ne poruku za korisnika.
final class ProblemDto {
  const ProblemDto({
    required this.status,
    required this.code,
    required this.title,
    this.value,
    this.min,
    this.max,
    this.input,
    this.from,
    this.to,
  });

  static const mediaType = 'application/problem+json';

  static String typeOf(String code) => 'tag:raf.rs,2026:cartmap/problem/$code';

  final int status;
  final String code;
  final String title;
  final int? value;
  final int? min;
  final int? max;
  final String? input;
  final String? from;
  final String? to;

  Map<String, Object?> toJson() => {
    'type': typeOf(code),
    'title': title,
    'status': status,
    'code': code,
    'value': ?value,
    'min': ?min,
    'max': ?max,
    'input': ?input,
    'from': ?from,
    'to': ?to,
  };

  factory ProblemDto.fromJson(Map<String, Object?> json) => ProblemDto(
    status: jsonInt(json, 'status'),
    code: jsonString(json, 'code'),
    title: jsonOptionalString(json, 'title') ?? '',
    value: jsonOptionalInt(json, 'value'),
    min: jsonOptionalInt(json, 'min'),
    max: jsonOptionalInt(json, 'max'),
    input: jsonOptionalString(json, 'input'),
    from: jsonOptionalString(json, 'from'),
    to: jsonOptionalString(json, 'to'),
  );
}
