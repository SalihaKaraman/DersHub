import 'user_role.dart';

abstract class AppUser {
  String get id;
  String get email;
  String get fullName;
  UserRole get role;
}
