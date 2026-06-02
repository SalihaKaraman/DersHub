// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'student.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_$StudentImpl _$$StudentImplFromJson(Map<String, dynamic> json) =>
    _$StudentImpl(
      id: json['id'] as String,
      teacherId: json['teacherId'] as String,
      nickname: json['nickname'] as String,
      gradeLevel: json['gradeLevel'] as String,
      subject: json['subject'] as String,
      hourlyRate: (json['hourlyRate'] as num).toDouble(),
      createdAt: DateTime.parse(json['createdAt'] as String),
      isActive: json['isActive'] as bool,
    );

Map<String, dynamic> _$$StudentImplToJson(_$StudentImpl instance) =>
    <String, dynamic>{
      'id': instance.id,
      'teacherId': instance.teacherId,
      'nickname': instance.nickname,
      'gradeLevel': instance.gradeLevel,
      'subject': instance.subject,
      'hourlyRate': instance.hourlyRate,
      'createdAt': instance.createdAt.toIso8601String(),
      'isActive': instance.isActive,
    };
