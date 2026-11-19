abstract final class ApiPaths {
  static const health = '/health';

  static const sessions = '/api/v1/sessions';
  static const currentSession = '/api/v1/sessions/current';

  static const catalog = '/api/v1/catalog';
  static const prices = '/api/v1/prices';
  static const priceReports = '/api/v1/price-reports';
  static const priceImports = '/api/v1/price-imports';

  static String priceStatus(String id) => '$prices/$id/status';

  static const lists = '/api/v1/lists';

  static String listStatus(String id) => '$lists/$id/status';

  static String listItems(String id) => '$lists/$id/items';

  static String itemBought(String listId, String productId) =>
      '${listItems(listId)}/$productId/bought';

  static const addresses = '/api/v1/addresses';
}

abstract final class ApiQuery {
  static const offset = 'offset';
  static const limit = 'limit';
  static const text = 'q';
}

/// Deo velike liste trazi se sa offset i limit; server vraca i ukupan broj.
abstract final class ApiPaging {
  static const defaultLimit = 50;
  static const maxLimit = 200;
}

abstract final class ApiCookies {
  static const session = 'cartmap_session';
}

/// Stanja i uloge idu preko mreze kao tekst, isti kao imena u domenu.
abstract final class ApiValues {
  static const listStatuses = ['preparing', 'ready', 'shopping', 'completed'];
  static const priceStatuses = ['pending', 'approved', 'rejected'];
  static const roles = ['shopper', 'admin'];
}
