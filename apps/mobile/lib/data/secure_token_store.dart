import 'package:api_client/api_client.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

/// Prijava (token) se cuva u bezbednom skladistu platforme: Keystore na
/// Androidu, Keychain na Apple platformama, Credential Manager na Windows-u,
/// libsecret na Linuxu. Lozinka se na uredjaju ne cuva.
final class SecureTokenStore implements TokenStore {
  const SecureTokenStore([
    this._storage = const FlutterSecureStorage(
      mOptions: MacOsOptions(usesDataProtectionKeychain: false),
    ),
  ]);

  static const _key = 'cartmap_session';

  final FlutterSecureStorage _storage;

  @override
  Future<String?> read() => _storage.read(key: _key);

  @override
  Future<void> write(String token) => _storage.write(key: _key, value: token);

  @override
  Future<void> clear() => _storage.delete(key: _key);
}
