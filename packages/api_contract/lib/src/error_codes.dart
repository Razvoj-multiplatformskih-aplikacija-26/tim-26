/// Kodovi gresaka na mrezi. Poruku za korisnika pravi klijent, ne server.
abstract final class ErrorCodes {
  static const listNameEmpty = 'list-name-empty';
  static const listNameTooLong = 'list-name-too-long';
  static const quantityNotANumber = 'quantity-not-a-number';
  static const quantityOutOfRange = 'quantity-out-of-range';
  static const itemTotalTooLarge = 'item-total-too-large';
  static const notAMember = 'not-a-member';
  static const listCompleted = 'list-completed';
  static const invalidTransition = 'invalid-transition';
  static const listHasNoItems = 'list-has-no-items';
  static const listNotInShopping = 'list-not-in-shopping';
  static const itemNotFound = 'item-not-found';
  static const priceNotANumber = 'price-not-a-number';
  static const priceOutOfRange = 'price-out-of-range';
  static const invalidPriceTransition = 'invalid-price-transition';
  static const notAllowed = 'not-allowed';
  static const notFound = 'not-found';

  static const badRequest = 'bad-request';
  static const unsupportedMediaType = 'unsupported-media-type';
  static const payloadTooLarge = 'payload-too-large';
  static const serverError = 'server-error';
  static const externalServiceUnavailable = 'external-service-unavailable';

  static const invalidCredentials = 'invalid-credentials';
  static const sessionExpired = 'session-expired';
  static const signInRequired = 'sign-in-required';
}
