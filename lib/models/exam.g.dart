// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'exam.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_$ExamImpl _$$ExamImplFromJson(Map<String, dynamic> json) => _$ExamImpl(
      id: json['id'] as String,
      studentId: json['studentId'] as String,
      title: json['title'] as String,
      subject: json['subject'] as String,
      date: DateTime.parse(json['date'] as String),
      score: (json['score'] as num?)?.toDouble(),
      maxScore: (json['maxScore'] as num?)?.toDouble() ?? 100.0,
      type: json['type'] as String? ?? 'Yazılı',
      notes: json['notes'] as String?,
      createdAt: DateTime.parse(json['createdAt'] as String),
    );

Map<String, dynamic> _$$ExamImplToJson(_$ExamImpl instance) =>
    <String, dynamic>{
      'id': instance.id,
      'studentId': instance.studentId,
      'title': instance.title,
      'subject': instance.subject,
      'date': instance.date.toIso8601String(),
      'score': instance.score,
      'maxScore': instance.maxScore,
      'type': instance.type,
      'notes': instance.notes,
      'createdAt': instance.createdAt.toIso8601String(),
    };
