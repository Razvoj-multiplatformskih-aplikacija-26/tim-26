import 'package:api_contract/api_contract.dart';
import 'package:domain/domain.dart';

import 'catalog_mapping.dart';
import 'list_mapping.dart';

/// Domenska greska -> greska na mrezi. Nosi kod i podatke pravila (granice),
/// a poruku za korisnika pravi klijent iz domenske greske.
extension DomainErrorMapping on DomainError {
  ProblemDto toProblem() => switch (this) {
    ListNameEmpty() => const ProblemDto(
      status: 422,
      code: ErrorCodes.listNameEmpty,
      title: 'List name is empty',
    ),
    ListNameTooLong(:final length, :final max) => ProblemDto(
      status: 422,
      code: ErrorCodes.listNameTooLong,
      title: 'List name too long',
      value: length,
      max: max,
    ),
    QuantityNotANumber(:final input) => ProblemDto(
      status: 422,
      code: ErrorCodes.quantityNotANumber,
      title: 'Quantity is not a number',
      input: input,
    ),
    QuantityOutOfRange(:final value, :final min, :final max) => ProblemDto(
      status: 422,
      code: ErrorCodes.quantityOutOfRange,
      title: 'Quantity out of range',
      value: value,
      min: min,
      max: max,
    ),
    ItemTotalTooLarge(:final total, :final max) => ProblemDto(
      status: 409,
      code: ErrorCodes.itemTotalTooLarge,
      title: 'Item total too large',
      value: total,
      max: max,
    ),
    NotAMember() => const ProblemDto(
      status: 403,
      code: ErrorCodes.notAMember,
      title: 'Not a member of the list',
    ),
    ListIsCompleted() => const ProblemDto(
      status: 409,
      code: ErrorCodes.listCompleted,
      title: 'List is completed',
    ),
    InvalidTransition(:final from, :final to) => ProblemDto(
      status: 409,
      code: ErrorCodes.invalidTransition,
      title: 'Invalid list transition',
      from: from.name,
      to: to.name,
    ),
    ListHasNoItems() => const ProblemDto(
      status: 422,
      code: ErrorCodes.listHasNoItems,
      title: 'List has no items',
    ),
    ListNotInShopping() => const ProblemDto(
      status: 409,
      code: ErrorCodes.listNotInShopping,
      title: 'Shopping has not started',
    ),
    ItemNotFound() => const ProblemDto(
      status: 404,
      code: ErrorCodes.itemNotFound,
      title: 'Item not on the list',
    ),
    PriceNotANumber(:final input) => ProblemDto(
      status: 422,
      code: ErrorCodes.priceNotANumber,
      title: 'Price is not a number',
      input: input,
    ),
    PriceOutOfRange(:final value, :final min, :final max) => ProblemDto(
      status: 422,
      code: ErrorCodes.priceOutOfRange,
      title: 'Price out of range',
      value: value,
      min: min,
      max: max,
    ),
    InvalidPriceTransition(:final from, :final to) => ProblemDto(
      status: 409,
      code: ErrorCodes.invalidPriceTransition,
      title: 'Invalid price transition',
      from: from.name,
      to: to.name,
    ),
    NotAllowed() => const ProblemDto(
      status: 403,
      code: ErrorCodes.notAllowed,
      title: 'Not allowed',
    ),
    NotFound() => const ProblemDto(
      status: 404,
      code: ErrorCodes.notFound,
      title: 'Not found',
    ),
  };
}

/// Greska na mrezi -> domenska greska. Nepoznat kod (novije pravilo na serveru)
/// daje null, pa klijent prikazuje opstu poruku umesto da padne.
extension ProblemMapping on ProblemDto {
  DomainError? toDomainError() => switch (this) {
    ProblemDto(code: ErrorCodes.listNameEmpty) => const ListNameEmpty(),
    ProblemDto(code: ErrorCodes.listNameTooLong, :final value?, :final max?) =>
      ListNameTooLong(value, max),
    ProblemDto(code: ErrorCodes.quantityNotANumber, :final input) =>
      QuantityNotANumber(input ?? ''),
    ProblemDto(
      code: ErrorCodes.quantityOutOfRange,
      :final value?,
      :final min?,
      :final max?,
    ) =>
      QuantityOutOfRange(value, min: min, max: max),
    ProblemDto(code: ErrorCodes.itemTotalTooLarge, :final value?, :final max?) =>
      ItemTotalTooLarge(value, max: max),
    ProblemDto(code: ErrorCodes.notAMember) => const NotAMember(),
    ProblemDto(code: ErrorCodes.listCompleted) => const ListIsCompleted(),
    ProblemDto(code: ErrorCodes.invalidTransition, :final from, :final to)
        when listStatusOrNull(from) != null && listStatusOrNull(to) != null =>
      InvalidTransition(listStatusOrNull(from)!, listStatusOrNull(to)!),
    ProblemDto(code: ErrorCodes.listHasNoItems) => const ListHasNoItems(),
    ProblemDto(code: ErrorCodes.listNotInShopping) => const ListNotInShopping(),
    ProblemDto(code: ErrorCodes.itemNotFound) => const ItemNotFound(),
    ProblemDto(code: ErrorCodes.priceNotANumber, :final input) =>
      PriceNotANumber(input ?? ''),
    ProblemDto(
      code: ErrorCodes.priceOutOfRange,
      :final value?,
      :final min?,
      :final max?,
    ) =>
      PriceOutOfRange(value, min: min, max: max),
    ProblemDto(code: ErrorCodes.invalidPriceTransition, :final from, :final to)
        when priceStatusOrNull(from) != null && priceStatusOrNull(to) != null =>
      InvalidPriceTransition(priceStatusOrNull(from)!, priceStatusOrNull(to)!),
    ProblemDto(code: ErrorCodes.notAllowed) => const NotAllowed(),
    ProblemDto(code: ErrorCodes.notFound) => const NotFound(),
    _ => null,
  };
}
