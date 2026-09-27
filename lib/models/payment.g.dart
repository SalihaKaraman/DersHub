// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'payment.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_$PaymentImpl _$$PaymentImplFromJson(Map<String, dynamic> json) =>
    _$PaymentImpl(
      id: json['id'] as String,
      teacherId: json['teacherId'] as String,
      studentId: json['studentId'] as String,
      studentName: json['studentName'] as String,
      lessonId: json['lessonId'] as String?,
      amount: (json['amount'] as num).toDouble(),
      status: json['status'] as String,
      dueDate: DateTime.parse(json['dueDate'] as String),
      paymentDate: json['paymentDate'] == null
          ? null
          : DateTime.parse(json['paymentDate'] as String),
      paymentMethod: json['paymentMethod'] as String?,
    );

Map<String, dynamic> _$$PaymentImplToJson(_$PaymentImpl instance) =>
    <String, dynamic>{
      'id': instance.id,
      'teacherId': instance.teacherId,
      'studentId': instance.studentId,
      'studentName': instance.studentName,
      'lessonId': instance.lessonId,
      'amount': instance.amount,
      'status': instance.status,
      'dueDate': instance.dueDate.toIso8601String(),
      'paymentDate': instance.paymentDate?.toIso8601String(),
      'paymentMethod': instance.paymentMethod,
    };
