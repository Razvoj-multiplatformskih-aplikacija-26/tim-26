import 'package:api_mapping/api_mapping.dart';
import 'package:domain/domain.dart';
import 'package:postgres/postgres.dart' hide Result;

final class Account {
  const Account({required this.user, required this.passwordHash});

  final User user;
  final String passwordHash;
}

final class AccountStore {
  const AccountStore(this._database);

  final Session _database;

  Future<Account?> account(String login) async {
    final rows = await _database.execute(
      Sql.named(
        'SELECT id, name, role, password_hash FROM users '
        'WHERE login = @login AND password_hash IS NOT NULL',
      ),
      parameters: {'login': login},
    );
    if (rows.isEmpty) return null;
    final row = rows.single;
    return Account(
      user: User(
        id: UserId(row[0]! as String),
        name: row[1]! as String,
        role: roleFromJson(row[2]! as String),
      ),
      passwordHash: row[3]! as String,
    );
  }
}
