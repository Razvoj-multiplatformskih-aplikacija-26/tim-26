import 'errors.dart';
import 'result.dart';

const int minQuantity = 1;
const int maxQuantity = 99;

final class Quantity {
  const Quantity._(this.value);

  final int value;

  static Result<Quantity> parse(String input) {
    final number = int.tryParse(input.trim());
    if (number == null) {
      return Failure(QuantityNotANumber(input));
    }
    return of(number);
  }

  static Result<Quantity> of(int number) {
    if (number < minQuantity || number > maxQuantity) {
      return Failure(QuantityOutOfRange(number));
    }
    return Success(Quantity._(number));
  }
}
