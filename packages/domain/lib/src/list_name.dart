import 'errors.dart';
import 'result.dart';

const int maxListNameLength = 40;

final class ListName {
  const ListName._(this.value);

  final String value;

  static Result<ListName> parse(String input) {
    final text = input.trim();
    if (text.isEmpty) {
      return const Failure(ListNameEmpty());
    }
    if (text.length > maxListNameLength) {
      return Failure(ListNameTooLong(text.length, maxListNameLength));
    }
    return Success(ListName._(text));
  }
}
