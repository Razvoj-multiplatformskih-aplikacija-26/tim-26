import 'package:domain/domain.dart';
import 'package:use_cases/use_cases.dart';

final demoAdmin = User(
  id: UserId('u-admin'),
  name: 'Demo administrator',
  role: Role.admin,
);

final class FakeSessionRepository implements SessionRepository {
  FakeSessionRepository(this.user);

  final User user;
  bool _signedIn = true;

  @override
  Future<User?> logIn({required String username, required String password}) async {
    _signedIn = true;
    return user;
  }

  @override
  Future<User?> current() async => _signedIn ? user : null;

  @override
  Future<void> logOut() async {
    _signedIn = false;
  }

  @override
  Stream<void> get expirations => const Stream.empty();
}
