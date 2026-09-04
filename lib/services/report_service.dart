import 'dart:async';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart' as fb;
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import '../models/lesson.dart';
import '../models/report.dart';
import '../models/student.dart';
import 'auth_service.dart';

final reportServiceProvider = Provider<ReportService>((ref) {
  return ReportService(ref);
});

final studentReportsStreamProvider =
    StreamProvider.family<List<StudentReport>, String>((ref, studentId) {
  return ref.watch(reportServiceProvider).getStudentReportsStream(studentId);
});

final teacherReportsStreamProvider = StreamProvider<List<StudentReport>>((ref) {
  return ref.watch(reportServiceProvider).getTeacherReportsStream();
});

class ReportService {
  final AuthService _authService;
  final FirebaseFirestore? _firestore;
  bool _useMockMode = false;

  final StreamController<List<StudentReport>> _reportsController =
      StreamController<List<StudentReport>>.broadcast();
  final List<StudentReport> _mockReports = [];

  ReportService(Ref ref)
      : _authService = ref.watch(authServiceProvider),
        _firestore = _initFirestore() {
    if (_firestore == null || _authService.isMockMode) {
      _useMockMode = true;
      _populateMockReports();
      _reportsController.onListen = () {
        _reportsController.add(List.unmodifiable(_mockReports));
      };
    }
  }

  static FirebaseFirestore? _initFirestore() {
    try {
      return FirebaseFirestore.instance;
    } catch (_) {
      return null;
    }
  }

  String get _currentTeacherId {
    if (_useMockMode) return 'mock_teacher_id';
    final uid = fb.FirebaseAuth.instance.currentUser?.uid;
    return uid ?? 'mock_teacher_id';
  }

  void _populateMockReports() {
    final now = DateTime.now();
    _mockReports.addAll([
      StudentReport(
        id: 'rep-001',
        teacherId: 'mock_teacher_id',
        studentId: 's1',
        studentName: 'Derin Aksoy',
        teacherName: 'Saliha Öğretmen',
        reportDate: now.subtract(const Duration(days: 3)),
        period: 'Ağustos 2026',
        totalLessons: 8,
        totalHours: 12,
        topicProgress: const [
          TopicProgress(
            topic: 'Türev ve Uygulamaları',
            lessonsCount: 4,
            level: 'İleri',
            proficiency: 0.90,
            notes: 'Geometrik yorum sorularında çok başarılı.',
          ),
          TopicProgress(
            topic: 'İntegral ve Alan Hesabı',
            lessonsCount: 3,
            level: 'Orta',
            proficiency: 0.75,
            notes: 'Belirli integral kurallarını pekiştirdi.',
          ),
          TopicProgress(
            topic: 'Limit ve Süreklilik',
            lessonsCount: 1,
            level: 'İleri',
            proficiency: 0.95,
            notes: 'Eksiksiz kavrandı.',
          ),
        ],
        overallFeedback:
            'Derin, bu ay gösterdiği üstün çalışma temposu ve analitik soru çözme yeteneğiyle AYT hedeflerine bir adım daha yaklaştı. Odaklanması mükemmel.',
        strengths: const [
          'Formülleri ezberlemek yerine mantığını kavrama becerisi',
          'Zorlu yeni nesil sorularda sabırlı ve sistematik yaklaşım',
          'Derslere hazırlıklı ve ödevlerini eksiksiz yaparak gelmesi',
        ],
        areasForImprovement: const [
          'İntegralde değişken değiştirme pratiğini artırma',
          'Zaman yönetimi için süreli deneme çözümleri yapma',
        ],
        monthlyLessonCount: const {
          '1. Hafta': 2,
          '2. Hafta': 2,
          '3. Hafta': 2,
          '4. Hafta': 2,
        },
        averageScore: 92.0,
        reportType: 'progress_report',
        certificateId: 'DHB-RAP-2026-0801',
        title: 'Ağustos 2026 İlerleme Raporu',
        createdAt: now.subtract(const Duration(days: 3)),
      ),
      StudentReport(
        id: 'rep-002',
        teacherId: 'mock_teacher_id',
        studentId: 's1',
        studentName: 'Derin Aksoy',
        teacherName: 'Saliha Öğretmen',
        reportDate: now.subtract(const Duration(days: 1)),
        period: 'Yaz Dönemi 2026',
        totalLessons: 16,
        totalHours: 24,
        topicProgress: const [],
        overallFeedback:
            'Yaz Dönemi AYT Matematik Hızlandırma Kampını ve ileri düzey analitik konuları üstün başarı, disiplin ve özveriyle tamamladığı için takdim edilmiştir.',
        strengths: const [],
        areasForImprovement: const [],
        reportType: 'certificate',
        certificateId: 'DHB-CERT-2026-0901',
        title: 'AYT Matematik Başarı Sertifikası',
        createdAt: now.subtract(const Duration(days: 1)),
      ),
      StudentReport(
        id: 'rep-003',
        teacherId: 'mock_teacher_id',
        studentId: 's2',
        studentName: 'Mert Kaya',
        teacherName: 'Saliha Öğretmen',
        reportDate: now.subtract(const Duration(days: 5)),
        period: 'Ağustos 2026',
        totalLessons: 6,
        totalHours: 9,
        topicProgress: const [
          TopicProgress(
            topic: 'Mevsimler ve İklim',
            lessonsCount: 3,
            level: 'İleri',
            proficiency: 0.88,
            notes: 'LGS tarzı grafik ve görsel soruları çözüldü.',
          ),
          TopicProgress(
            topic: 'DNA ve Genetik Kod',
            lessonsCount: 3,
            level: 'Orta',
            proficiency: 0.70,
            notes: 'Çaprazlama konusuna ek tekrar yapılması faydalı olacak.',
          ),
        ],
        overallFeedback:
            'Mert fen bilgisi kavramlarını kavramada istekli. Özellikle görsel sorularda dikkatini koruduğunda netleri hızla yükseliyor.',
        strengths: const [
          'Deney ve modelleme sorularına yüksek ilgi',
          'Derste soru sormaktan çekinmemesi',
        ],
        areasForImprovement: const [
          'Uzun metinli sorularda dikkat hatalarını azaltma',
          'Haftalık konu özetlerini düzenli çıkarma',
        ],
        averageScore: 84.0,
        reportType: 'progress_report',
        certificateId: 'DHB-RAP-2026-0802',
        title: 'Ağustos 2026 Gelişim Raporu',
        createdAt: now.subtract(const Duration(days: 5)),
      ),
    ]);
  }

  /// Öğrenciye ait rapor ve sertifikaları stream olarak getirir
  Stream<List<StudentReport>> getStudentReportsStream(String studentId) {
    if (_useMockMode || _firestore == null) {
      return _reportsController.stream.map(
        (list) => list.where((r) => r.studentId == studentId).toList(),
      );
    }

    return _firestore
        .collection('reports')
        .where('studentId', isEqualTo: studentId)
        .orderBy('reportDate', descending: true)
        .snapshots()
        .map((snap) => snap.docs
            .map((doc) => StudentReport.fromMap(doc.data(), doc.id))
            .toList());
  }

  /// Öğretmene ait tüm raporları stream olarak getirir
  Stream<List<StudentReport>> getTeacherReportsStream() {
    if (_useMockMode || _firestore == null) {
      return _reportsController.stream;
    }

    return _firestore
        .collection('reports')
        .where('teacherId', isEqualTo: _currentTeacherId)
        .orderBy('reportDate', descending: true)
        .snapshots()
        .map((snap) => snap.docs
            .map((doc) => StudentReport.fromMap(doc.data(), doc.id))
            .toList());
  }

  /// Rapor veya sertifikayı kaydeder / günceller
  Future<StudentReport> saveReport(StudentReport report) async {
    final reportToSave = report.id.isEmpty
        ? report.copyWith(
            id: 'rep-${DateTime.now().millisecondsSinceEpoch}',
            teacherId: report.teacherId.isEmpty ? _currentTeacherId : report.teacherId,
            createdAt: DateTime.now(),
          )
        : report;

    if (_useMockMode || _firestore == null) {
      final index = _mockReports.indexWhere((r) => r.id == reportToSave.id);
      if (index >= 0) {
        _mockReports[index] = reportToSave;
      } else {
        _mockReports.insert(0, reportToSave);
      }
      _reportsController.add(List.unmodifiable(_mockReports));
      return reportToSave;
    }

    await _firestore
        .collection('reports')
        .doc(reportToSave.id)
        .set(reportToSave.toMap());

    return reportToSave;
  }

  /// Raporu siler
  Future<void> deleteReport(String reportId) async {
    if (_useMockMode || _firestore == null) {
      _mockReports.removeWhere((r) => r.id == reportId);
      _reportsController.add(List.unmodifiable(_mockReports));
      return;
    }

    await _firestore.collection('reports').doc(reportId).delete();
  }

  /// Öğrencinin geçmiş derslerinden otomatik Aylık Rapor Taslağı üretir
  StudentReport createMonthlyReportDraft({
    required Student student,
    required List<Lesson> lessons,
    required String teacherName,
    DateTime? targetMonth,
  }) {
    final date = targetMonth ?? DateTime.now();
    final periodName = DateFormat('MMMM yyyy', 'tr_TR').format(date);
    final monthLessons = lessons.where((l) {
      return l.dateTime.year == date.year && l.dateTime.month == date.month;
    }).toList();

    // Eğer o aya ait ders yoksa son 30 günün derslerini al
    final effectiveLessons = monthLessons.isNotEmpty
        ? monthLessons
        : lessons.where((l) {
            return l.dateTime.isAfter(date.subtract(const Duration(days: 30)));
          }).toList();

    final totalLessons = effectiveLessons.length;
    final totalMinutes = effectiveLessons.fold<int>(
      0,
      (total, l) => total + l.durationMinutes,
    );
    final totalHours = (totalMinutes / 60).round();

    // Konuları grupla
    final Map<String, int> topicCounts = {};
    for (final l in effectiveLessons) {
      final t = l.topic.trim();
      if (t.isNotEmpty) {
        topicCounts[t] = (topicCounts[t] ?? 0) + 1;
      }
    }

    final topicProgressList = topicCounts.entries.map((entry) {
      final count = entry.value;
      final level = count >= 4
          ? 'İleri'
          : count >= 2
              ? 'Orta'
              : 'Başlangıç';
      final proficiency = (count / 5.0).clamp(0.4, 0.95);
      return TopicProgress(
        topic: entry.key,
        lessonsCount: count,
        level: level,
        proficiency: proficiency,
        notes: '$count ders tamamlandı.',
      );
    }).toList();

    final certId =
        'DHB-RAP-${date.year}${date.month.toString().padLeft(2, '0')}-${student.id.substring(0, student.id.length.clamp(0, 4)).toUpperCase()}';

    return StudentReport(
      id: '',
      teacherId: _currentTeacherId,
      studentId: student.id,
      studentName: student.nickname,
      teacherName: teacherName,
      reportDate: date,
      period: periodName,
      totalLessons: totalLessons > 0 ? totalLessons : 4,
      totalHours: totalHours > 0 ? totalHours : 6,
      topicProgress: topicProgressList.isNotEmpty
          ? topicProgressList
          : [
              TopicProgress(
                topic: student.subject,
                lessonsCount: 4,
                level: 'Orta',
                proficiency: 0.80,
                notes: 'Temel kavramlar çalışıldı.',
              ),
            ],
      overallFeedback:
          'Sayın ${student.nickname}, $periodName döneminde ${student.subject} derslerine düzenli katılım göstermiş ve çalışma disipliniyle hedeflerine doğru istikrarlı bir ilerleme kaydetmiştir.',
      strengths: const [
        'Ders içi aktif katılım ve yüksek soru sorma motivasyonu',
        'Verilen pekiştirme ödevlerinin zamanında teslim edilmesi',
        'Kavramsal konuları hızlı anlama ve analiz becerisi',
      ],
      areasForImprovement: const [
        'Soru çözümlerinde işlem adımlarını daha sistemli yazma',
        'Haftalık konu tekrar saatlerini aksatmadan sürdürme',
      ],
      averageScore: 88.0,
      reportType: 'progress_report',
      certificateId: certId,
      title: '$periodName Gelişim Raporu',
      createdAt: DateTime.now(),
    );
  }

  /// Öğrenci için Başarı Sertifikası taslağı üretir
  StudentReport createCertificateDraft({
    required Student student,
    required String teacherName,
    required String certificateTitle,
    String? customNote,
  }) {
    final now = DateTime.now();
    final certId =
        'DHB-CERT-${now.year}-${student.id.substring(0, student.id.length.clamp(0, 4)).toUpperCase()}-${now.millisecond}';

    return StudentReport(
      id: '',
      teacherId: _currentTeacherId,
      studentId: student.id,
      studentName: student.nickname,
      teacherName: teacherName,
      reportDate: now,
      period: DateFormat('MMMM yyyy', 'tr_TR').format(now),
      totalLessons: 0,
      totalHours: 0,
      topicProgress: const [],
      overallFeedback: customNote ??
          'Sayın ${student.nickname}, ${student.subject} eğitim programında göstermiş olduğu üstün başarı, gayret ve disiplin dolayısıyla bu başarı sertifikasını almaya hak kazanmıştır.',
      strengths: const [],
      areasForImprovement: const [],
      averageScore: 100.0,
      reportType: 'certificate',
      certificateId: certId,
      title: certificateTitle.isNotEmpty
          ? certificateTitle
          : '${student.subject} Başarı Sertifikası',
      createdAt: now,
    );
  }
}
