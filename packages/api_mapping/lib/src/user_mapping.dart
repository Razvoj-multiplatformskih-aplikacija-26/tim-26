import 'package:api_contract/api_contract.dart';
import 'package:domain/domain.dart';

Role roleFromJson(String value) =>
    Role.values.asNameMap()[value] ??
    (throw FormatException('Unknown role', value));

extension UserMapping on User {
  UserDto toDto() => UserDto(id: id.value, name: name, role: role.name);
}

extension UserDtoMapping on UserDto {
  User toDomain() => User(id: UserId(id), name: name, role: roleFromJson(role));
}
