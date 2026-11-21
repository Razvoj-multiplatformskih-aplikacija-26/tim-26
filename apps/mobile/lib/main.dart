import 'package:flutter/material.dart';

import 'app.dart';
import 'data/secure_token_store.dart';
import 'dependencies.dart';
import 'map_filter.dart';
import 'server_address.dart';

/// Lazni podaci umesto servera: flutter run --dart-define=CARTMAP_FAKE=true
const _useFake = bool.fromEnvironment('CARTMAP_FAKE');

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await restoreMapFilter();
  runApp(
    CartMapApp(
      dependencies: _useFake
          ? AppDependencies.fake()
          : AppDependencies.server(
              baseUri: serverAddress(),
              tokens: const SecureTokenStore(),
            ),
    ),
  );
}
