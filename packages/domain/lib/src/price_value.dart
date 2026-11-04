import 'errors.dart';
import 'result.dart';

const int minPrice = 1;
const int maxPrice = 100000;

final class PriceValue {
  const PriceValue._(this.value);

  final int value;

  static Result<PriceValue> parse(String input) {
    final number = int.tryParse(input.trim());
    if (number == null) {
      return Failure(PriceNotANumber(input));
    }
    return of(number);
  }

  static Result<PriceValue> of(int number) {
    if (number < minPrice || number > maxPrice) {
      return Failure(PriceOutOfRange(number));
    }
    return Success(PriceValue._(number));
  }
}
