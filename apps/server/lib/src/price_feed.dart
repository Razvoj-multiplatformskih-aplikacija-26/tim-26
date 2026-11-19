/// Spoljni izvor cena (API trgovinskih lanaca). Poziva ga samo server, iza ovog porta.
abstract interface class PriceFeed {
  Future<List<FeedPrice>> latest();
}

final class FeedPrice {
  const FeedPrice({
    required this.productId,
    required this.storeId,
    required this.priceRsd,
    required this.seenAt,
  });

  final String productId;
  final String storeId;
  final int priceRsd;
  final DateTime seenAt;
}

final class PriceFeedException implements Exception {
  const PriceFeedException(this.message);

  final String message;

  @override
  String toString() => 'PriceFeedException: $message';
}

/// Lazna implementacija za KT2: vraca nekoliko cena kao da su stigle iz izvora.
/// Kljuc dobija iz .env kao i prava implementacija, ali ga ne salje nikome.
final class FakePriceFeed implements PriceFeed {
  FakePriceFeed({required this.apiKey});

  final String apiKey;
  int _round = 0;

  static const _samples = [
    ('mleko', 'lidl1', 125),
    ('hleb', 'maxi1', 79),
    ('jaja', 'roda1', 205),
    ('kafa', 'idea1', 365),
  ];

  @override
  Future<List<FeedPrice>> latest() async {
    if (apiKey.isEmpty) {
      throw const PriceFeedException('PRICE_FEED_API_KEY is not set');
    }
    await Future<void>.delayed(const Duration(milliseconds: 300));
    _round++;
    final now = DateTime.now().toUtc();
    return [
      for (final (product, store, price) in _samples)
        FeedPrice(
          productId: product,
          storeId: store,
          priceRsd: price + _round % 4,
          seenAt: now,
        ),
    ];
  }
}
