// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'fee_policy.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_$FeePolicyImpl _$$FeePolicyImplFromJson(Map<String, dynamic> json) =>
    _$FeePolicyImpl(
      earlyCancellationHours:
          (json['earlyCancellationHours'] as num?)?.toInt() ?? 24,
      earlyCancellationFeePercent:
          (json['earlyCancellationFeePercent'] as num?)?.toDouble() ?? 0.0,
      lateCancellationFeePercent:
          (json['lateCancellationFeePercent'] as num?)?.toDouble() ?? 50.0,
      noShowFeePercent: (json['noShowFeePercent'] as num?)?.toDouble() ?? 100.0,
      teacherCancellationCompensable:
          json['teacherCancellationCompensable'] as bool? ?? true,
    );

Map<String, dynamic> _$$FeePolicyImplToJson(_$FeePolicyImpl instance) =>
    <String, dynamic>{
      'earlyCancellationHours': instance.earlyCancellationHours,
      'earlyCancellationFeePercent': instance.earlyCancellationFeePercent,
      'lateCancellationFeePercent': instance.lateCancellationFeePercent,
      'noShowFeePercent': instance.noShowFeePercent,
      'teacherCancellationCompensable': instance.teacherCancellationCompensable,
    };
