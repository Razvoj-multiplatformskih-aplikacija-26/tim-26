import 'package:api_client/api_client.dart';
import 'package:use_cases/use_cases.dart';

import 'data/fake_sessions.dart';
import 'data/fake_shopping_list_repository.dart';

/// Odakle stizu podaci. Ekrani i Bloc-ovi vide samo portove iz use_cases.
final class AppDependencies {
  const AppDependencies({
    required this.lists,
    required this.sessions,
    required this.addresses,
    this.fake,
  });

  factory AppDependencies.server({
    required Uri baseUri,
    required TokenStore tokens,
  }) {
    final api = ApiClient(baseUri: baseUri, tokens: tokens);
    return AppDependencies(
      lists: HttpShoppingListRepository(api),
      sessions: HttpSessionRepository(api),
      addresses: HttpAddressSearch(api),
    );
  }

  factory AppDependencies.fake() {
    final fake = FakeShoppingListRepository();
    return AppDependencies(
      lists: fake,
      sessions: FakeSessionRepository(demoUser),
      addresses: const FakeAddressSearch(),
      fake: fake,
    );
  }

  final ShoppingListRepository lists;
  final SessionRepository sessions;
  final AddressSearch addresses;

  /// Postoji samo u laznom rezimu, za demo opcije (greska, prazan prikaz).
  final FakeShoppingListRepository? fake;
}
