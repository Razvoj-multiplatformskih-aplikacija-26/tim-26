import 'package:api_client/api_client.dart';
import 'package:use_cases/use_cases.dart';

import 'data/fake_price_repository.dart';
import 'data/fake_sessions.dart';

final class BackofficeDependencies {
  const BackofficeDependencies({
    required this.prices,
    required this.sessions,
    this.fake,
  });

  factory BackofficeDependencies.server({
    required Uri baseUri,
    required TokenStore tokens,
  }) {
    final api = ApiClient(baseUri: baseUri, tokens: tokens);
    return BackofficeDependencies(
      prices: HttpPriceRepository(api),
      sessions: HttpSessionRepository(api),
    );
  }

  factory BackofficeDependencies.fake() {
    final fake = FakePriceRepository();
    return BackofficeDependencies(
      prices: fake,
      sessions: FakeSessionRepository(demoAdmin),
      fake: fake,
    );
  }

  final PriceRepository prices;
  final SessionRepository sessions;
  final FakePriceRepository? fake;
}
