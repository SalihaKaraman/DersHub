import 'package:freezed_annotation/freezed_annotation.dart';
import 'app_user.dart';
import 'user_role.dart';

part 'parent.freezed.dart';
part 'parent.g.dart';

@freezed
class Parent with _$Parent implements AppUser {
  const factory Parent({
    required String id,
    required String email,
    required String fullName,
    required String phone,
    required List<String> linkedStudentIds,
    required List<String> linkedTeacherIds,
    required DateTime createdAt,
  }) = _Parent;

  const Parent._();

  @override
  UserRole get role => UserRole.parent;

  factory Parent.fromJson(Map<String, dynamic> json) => _$ParentFromJson(json);

  factory Parent.fromMap(Map<String, dynamic> map, String id) {
    return Parent.fromJson({...map, 'id': id});
  }

  Map<String, dynamic> toMap() => toJson();
}
