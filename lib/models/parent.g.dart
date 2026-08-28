// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'parent.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_$ParentImpl _$$ParentImplFromJson(Map<String, dynamic> json) => _$ParentImpl(
  id: json['id'] as String,
  email: json['email'] as String,
  fullName: json['fullName'] as String,
  phone: json['phone'] as String,
  linkedStudentIds: (json['linkedStudentIds'] as List<dynamic>)
      .map((e) => e as String)
      .toList(),
  linkedTeacherIds: (json['linkedTeacherIds'] as List<dynamic>)
      .map((e) => e as String)
      .toList(),
  createdAt: DateTime.parse(json['createdAt'] as String),
);

Map<String, dynamic> _$$ParentImplToJson(_$ParentImpl instance) =>
    <String, dynamic>{
      'id': instance.id,
      'email': instance.email,
      'fullName': instance.fullName,
      'phone': instance.phone,
      'linkedStudentIds': instance.linkedStudentIds,
      'linkedTeacherIds': instance.linkedTeacherIds,
      'createdAt': instance.createdAt.toIso8601String(),
    };
