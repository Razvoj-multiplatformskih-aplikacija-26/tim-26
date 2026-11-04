import 'package:domain/domain.dart';
import 'package:equatable/equatable.dart';

sealed class PriceReviewState extends Equatable {
  const PriceReviewState();

  @override
  List<Object?> get props => [];
}

final class PricesLoading extends PriceReviewState {
  const PricesLoading();
}

final class PricesFailure extends PriceReviewState {
  const PricesFailure();
}

final class PricesEmpty extends PriceReviewState {
  const PricesEmpty(this.catalog);

  final Catalog catalog;

  @override
  List<Object?> get props => [catalog];
}

final class PricesLoaded extends PriceReviewState {
  const PricesLoaded({required this.catalog, this.error});

  final Catalog catalog;
  final DomainError? error;

  @override
  List<Object?> get props => [catalog, error];
}
