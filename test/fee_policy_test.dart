import 'package:flutter_test/flutter_test.dart';
import 'package:dershub/models/fee_policy.dart';
import 'package:dershub/models/lesson_status.dart';

void main() {
  // Sabit test tarihleri
  final lessonDateTime = DateTime(2024, 6, 15, 16, 0); // Ders saati: 15 Haziran 16:00

  group('FeePolicy — Erken İptal (öğrenci, 24+ saat önce)', () {
    final policy = const FeePolicy(
      earlyCancellationHours: 24,
      earlyCancellationFeePercent: 0.0,
      lateCancellationFeePercent: 50.0,
      noShowFeePercent: 100.0,
      teacherCancellationCompensable: true,
    );

    test('Ders saatine 48 saat kala iptal → %0 ücret', () {
      final statusUpdatedAt = lessonDateTime.subtract(const Duration(hours: 48));
      final result = policy.calculateCharge(
        lessonPrice: 1000,
        lessonDateTime: lessonDateTime,
        status: LessonStatus.cancelledByStudent,
        statusUpdatedAt: statusUpdatedAt,
      );

      expect(result.calculatedCharge, equals(0.0));
      expect(result.chargePercentage, equals(0.0));
      expect(result.createsCompensation, isFalse);
    });

    test('Ders saatine tam 24 saat kala iptal → %0 ücret (eşik dahil)', () {
      final statusUpdatedAt = lessonDateTime.subtract(const Duration(hours: 24));
      final result = policy.calculateCharge(
        lessonPrice: 1000,
        lessonDateTime: lessonDateTime,
        status: LessonStatus.cancelledByStudent,
        statusUpdatedAt: statusUpdatedAt,
      );

      expect(result.calculatedCharge, equals(0.0));
      expect(result.chargePercentage, equals(0.0));
    });
  });

  group('FeePolicy — Geç İptal (öğrenci, 24 saatten az)', () {
    final policy = const FeePolicy(
      earlyCancellationHours: 24,
      earlyCancellationFeePercent: 0.0,
      lateCancellationFeePercent: 50.0,
      noShowFeePercent: 100.0,
    );

    test('Ders saatine 2 saat kala iptal → %50 ücret', () {
      final statusUpdatedAt = lessonDateTime.subtract(const Duration(hours: 2));
      final result = policy.calculateCharge(
        lessonPrice: 1000,
        lessonDateTime: lessonDateTime,
        status: LessonStatus.cancelledByStudent,
        statusUpdatedAt: statusUpdatedAt,
      );

      expect(result.calculatedCharge, equals(500.0));
      expect(result.chargePercentage, equals(50.0));
      expect(result.createsCompensation, isFalse);
    });

    test('Özel politika: %30 geç iptal', () {
      const customPolicy = FeePolicy(
        earlyCancellationHours: 12,
        lateCancellationFeePercent: 30.0,
        noShowFeePercent: 80.0,
      );
      final statusUpdatedAt = lessonDateTime.subtract(const Duration(hours: 5));
      final result = customPolicy.calculateCharge(
        lessonPrice: 1000,
        lessonDateTime: lessonDateTime,
        status: LessonStatus.cancelledByStudent,
        statusUpdatedAt: statusUpdatedAt,
      );

      expect(result.calculatedCharge, equals(300.0));
      expect(result.chargePercentage, equals(30.0));
    });
  });

  group('FeePolicy — Gelmedi (No-Show)', () {
    final policy = const FeePolicy(noShowFeePercent: 100.0);

    test('No-show → %100 tam ücret', () {
      final result = policy.calculateCharge(
        lessonPrice: 800,
        lessonDateTime: lessonDateTime,
        status: LessonStatus.noShow,
      );

      expect(result.calculatedCharge, equals(800.0));
      expect(result.chargePercentage, equals(100.0));
      expect(result.createsCompensation, isFalse);
    });

    test('No-show özel politika %75', () {
      const customPolicy = FeePolicy(noShowFeePercent: 75.0);
      final result = customPolicy.calculateCharge(
        lessonPrice: 1000,
        lessonDateTime: lessonDateTime,
        status: LessonStatus.noShow,
      );

      expect(result.calculatedCharge, equals(750.0));
      expect(result.chargePercentage, equals(75.0));
    });
  });

  group('FeePolicy — Tamamlandı', () {
    test('Yapıldı → %100 tam ücret', () {
      const policy = FeePolicy();
      final result = policy.calculateCharge(
        lessonPrice: 900,
        lessonDateTime: lessonDateTime,
        status: LessonStatus.completed,
      );

      expect(result.calculatedCharge, equals(900.0));
      expect(result.chargePercentage, equals(100.0));
      expect(result.createsCompensation, isFalse);
    });
  });

  group('FeePolicy — Öğretmen İptali', () {
    test('Telafi açıksa: %0 ücret + telafi hakkı', () {
      const policy = FeePolicy(teacherCancellationCompensable: true);
      final result = policy.calculateCharge(
        lessonPrice: 1000,
        lessonDateTime: lessonDateTime,
        status: LessonStatus.cancelledByTeacher,
      );

      expect(result.calculatedCharge, equals(0.0));
      expect(result.chargePercentage, equals(0.0));
      expect(result.createsCompensation, isTrue);
    });

    test('Telafi kapalıysa: %0 ücret + telafi YOK', () {
      const policy = FeePolicy(teacherCancellationCompensable: false);
      final result = policy.calculateCharge(
        lessonPrice: 1000,
        lessonDateTime: lessonDateTime,
        status: LessonStatus.cancelledByTeacher,
      );

      expect(result.calculatedCharge, equals(0.0));
      expect(result.createsCompensation, isFalse);
    });
  });

  group('FeePolicy — Ertelendi', () {
    test('Erteleme → %0 ücret, telafi yok', () {
      const policy = FeePolicy();
      final result = policy.calculateCharge(
        lessonPrice: 1000,
        lessonDateTime: lessonDateTime,
        status: LessonStatus.rescheduled,
      );

      expect(result.calculatedCharge, equals(0.0));
      expect(result.createsCompensation, isFalse);
    });
  });

  group('FeePolicy — Planlandı', () {
    test('Planlandı → %0 ücret (henüz gerçekleşmedi)', () {
      const policy = FeePolicy();
      final result = policy.calculateCharge(
        lessonPrice: 1000,
        lessonDateTime: lessonDateTime,
        status: LessonStatus.scheduled,
      );

      expect(result.calculatedCharge, equals(0.0));
      expect(result.chargePercentage, equals(0.0));
      expect(result.createsCompensation, isFalse);
    });
  });

  group('LessonStatus — Enum dönüşümü (geriye dönük uyumluluk)', () {
    test('Boş string → scheduled', () {
      expect(LessonStatus.fromString(''), equals(LessonStatus.scheduled));
    });

    test('null → scheduled', () {
      expect(LessonStatus.fromString(null), equals(LessonStatus.scheduled));
    });

    test('isCompleted=true → completed', () {
      expect(LessonStatus.fromString(null, isCompleted: true), equals(LessonStatus.completed));
    });

    test('"completed" → completed', () {
      expect(LessonStatus.fromString('completed'), equals(LessonStatus.completed));
    });

    test('"cancelledByStudent" → cancelledByStudent', () {
      expect(LessonStatus.fromString('cancelledByStudent'), equals(LessonStatus.cancelledByStudent));
    });

    test('"cancelledByTeacher" → cancelledByTeacher', () {
      expect(LessonStatus.fromString('cancelledByTeacher'), equals(LessonStatus.cancelledByTeacher));
    });

    test('"rescheduled" → rescheduled', () {
      expect(LessonStatus.fromString('rescheduled'), equals(LessonStatus.rescheduled));
    });

    test('"noShow" → noShow', () {
      expect(LessonStatus.fromString('noShow'), equals(LessonStatus.noShow));
    });

    test('Tanımsız string + isCompleted=false → scheduled', () {
      expect(LessonStatus.fromString('bilinmeyen'), equals(LessonStatus.scheduled));
    });

    test('Tanımsız string + isCompleted=true → completed', () {
      expect(LessonStatus.fromString('bilinmeyen', isCompleted: true), equals(LessonStatus.completed));
    });
  });

  group('FeePolicy — Öğrenci özel politika override', () {
    const globalPolicy = FeePolicy(
      lateCancellationFeePercent: 50.0,
      noShowFeePercent: 100.0,
    );
    const customPolicy = FeePolicy(
      lateCancellationFeePercent: 25.0,
      noShowFeePercent: 60.0,
    );

    test('Özel politika genel politikayı ezer (no-show)', () {
      final statusUpdatedAt = lessonDateTime.subtract(const Duration(hours: 1));
      final globalResult = globalPolicy.calculateCharge(
        lessonPrice: 1000,
        lessonDateTime: lessonDateTime,
        status: LessonStatus.noShow,
        statusUpdatedAt: statusUpdatedAt,
      );
      final customResult = customPolicy.calculateCharge(
        lessonPrice: 1000,
        lessonDateTime: lessonDateTime,
        status: LessonStatus.noShow,
        statusUpdatedAt: statusUpdatedAt,
      );

      expect(globalResult.calculatedCharge, equals(1000.0));
      expect(customResult.calculatedCharge, equals(600.0));
    });
  });
}
