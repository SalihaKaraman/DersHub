import 'package:freezed_annotation/freezed_annotation.dart';

part 'student.freezed.dart';
part 'student.g.dart';

@freezed
class Student with _$Student {
  const factory Student({
    required String id,
    required String teacherId,
    required String nickname,
    required String gradeLevel,
    required String subject,
    required double hourlyRate,
    required DateTime createdAt,
    required bool isActive,
  }) = _Student;

  const Student._();

  factory Student.fromJson(Map<String, dynamic> json) =>
      _$StudentFromJson(json);

  factory Student.fromMap(Map<String, dynamic> map, String id) {
    return Student.fromJson({...map, 'id': id});
  }

  Map<String, dynamic> toMap() => toJson();
}
