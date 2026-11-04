import 'package:domain/domain.dart';

sealed class PriceReviewEvent {
  const PriceReviewEvent();
}

final class PricesRequested extends PriceReviewEvent {
  const PricesRequested();
}

final class PriceStatusChanged extends PriceReviewEvent {
  const PriceStatusChanged(this.priceId, this.status);

  final PriceEntryId priceId;
  final PriceStatus status;
}

final class PriceEntered extends PriceReviewEvent {
  const PriceEntered({
    required this.product,
    required this.store,
    required this.price,
  });

  final Product product;
  final Store store;
  final int price;
}
