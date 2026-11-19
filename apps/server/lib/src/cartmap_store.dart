import 'package:domain/domain.dart';
import 'package:postgres/postgres.dart' hide Result;

/// SQL nad bazom. Pravila ne proverava; to radi domen u handler-ima.
final class CartMapStore {
  const CartMapStore(this._database);

  final Session _database;

  Future<bool> isEmpty() async {
    final rows = await _database.execute('SELECT count(*) FROM users');
    return rows.single[0] == 0;
  }

  Future<String> newId() async {
    final rows = await _database.execute('SELECT gen_random_uuid()::text');
    return rows.single[0]! as String;
  }

  // Katalog

  Future<List<Product>> products() async {
    final rows = await _database.execute(
      'SELECT id, name, packaging FROM products ORDER BY name',
    );
    return [for (final row in rows) _product(row, 0)];
  }

  Future<Product?> product(ProductId id) async {
    final rows = await _database.execute(
      Sql.named('SELECT id, name, packaging FROM products WHERE id = @id'),
      parameters: {'id': id.value},
    );
    return rows.isEmpty ? null : _product(rows.single, 0);
  }

  Future<List<Store>> stores() async {
    final rows = await _database.execute(
      'SELECT id, name, latitude, longitude FROM stores ORDER BY name',
    );
    return [for (final row in rows) _store(row, 0)];
  }

  Future<Store?> store(StoreId id) async {
    final rows = await _database.execute(
      Sql.named(
        'SELECT id, name, latitude, longitude FROM stores WHERE id = @id',
      ),
      parameters: {'id': id.value},
    );
    return rows.isEmpty ? null : _store(rows.single, 0);
  }

  // Cene

  static const _priceColumns = '''
    SELECT pr.id, pr.price, pr.status, pr.updated_at,
           p.id, p.name, p.packaging,
           s.id, s.name, s.latitude, s.longitude
    FROM prices pr
    JOIN products p ON p.id = pr.product_id
    JOIN stores s ON s.id = pr.store_id
  ''';

  Future<int> priceCount({required bool onlyApproved}) async {
    final rows = await _database.execute(
      onlyApproved
          ? "SELECT count(*) FROM prices WHERE status = 'approved'"
          : 'SELECT count(*) FROM prices',
    );
    return rows.single[0]! as int;
  }

  Future<List<PriceEntry>> prices({
    required bool onlyApproved,
    required int offset,
    required int limit,
  }) async {
    final where = onlyApproved ? "WHERE pr.status = 'approved'" : '';
    final rows = await _database.execute(
      Sql.named(
        '$_priceColumns $where '
        'ORDER BY pr.updated_at DESC, pr.id LIMIT @limit OFFSET @offset',
      ),
      parameters: {'limit': limit, 'offset': offset},
    );
    return [for (final row in rows) _price(row)];
  }

  /// Sa [lock] zakljucava red do kraja transakcije, pa drugi poziv za istu cenu ceka.
  Future<PriceEntry?> price(PriceEntryId id, {bool lock = false}) async {
    final rows = await _database.execute(
      Sql.named(
        '$_priceColumns WHERE pr.id = @id${lock ? ' FOR UPDATE OF pr' : ''}',
      ),
      parameters: {'id': id.value},
    );
    return rows.isEmpty ? null : _price(rows.single);
  }

  Future<void> insertPrice(PriceEntry entry, {UserId? reportedBy}) async {
    await _database.execute(
      Sql.named('''
        INSERT INTO prices (id, product_id, store_id, price, status, updated_at, reported_by)
        VALUES (@id, @product, @store, @price, @status, @updated, @reportedBy)
      '''),
      parameters: {
        'id': entry.id.value,
        'product': entry.product.id.value,
        'store': entry.store.id.value,
        'price': entry.price,
        'status': entry.status.name,
        'updated': entry.updatedAt.toUtc(),
        'reportedBy': reportedBy?.value,
      },
    );
  }

  Future<void> updatePriceStatus(PriceEntry entry) async {
    await _database.execute(
      Sql.named('UPDATE prices SET status = @status WHERE id = @id'),
      parameters: {'id': entry.id.value, 'status': entry.status.name},
    );
  }

  // Liste

  Future<List<ShoppingList>> listsOf(UserId user) async {
    final rows = await _database.execute(
      Sql.named('''
        SELECT l.id, l.name, l.status
        FROM shopping_lists l
        JOIN list_members m ON m.list_id = l.id
        WHERE m.user_id = @user
        ORDER BY l.created_at, l.id
      '''),
      parameters: {'user': user.value},
    );
    return [for (final row in rows) await _withMembersAndItems(row)];
  }

  /// Sa [lock] zakljucava listu do kraja transakcije (SELECT ... FOR UPDATE).
  /// Zato dva istovremena poziva za istu listu prolaze jedan za drugim,
  /// a drugi vidi izmenu prvog pre nego sto domen proveri pravilo.
  Future<ShoppingList?> list(ShoppingListId id, {bool lock = false}) async {
    final rows = await _database.execute(
      Sql.named(
        'SELECT id, name, status FROM shopping_lists WHERE id = @id'
        '${lock ? ' FOR UPDATE' : ''}',
      ),
      parameters: {'id': id.value},
    );
    return rows.isEmpty ? null : _withMembersAndItems(rows.single);
  }

  Future<void> insertList(ShoppingList list, {DateTime? createdAt}) async {
    await _database.execute(
      Sql.named('''
        INSERT INTO shopping_lists (id, name, status, created_at)
        VALUES (@id, @name, @status, @created)
      '''),
      parameters: {
        'id': list.id.value,
        'name': list.name,
        'status': list.status.name,
        'created': (createdAt ?? DateTime.now()).toUtc(),
      },
    );
    for (final member in list.members) {
      await _database.execute(
        Sql.named(
          'INSERT INTO list_members (list_id, user_id) VALUES (@list, @user)',
        ),
        parameters: {'list': list.id.value, 'user': member.value},
      );
    }
    await _saveItems(list);
  }

  Future<void> saveList(ShoppingList list) async {
    await _database.execute(
      Sql.named('UPDATE shopping_lists SET status = @status WHERE id = @id'),
      parameters: {'id': list.id.value, 'status': list.status.name},
    );
    await _saveItems(list);
  }

  Future<void> _saveItems(ShoppingList list) async {
    for (final item in list.items) {
      await _database.execute(
        Sql.named('''
          INSERT INTO list_items (list_id, product_id, quantity, bought)
          VALUES (@list, @product, @quantity, @bought)
          ON CONFLICT (list_id, product_id)
          DO UPDATE SET quantity = EXCLUDED.quantity, bought = EXCLUDED.bought
        '''),
        parameters: {
          'list': list.id.value,
          'product': item.product.id.value,
          'quantity': item.quantity,
          'bought': item.bought,
        },
      );
    }
  }

  Future<ShoppingList> _withMembersAndItems(ResultRow row) async {
    final id = row[0]! as String;
    final members = await _database.execute(
      Sql.named(
        'SELECT user_id FROM list_members WHERE list_id = @id ORDER BY seq',
      ),
      parameters: {'id': id},
    );
    final items = await _database.execute(
      Sql.named('''
        SELECT p.id, p.name, p.packaging, i.quantity, i.bought
        FROM list_items i
        JOIN products p ON p.id = i.product_id
        WHERE i.list_id = @id
        ORDER BY i.seq
      '''),
      parameters: {'id': id},
    );
    return ShoppingList(
      id: ShoppingListId(id),
      name: row[1]! as String,
      status: ShoppingListStatus.values.byName(row[2]! as String),
      members: [for (final member in members) UserId(member[0]! as String)],
      items: [
        for (final item in items)
          ShoppingItem(
            product: _product(item, 0),
            quantity: item[3]! as int,
            bought: item[4]! as bool,
          ),
      ],
    );
  }
}

Product _product(ResultRow row, int from) => Product(
  id: ProductId(row[from]! as String),
  name: row[from + 1]! as String,
  packaging: row[from + 2]! as String,
);

Store _store(ResultRow row, int from) => Store(
  id: StoreId(row[from]! as String),
  name: row[from + 1]! as String,
  location: GeoPoint(row[from + 2]! as double, row[from + 3]! as double),
);

PriceEntry _price(ResultRow row) => PriceEntry(
  id: PriceEntryId(row[0]! as String),
  price: row[1]! as int,
  status: PriceStatus.values.byName(row[2]! as String),
  updatedAt: (row[3]! as DateTime).toUtc(),
  product: _product(row, 4),
  store: _store(row, 7),
);
