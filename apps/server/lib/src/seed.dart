import 'package:domain/domain.dart';
import 'package:postgres/postgres.dart' hide Result;

import 'cartmap_store.dart';
import 'passwords.dart';

/// Pocetni podaci: 10 proizvoda, 8 prodavnica, 80 cena u sva tri stanja,
/// 11 lista u sva cetiri stanja i nalog za svaku ulogu.
const _users = [
  ('u1', 'Jovana Marić', Role.shopper, 'kupac1'),
  ('u2', 'Petar Ilić', Role.shopper, 'kupac2'),
  ('u3', 'Mila Đurić', Role.shopper, 'kupac3'),
  ('u-admin', 'Nikola Savić', Role.admin, 'admin1'),
];

const _products = [
  ('mleko', 'Mleko 2,8%', '1 l'),
  ('hleb', 'Hleb beli', '500 g'),
  ('jaja', 'Jaja M', '10 kom'),
  ('ulje', 'Suncokretovo ulje', '1 l'),
  ('brasno', 'Brašno T-400', '1 kg'),
  ('secer', 'Šećer', '1 kg'),
  ('pirinac', 'Pirinač', '1 kg'),
  ('jogurt', 'Jogurt', '1 l'),
  ('kafa', 'Mlevena kafa', '200 g'),
  ('sampon', 'Šampon', '400 ml'),
];

const _stores = [
  ('maxi1', 'Maxi Terazije', 44.8148, 20.4600),
  ('lidl1', 'Lidl Dorćol', 44.8245, 20.4690),
  ('roda1', 'Roda Slavija', 44.8020, 20.4660),
  ('dis1', 'DIS Vračar', 44.7980, 20.4750),
  ('uni1', 'Univerexport Skadarlija', 44.8185, 20.4660),
  ('idea1', 'Idea Zeleni venac', 44.8150, 20.4540),
  ('maxi2', 'Maxi Savski venac', 44.8070, 20.4480),
  ('lidl2', 'Lidl Karaburma', 44.8190, 20.5030),
];

const _basePrices = [140, 80, 220, 260, 90, 110, 200, 150, 380, 450];
const _storeFactors = [100, 92, 96, 98, 101, 99, 100, 91];

PriceStatus _statusFor(int number) {
  if (number % 5 == 0) return PriceStatus.pending;
  if (number % 7 == 3) return PriceStatus.rejected;
  return PriceStatus.approved;
}

/// (id, naziv, stanje, clanovi, stavke: (indeks proizvoda, kolicina, kupljeno))
const _lists = [
  ('l1', 'Nedeljna kupovina', ShoppingListStatus.preparing, ['u1', 'u2'],
      [(0, 2, false), (1, 1, false), (2, 1, false)]),
  ('l2', 'Doručak', ShoppingListStatus.preparing, ['u1'],
      [(0, 1, false), (1, 2, false), (8, 1, false)]),
  ('l3', 'Kućne potrepštine', ShoppingListStatus.preparing, ['u1'],
      <(int, int, bool)>[]),
  ('l4', 'Roštilj u subotu', ShoppingListStatus.ready, ['u1'],
      [(1, 3, false), (3, 1, false), (5, 1, false)]),
  ('l5', 'Slava', ShoppingListStatus.ready, ['u1', 'u2'],
      [(2, 2, false), (4, 2, false), (5, 2, false), (3, 1, false)]),
  ('l6', 'Mesečna kupovina', ShoppingListStatus.ready, ['u1'],
      [(6, 2, false), (4, 1, false), (9, 1, false), (7, 3, false)]),
  ('l7', 'Pekara i mlečni', ShoppingListStatus.shopping, ['u1', 'u2'],
      [(0, 2, true), (1, 1, false), (7, 1, false)]),
  ('l8', 'Za put', ShoppingListStatus.shopping, ['u1'],
      [(1, 2, true), (8, 1, false), (5, 1, false)]),
  ('l9', 'Rođendan', ShoppingListStatus.completed, ['u1', 'u2'],
      [(2, 2, true), (4, 1, true)]),
  ('l10', 'Prošlomesečna kupovina', ShoppingListStatus.completed, ['u1'],
      [(0, 1, true), (6, 1, true)]),
  ('l11', 'Milina lista', ShoppingListStatus.preparing, ['u3'],
      [(3, 1, false), (9, 2, false)]),
];

Future<void> seedDemoData(
  Pool<void> database, {
  required DateTime now,
  required String? demoPassword,
}) async {
  if (!await CartMapStore(database).isEmpty()) return;
  if (demoPassword == null) {
    throw StateError('DEMO_PASSWORD is not set. Copy .env.example to .env.');
  }
  final hashes = {
    for (final (id, _, _, _) in _users) id: await hashPassword(demoPassword),
  };
  await database.runTx((session) async {
    final store = CartMapStore(session);
    for (final (id, name, role, login) in _users) {
      await session.execute(
        Sql.named(
          'INSERT INTO users (id, name, role, login, password_hash) '
          'VALUES (@id, @name, @role, @login, @hash)',
        ),
        parameters: {
          'id': id,
          'name': name,
          'role': role.name,
          'login': login,
          'hash': hashes[id],
        },
      );
    }
    final products = <Product>[];
    for (final (id, name, packaging) in _products) {
      await session.execute(
        Sql.named(
          'INSERT INTO products (id, name, packaging) VALUES (@id, @name, @packaging)',
        ),
        parameters: {'id': id, 'name': name, 'packaging': packaging},
      );
      products.add(Product(id: ProductId(id), name: name, packaging: packaging));
    }
    final stores = <Store>[];
    for (final (id, name, lat, lng) in _stores) {
      await session.execute(
        Sql.named(
          'INSERT INTO stores (id, name, latitude, longitude) '
          'VALUES (@id, @name, @lat, @lng)',
        ),
        parameters: {'id': id, 'name': name, 'lat': lat, 'lng': lng},
      );
      stores.add(Store(id: StoreId(id), name: name, location: GeoPoint(lat, lng)));
    }
    for (var p = 0; p < products.length; p++) {
      for (var s = 0; s < stores.length; s++) {
        final number = p * stores.length + s;
        await store.insertPrice(
          PriceEntry(
            id: PriceEntryId('price-$number'),
            product: products[p],
            store: stores[s],
            price: _basePrices[p] * _storeFactors[s] ~/ 100,
            status: _statusFor(number),
            updatedAt: now.subtract(Duration(days: (number * 3) % 12)),
          ),
        );
      }
    }
    for (var i = 0; i < _lists.length; i++) {
      final (id, name, status, members, items) = _lists[i];
      await store.insertList(
        ShoppingList(
          id: ShoppingListId(id),
          name: name,
          status: status,
          members: [for (final member in members) UserId(member)],
          items: [
            for (final (product, quantity, bought) in items)
              ShoppingItem(
                product: products[product],
                quantity: quantity,
                bought: bought,
              ),
          ],
        ),
        createdAt: now.subtract(Duration(hours: _lists.length - i)),
      );
    }
  });
}
