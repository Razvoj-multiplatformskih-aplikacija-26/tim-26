import 'ids.dart';

/// Uloge u sistemu: kupac koristi mobilnu aplikaciju, administrator backoffice.
enum Role { shopper, admin }

final class User {
  const User({required this.id, required this.name, required this.role});

  final UserId id;
  final String name;
  final Role role;

  @override
  bool operator ==(Object other) =>
      other is User && other.id == id && other.name == name && other.role == role;

  @override
  int get hashCode => Object.hash(id, name, role);

  @override
  String toString() => 'User($name, ${role.name})';
}
