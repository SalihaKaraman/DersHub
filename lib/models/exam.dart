import 'package:freezed_annotation/freezed_annotation.dart';

part 'exam.freezed.dart';
part 'exam.g.dart';

@freezed
class Exam with _$Exam {
  const factory Exam({
    required String id,
    required String studentId,
    required String title, // Örn: 1. Dönem 1. Yazılı
    required String subject, // Örn: Matematik
    required DateTime date,
    double? score,
    @Default(100.0) double maxScore,
    @Default('Yazılı') String type, // Yazılı, Sözel, Deneme vs.
    String? notes,
    required DateTime createdAt,
  }) = _Exam;

  const Exam._();

  factory Exam.fromJson(Map<String, dynamic> json) => _$ExamFromJson(json);

  factory Exam.fromMap(Map<String, dynamic> map, String id) {
    return Exam.fromJson({...map, 'id': id});
  }

  Map<String, dynamic> toMap() => toJson();
}
