import 'package:domain/domain.dart';
import 'package:equatable/equatable.dart';

import '../notice.dart';

sealed class PriceReviewState extends Equatable {
  const PriceReviewState();

  @override
  List<Object?> get props => [];
}

final class PricesLoading extends PriceReviewState {
  const PricesLoading();
}

final class PricesFailure extends PriceReviewState {
  const PricesFailure([this.notice = Notice.serverError]);

  final Notice notice;

  @override
  List<Object?> get props => [notice];
}

final class PricesEmpty extends PriceReviewState {
  const PricesEmpty(this.catalog, {this.error, this.notice, this.imported});

  final Catalog catalog;
  final DomainError? error;
  final Notice? notice;
  final int? imported;

  @override
  List<Object?> get props => [catalog, error, notice, imported];
}

final class PricesLoaded extends PriceReviewState {
  const PricesLoaded({
    required this.catalog,
    this.error,
    this.notice,
    this.imported,
  });

  final Catalog catalog;
  final DomainError? error;
  final Notice? notice;

  /// Koliko je cena stiglo iz spoljnog izvora, uz Notice.pricesImported.
  final int? imported;

  @override
  List<Object?> get props => [catalog, error, notice, imported];
}
