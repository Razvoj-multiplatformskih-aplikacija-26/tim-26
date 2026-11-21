import 'package:domain/domain.dart';
import 'package:use_cases/use_cases.dart';

import 'demo_data.dart';

final demoUser = User(id: currentUserId, name: 'Demo kupac', role: Role.shopper);

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

final class FakeAddressSearch implements AddressSearch {
  const FakeAddressSearch();

  static const _known = [
    FoundAddress(label: 'Knez Mihailova 5, Beograd', point: GeoPoint(44.8170, 20.4575)),
    FoundAddress(label: 'Bulevar kralja Aleksandra 73, Beograd', point: GeoPoint(44.8055, 20.4760)),
  ];

  @override
  Future<List<FoundAddress>> search(String text) async => [
    for (final address in _known)
      if (address.label.toLowerCase().contains(text.toLowerCase())) address,
  ];
}
