import 'package:flutter_test/flutter_test.dart';
import 'package:dershub/models/report.dart';
import 'package:dershub/models/student.dart';
import 'package:dershub/services/pdf_generator_service.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  group('Prompt 3 - PDF ve Rapor Testleri', () {
    final testStudent = Student(
      id: 's1',
      teacherId: 't1',
      nickname: 'Derin Aksoy',
      gradeLevel: '12. Sınıf',
      subject: 'Matematik (AYT)',
      hourlyRate: 800,
      isActive: true,
      createdAt: DateTime.now(),
    );

    final testReport = StudentReport(
      id: 'rep-test-1',
      teacherId: 't1',
      studentId: 's1',
      studentName: 'Derin Aksoy',
      teacherName: 'Saliha Öğretmen',
      reportDate: DateTime.now(),
      period: 'Eylül 2026',
      totalLessons: 8,
      totalHours: 12,
      topicProgress: const [
        TopicProgress(
          topic: 'Türev ve Uygulamaları',
          lessonsCount: 4,
          level: 'İleri',
          proficiency: 0.90,
        ),
        TopicProgress(
          topic: 'İntegral',
          lessonsCount: 4,
          level: 'Orta',
          proficiency: 0.75,
        ),
      ],
      overallFeedback: 'Derin bu ay derslerde çok başarılı bir performans sergiledi.',
      strengths: const ['Problem çözme hızı', 'Düzenli ödev yapma'],
      areasForImprovement: const ['Zaman yönetimi'],
      averageScore: 90.0,
      reportType: 'progress_report',
      certificateId: 'DHB-RAP-2026-0901',
      title: 'Eylül 2026 Gelişim Raporu',
    );

    final testCertificate = StudentReport(
      id: 'cert-test-1',
      teacherId: 't1',
      studentId: 's1',
      studentName: 'Derin Aksoy',
      teacherName: 'Saliha Öğretmen',
      reportDate: DateTime.now(),
      period: 'Yaz Dönemi 2026',
      totalLessons: 16,
      totalHours: 24,
      topicProgress: const [],
      overallFeedback: 'AYT Matematik Hızlandırma Programını başarıyla tamamladı.',
      strengths: const [],
      areasForImprovement: const [],
      reportType: 'certificate',
      certificateId: 'DHB-CERT-2026-0901',
      title: 'AYT Matematik Başarı Sertifikası',
    );

    test('StudentReport toMap ve fromMap serialization çalışmalı', () {
      final map = testReport.toMap();
      final fromMap = StudentReport.fromMap(map, 'rep-test-1');

      expect(fromMap.id, equals('rep-test-1'));
      expect(fromMap.studentName, equals('Derin Aksoy'));
      expect(fromMap.topicProgress.length, equals(2));
      expect(fromMap.topicProgress.first.level, equals('İleri'));
    });

    test('İlerleme Raporu PDF oluşturma byte üretmeli', () async {
      final bytes = await PdfGeneratorService.generateProgressReportPdf(
        testReport,
        student: testStudent,
      );

      expect(bytes, isNotEmpty);
      expect(bytes.length, greaterThan(1000));
    });

    test('Başarı Sertifikası PDF oluşturma byte üretmeli', () async {
      final bytes = await PdfGeneratorService.generateCertificatePdf(
        testCertificate,
        student: testStudent,
      );

      expect(bytes, isNotEmpty);
      expect(bytes.length, greaterThan(1000));
    });
  });
}
