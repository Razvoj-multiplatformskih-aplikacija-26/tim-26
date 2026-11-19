Map<String, Object?> jsonObject(Object? value) => switch (value) {
  final Map<String, Object?> object => object,
  _ => throw FormatException('Expected a JSON object', value),
};

List<Map<String, Object?>> jsonObjects(Map<String, Object?> json, String key) =>
    switch (json[key]) {
      final List<Object?> list => [for (final item in list) jsonObject(item)],
      _ => throw FormatException('Expected "$key" to be a list', json),
    };

List<String> jsonStrings(Map<String, Object?> json, String key) =>
    switch (json[key]) {
      final List<Object?> list => [
        for (final item in list)
          if (item is String)
            item
          else
            throw FormatException('Expected "$key" to hold strings', json),
      ],
      _ => throw FormatException('Expected "$key" to be a list', json),
    };

String jsonString(Map<String, Object?> json, String key) => switch (json[key]) {
  final String value => value,
  _ => throw FormatException('Expected "$key" to be a string', json),
};

String? jsonOptionalString(Map<String, Object?> json, String key) =>
    switch (json[key]) {
      null => null,
      final String value => value,
      _ => throw FormatException('Expected "$key" to be a string', json),
    };

int jsonInt(Map<String, Object?> json, String key) => switch (json[key]) {
  final int value => value,
  _ => throw FormatException('Expected "$key" to be an integer', json),
};

int? jsonOptionalInt(Map<String, Object?> json, String key) =>
    switch (json[key]) {
      null => null,
      final int value => value,
      _ => throw FormatException('Expected "$key" to be an integer', json),
    };

double jsonDouble(Map<String, Object?> json, String key) => switch (json[key]) {
  final num value => value.toDouble(),
  _ => throw FormatException('Expected "$key" to be a number', json),
};

bool jsonBool(Map<String, Object?> json, String key) => switch (json[key]) {
  final bool value => value,
  _ => throw FormatException('Expected "$key" to be a boolean', json),
};

/// Vreme na mrezi je uvek ISO 8601 u UTC-u, na primer 2026-11-19T17:00:00Z.
DateTime jsonInstant(Map<String, Object?> json, String key) {
  final value = jsonString(json, key);
  final parsed = DateTime.parse(value);
  if (!parsed.isUtc) {
    throw FormatException('Expected "$key" with a time zone', value);
  }
  return parsed;
}

String instantToJson(DateTime instant) => instant.toUtc().toIso8601String();
