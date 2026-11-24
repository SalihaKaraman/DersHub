import 'package:freezed_annotation/freezed_annotation.dart';
import 'lesson_status.dart';

part 'lesson.freezed.dart';
part 'lesson.g.dart';

@freezed
class Lesson with _$Lesson {
  const factory Lesson({
    required String id,
    required String teacherId,
    required String studentId,
    required String studentName,
    required DateTime dateTime,
    required int durationMinutes,
    required double price,
    required String topic,
    @Default('scheduled') String status,
    @Default(false) bool isCompleted,
    @Default('') String notes,
    required DateTime createdAt,
    DateTime? statusUpdatedAt,
    String? cancellationReason,
    double? calculatedCharge,
    double? chargePercentage,
    @Default(false) bool createsCompensation,
  }) = _Lesson;

  const Lesson._();

  LessonStatus get lessonStatus =>
      LessonStatus.fromString(status, isCompleted: isCompleted);

  double get finalCharge => calculatedCharge ?? (isCompleted ? price : 0.0);

  bool get isCancelled =>
      lessonStatus == LessonStatus.cancelledByStudent ||
      lessonStatus == LessonStatus.cancelledByTeacher;

  factory Lesson.fromJson(Map<String, dynamic> json) => _$LessonFromJson(json);

  factory Lesson.fromMap(Map<String, dynamic> map, String id) {
    return Lesson.fromJson({...map, 'id': id});
  }

  Map<String, dynamic> toMap() {
    final json = toJson();
    json.remove('id');
    return json;
  }
}
