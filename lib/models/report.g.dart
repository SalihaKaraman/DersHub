// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'report.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_$TopicProgressImpl _$$TopicProgressImplFromJson(Map<String, dynamic> json) =>
    _$TopicProgressImpl(
      topic: json['topic'] as String,
      lessonsCount: (json['lessonsCount'] as num).toInt(),
      level: json['level'] as String,
      proficiency: (json['proficiency'] as num).toDouble(),
      notes: json['notes'] as String? ?? '',
    );

Map<String, dynamic> _$$TopicProgressImplToJson(_$TopicProgressImpl instance) =>
    <String, dynamic>{
      'topic': instance.topic,
      'lessonsCount': instance.lessonsCount,
      'level': instance.level,
      'proficiency': instance.proficiency,
      'notes': instance.notes,
    };

_$StudentReportImpl _$$StudentReportImplFromJson(Map<String, dynamic> json) =>
    _$StudentReportImpl(
      id: json['id'] as String,
      teacherId: json['teacherId'] as String,
      studentId: json['studentId'] as String,
      studentName: json['studentName'] as String,
      teacherName: json['teacherName'] as String? ?? '',
      reportDate: DateTime.parse(json['reportDate'] as String),
      period: json['period'] as String,
      totalLessons: (json['totalLessons'] as num).toInt(),
      totalHours: (json['totalHours'] as num).toInt(),
      topicProgress: (json['topicProgress'] as List<dynamic>)
          .map((e) => TopicProgress.fromJson(e as Map<String, dynamic>))
          .toList(),
      overallFeedback: json['overallFeedback'] as String,
      strengths: (json['strengths'] as List<dynamic>)
          .map((e) => e as String)
          .toList(),
      areasForImprovement: (json['areasForImprovement'] as List<dynamic>)
          .map((e) => e as String)
          .toList(),
      monthlyLessonCount:
          (json['monthlyLessonCount'] as Map<String, dynamic>?)?.map(
            (k, e) => MapEntry(k, (e as num).toInt()),
          ) ??
          const {},
      averageScore: (json['averageScore'] as num?)?.toDouble() ?? 0.0,
      reportType: json['reportType'] as String? ?? 'progress_report',
      certificateId: json['certificateId'] as String?,
      title: json['title'] as String? ?? 'Aylık İlerleme Raporu',
      createdAt: json['createdAt'] == null
          ? null
          : DateTime.parse(json['createdAt'] as String),
    );

Map<String, dynamic> _$$StudentReportImplToJson(_$StudentReportImpl instance) =>
    <String, dynamic>{
      'id': instance.id,
      'teacherId': instance.teacherId,
      'studentId': instance.studentId,
      'studentName': instance.studentName,
      'teacherName': instance.teacherName,
      'reportDate': instance.reportDate.toIso8601String(),
      'period': instance.period,
      'totalLessons': instance.totalLessons,
      'totalHours': instance.totalHours,
      'topicProgress': instance.topicProgress,
      'overallFeedback': instance.overallFeedback,
      'strengths': instance.strengths,
      'areasForImprovement': instance.areasForImprovement,
      'monthlyLessonCount': instance.monthlyLessonCount,
      'averageScore': instance.averageScore,
      'reportType': instance.reportType,
      'certificateId': instance.certificateId,
      'title': instance.title,
      'createdAt': instance.createdAt?.toIso8601String(),
    };
