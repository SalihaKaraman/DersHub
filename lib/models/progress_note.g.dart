// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'progress_note.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_$ProgressNoteImpl _$$ProgressNoteImplFromJson(Map<String, dynamic> json) =>
    _$ProgressNoteImpl(
      id: json['id'] as String,
      studentId: json['studentId'] as String,
      teacherId: json['teacherId'] as String,
      topic: json['topic'] as String,
      strengths: (json['strengths'] as List<dynamic>)
          .map((e) => e as String)
          .toList(),
      weaknesses: (json['weaknesses'] as List<dynamic>)
          .map((e) => e as String)
          .toList(),
      goals: json['goals'] as String,
      createdAt: DateTime.parse(json['createdAt'] as String),
    );

Map<String, dynamic> _$$ProgressNoteImplToJson(_$ProgressNoteImpl instance) =>
    <String, dynamic>{
      'id': instance.id,
      'studentId': instance.studentId,
      'teacherId': instance.teacherId,
      'topic': instance.topic,
      'strengths': instance.strengths,
      'weaknesses': instance.weaknesses,
      'goals': instance.goals,
      'createdAt': instance.createdAt.toIso8601String(),
    };
