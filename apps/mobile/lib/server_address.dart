import 'package:flutter/foundation.dart';

/// Android emulator vidi racunar na 10.0.2.2, ostale platforme na localhost-u.
/// Telefon na mrezi: flutter run --dart-define=SERVER_URL=http://<IP racunara>:8080
Uri serverAddress() {
  const configured = String.fromEnvironment('SERVER_URL');
  if (configured.isNotEmpty) return Uri.parse(configured);
  final host = !kIsWeb && defaultTargetPlatform == TargetPlatform.android
      ? '10.0.2.2'
      : 'localhost';
  return Uri.parse('http://$host:8080');
}
