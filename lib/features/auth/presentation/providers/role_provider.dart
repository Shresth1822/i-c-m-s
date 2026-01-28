import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'role_provider.g.dart';

enum UserRole { user, admin }

@riverpod
class Role extends _$Role {
  @override
  UserRole build() => UserRole.user;

  void toggle() {
    state = state == UserRole.user ? UserRole.admin : UserRole.user;
  }
}
