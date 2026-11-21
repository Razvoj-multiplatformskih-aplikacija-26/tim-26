import 'package:api_client/api_client.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

import 'app.dart';
import 'data/secure_token_store.dart';
import 'dependencies.dart';

const _useFake = bool.fromEnvironment('CARTMAP_FAKE');

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  runApp(
    BackofficeApp(
      dependencies: _useFake
          ? BackofficeDependencies.fake()
          : BackofficeDependencies.server(
              baseUri: Uri.parse(
                const String.fromEnvironment(
                  'SERVER_URL',
                  defaultValue: 'http://localhost:8080',
                ),
              ),
              tokens: kIsWeb ? MemoryTokenStore() : const SecureTokenStore(),
            ),
    ),
  );
}
