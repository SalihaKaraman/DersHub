import 'package:freezed_annotation/freezed_annotation.dart';

part 'report.freezed.dart';
part 'report.g.dart';

@freezed
class TopicProgress with _$TopicProgress {
  const factory TopicProgress({
    required String topic,
    required int lessonsCount,
    required String level, // "Başlangıç", "Orta", "İleri"
    required double proficiency, // 0.0 - 1.0
    @Default('') String notes,
  }) = _TopicProgress;

  factory TopicProgress.fromJson(Map<String, dynamic> json) =>
      _$TopicProgressFromJson(json);
}

@freezed
class StudentReport with _$StudentReport {
  const factory StudentReport({
    required String id,
    required String teacherId,
    required String studentId,
    required String studentName,
    @Default('') String teacherName,
    required DateTime reportDate,
    required String period, // "Eylül 2026", "Ağustos 2026"
    required int totalLessons,
    required int totalHours,
    required List<TopicProgress> topicProgress,
    required String overallFeedback,
    required List<String> strengths,
    required List<String> areasForImprovement,
    @Default({}) Map<String, int> monthlyLessonCount,
    @Default(0.0) double averageScore,
    @Default('progress_report') String reportType, // "progress_report" veya "certificate"
    String? certificateId, // "DK-2026-CERT-01"
    @Default('Aylık İlerleme Raporu') String title,
    DateTime? createdAt,
  }) = _StudentReport;

  const StudentReport._();

  factory StudentReport.fromJson(Map<String, dynamic> json) =>
      _$StudentReportFromJson(json);

  factory StudentReport.fromMap(Map<String, dynamic> map, String id) {
    final rawProgress = map['topicProgress'];
    final List<TopicProgress> progressList = [];
    if (rawProgress is List) {
      for (final item in rawProgress) {
        if (item is TopicProgress) {
          progressList.add(item);
        } else if (item is Map) {
          progressList.add(TopicProgress.fromJson(Map<String, dynamic>.from(item)));
        }
      }
    }

    return StudentReport(
      id: id,
      teacherId: map['teacherId'] as String? ?? '',
      studentId: map['studentId'] as String? ?? '',
      studentName: map['studentName'] as String? ?? '',
      teacherName: map['teacherName'] as String? ?? '',
      reportDate: map['reportDate'] is String
          ? DateTime.parse(map['reportDate'] as String)
          : (map['reportDate'] != null
              ? (map['reportDate']).toDate()
              : DateTime.now()),
      period: map['period'] as String? ?? '',
      totalLessons: (map['totalLessons'] as num?)?.toInt() ?? 0,
      totalHours: (map['totalHours'] as num?)?.toInt() ?? 0,
      topicProgress: progressList,
      overallFeedback: map['overallFeedback'] as String? ?? '',
      strengths: List<String>.from(map['strengths'] ?? []),
      areasForImprovement: List<String>.from(map['areasForImprovement'] ?? []),
      monthlyLessonCount: Map<String, int>.from(map['monthlyLessonCount'] ?? {}),
      averageScore: (map['averageScore'] as num?)?.toDouble() ?? 0.0,
      reportType: map['reportType'] as String? ?? 'progress_report',
      certificateId: map['certificateId'] as String?,
      title: map['title'] as String? ?? 'Aylık İlerleme Raporu',
      createdAt: map['createdAt'] is String
          ? DateTime.parse(map['createdAt'] as String)
          : (map['createdAt'] != null
              ? (map['createdAt']).toDate()
              : DateTime.now()),
    );
  }

  Map<String, dynamic> toMap() {
    final json = toJson();
    json.remove('id');
    json['topicProgress'] = topicProgress.map((e) => e.toJson()).toList();
    return json;
  }
}
