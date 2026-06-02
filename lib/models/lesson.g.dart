// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'lesson.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_$LessonImpl _$$LessonImplFromJson(Map<String, dynamic> json) => _$LessonImpl(
  id: json['id'] as String,
  teacherId: json['teacherId'] as String,
  studentId: json['studentId'] as String,
  studentName: json['studentName'] as String,
  dateTime: DateTime.parse(json['dateTime'] as String),
  durationMinutes: (json['durationMinutes'] as num).toInt(),
  price: (json['price'] as num).toDouble(),
  topic: json['topic'] as String,
  status: json['status'] as String? ?? 'scheduled',
  isCompleted: json['isCompleted'] as bool? ?? false,
  notes: json['notes'] as String? ?? '',
  createdAt: DateTime.parse(json['createdAt'] as String),
);

Map<String, dynamic> _$$LessonImplToJson(_$LessonImpl instance) =>
    <String, dynamic>{
      'id': instance.id,
      'teacherId': instance.teacherId,
      'studentId': instance.studentId,
      'studentName': instance.studentName,
      'dateTime': instance.dateTime.toIso8601String(),
      'durationMinutes': instance.durationMinutes,
      'price': instance.price,
      'topic': instance.topic,
      'status': instance.status,
      'isCompleted': instance.isCompleted,
      'notes': instance.notes,
      'createdAt': instance.createdAt.toIso8601String(),
    };
