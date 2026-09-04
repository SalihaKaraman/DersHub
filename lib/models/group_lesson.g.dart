// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'group_lesson.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_$GroupLessonNoteImpl _$$GroupLessonNoteImplFromJson(
  Map<String, dynamic> json,
) => _$GroupLessonNoteImpl(
  studentId: json['studentId'] as String,
  studentName: json['studentName'] as String,
  personalNote: json['personalNote'] as String? ?? '',
  attended: json['attended'] as bool? ?? true,
  score: (json['score'] as num?)?.toDouble(),
);

Map<String, dynamic> _$$GroupLessonNoteImplToJson(
  _$GroupLessonNoteImpl instance,
) => <String, dynamic>{
  'studentId': instance.studentId,
  'studentName': instance.studentName,
  'personalNote': instance.personalNote,
  'attended': instance.attended,
  'score': instance.score,
};

_$GroupLessonImpl _$$GroupLessonImplFromJson(Map<String, dynamic> json) =>
    _$GroupLessonImpl(
      id: json['id'] as String,
      teacherId: json['teacherId'] as String,
      groupName: json['groupName'] as String,
      subject: json['subject'] as String,
      topic: json['topic'] as String,
      studentIds: (json['studentIds'] as List<dynamic>)
          .map((e) => e as String)
          .toList(),
      studentNames: (json['studentNames'] as List<dynamic>)
          .map((e) => e as String)
          .toList(),
      dateTime: DateTime.parse(json['dateTime'] as String),
      durationMinutes: (json['durationMinutes'] as num).toInt(),
      pricePerStudent: (json['pricePerStudent'] as num).toDouble(),
      notes: json['notes'] as String? ?? '',
      individualNotes:
          (json['individualNotes'] as List<dynamic>?)
              ?.map((e) => GroupLessonNote.fromJson(e as Map<String, dynamic>))
              .toList() ??
          const [],
      isCompleted: json['isCompleted'] as bool? ?? false,
      createdAt: DateTime.parse(json['createdAt'] as String),
    );

Map<String, dynamic> _$$GroupLessonImplToJson(_$GroupLessonImpl instance) =>
    <String, dynamic>{
      'id': instance.id,
      'teacherId': instance.teacherId,
      'groupName': instance.groupName,
      'subject': instance.subject,
      'topic': instance.topic,
      'studentIds': instance.studentIds,
      'studentNames': instance.studentNames,
      'dateTime': instance.dateTime.toIso8601String(),
      'durationMinutes': instance.durationMinutes,
      'pricePerStudent': instance.pricePerStudent,
      'notes': instance.notes,
      'individualNotes': instance.individualNotes,
      'isCompleted': instance.isCompleted,
      'createdAt': instance.createdAt.toIso8601String(),
    };
