import 'package:freezed_annotation/freezed_annotation.dart';
import 'lesson_status.dart';

part 'fee_policy.freezed.dart';
part 'fee_policy.g.dart';

class FeeCalculationResult {
  final double calculatedCharge;
  final double chargePercentage;
  final bool createsCompensation;
  final String description;

  const FeeCalculationResult({
    required this.calculatedCharge,
    required this.chargePercentage,
    required this.createsCompensation,
    required this.description,
  });

  @override
  String toString() =>
      'FeeCalculationResult(charge: $calculatedCharge, percent: $chargePercentage%, comp: $createsCompensation, desc: $description)';
}

@freezed
class FeePolicy with _$FeePolicy {
  const factory FeePolicy({
    @Default(24) int earlyCancellationHours,
    @Default(0.0) double earlyCancellationFeePercent,
    @Default(50.0) double lateCancellationFeePercent,
    @Default(100.0) double noShowFeePercent,
    @Default(true) bool teacherCancellationCompensable,
  }) = _FeePolicy;

  const FeePolicy._();

  factory FeePolicy.fromJson(Map<String, dynamic> json) =>
      _$FeePolicyFromJson(json);

  Map<String, dynamic> toMap() => toJson();

  FeeCalculationResult calculateCharge({
    required double lessonPrice,
    required DateTime lessonDateTime,
    required LessonStatus status,
    DateTime? statusUpdatedAt,
  }) {
    final updatedAt = statusUpdatedAt ?? DateTime.now();
    switch (status) {
      case LessonStatus.completed:
        return FeeCalculationResult(
          calculatedCharge: lessonPrice,
          chargePercentage: 100.0,
          createsCompensation: false,
          description: 'Ders tamamlandı (%100 tam ücret)',
        );
      case LessonStatus.noShow:
        final charge = lessonPrice * (noShowFeePercent / 100.0);
        return FeeCalculationResult(
          calculatedCharge: charge,
          chargePercentage: noShowFeePercent,
          createsCompensation: false,
          description:
              'Öğrenci gelmedi (%${noShowFeePercent.toStringAsFixed(0)} ücret)',
        );
      case LessonStatus.cancelledByStudent:
        final hoursUntil =
            lessonDateTime.difference(updatedAt).inMinutes / 60.0;
        if (hoursUntil >= earlyCancellationHours) {
          final charge = lessonPrice * (earlyCancellationFeePercent / 100.0);
          return FeeCalculationResult(
            calculatedCharge: charge,
            chargePercentage: earlyCancellationFeePercent,
            createsCompensation: false,
            description:
                'Erken iptal ($earlyCancellationHours+ saat önce, %${earlyCancellationFeePercent.toStringAsFixed(0)} ücret)',
          );
        } else {
          final charge = lessonPrice * (lateCancellationFeePercent / 100.0);
          return FeeCalculationResult(
            calculatedCharge: charge,
            chargePercentage: lateCancellationFeePercent,
            createsCompensation: false,
            description:
                'Geç iptal ($earlyCancellationHours saatten az kala, %${lateCancellationFeePercent.toStringAsFixed(0)} ücret)',
          );
        }
      case LessonStatus.cancelledByTeacher:
        return FeeCalculationResult(
          calculatedCharge: 0.0,
          chargePercentage: 0.0,
          createsCompensation: teacherCancellationCompensable,
          description: teacherCancellationCompensable
              ? 'Öğretmen iptali (Ücretsiz, telafi hakkı doğar)'
              : 'Öğretmen iptali (Ücretsiz)',
        );
      case LessonStatus.rescheduled:
        return const FeeCalculationResult(
          calculatedCharge: 0.0,
          chargePercentage: 0.0,
          createsCompensation: false,
          description: 'Ders ertelendi (Ücret yansıtılmaz)',
        );
      case LessonStatus.scheduled:
        return const FeeCalculationResult(
          calculatedCharge: 0.0,
          chargePercentage: 0.0,
          createsCompensation: false,
          description: 'Ders planlandı',
        );
    }
  }
}
