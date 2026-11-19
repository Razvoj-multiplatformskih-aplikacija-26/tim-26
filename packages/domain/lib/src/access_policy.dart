import 'catalog.dart';
import 'shopping_list.dart';
import 'user.dart';

/// Sva prava na jednom mestu. Koriste ih mobilna aplikacija, backoffice i server.
abstract final class AccessPolicy {
  static bool canUseMobileApp(User user) => user.role == Role.shopper;

  static bool canUseBackoffice(User user) => user.role == Role.admin;

  /// Liste za kupovinu imaju samo kupci.
  static bool canHaveLists(User user) => user.role == Role.shopper;

  /// Listu vide i menjaju samo njeni clanovi.
  static bool canViewList(User user, ShoppingList list) =>
      list.members.contains(user.id);

  /// Kupac prijavljuje cenu koju je video u prodavnici; ceka proveru.
  static bool canReportPrice(User user) => user.role == Role.shopper;

  /// Potvrda i odbijanje cene.
  static bool canReviewPrices(User user) => user.role == Role.admin;

  /// Unos proverene cene.
  static bool canEnterPrices(User user) => user.role == Role.admin;

  /// Preuzimanje cena iz spoljnog izvora.
  static bool canImportPrices(User user) => user.role == Role.admin;

  /// Kupac vidi samo potvrdjene cene, administrator sve.
  static bool seesOnlyApprovedPrices(User user) => user.role != Role.admin;

  static bool canSeePrice(User user, PriceEntry entry) =>
      !seesOnlyApprovedPrices(user) || entry.status == PriceStatus.approved;
}
