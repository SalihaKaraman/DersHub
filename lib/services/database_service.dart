import 'dart:async';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart' as fb;
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/student.dart';
import '../models/lesson.dart';
import '../models/lesson_status.dart';
import '../models/fee_policy.dart';
import '../models/payment.dart';
import '../models/note.dart';
import 'auth_service.dart';
import 'notification_service.dart';
import 'settings_service.dart';

final databaseServiceProvider = Provider<DatabaseService>((ref) {
  return DatabaseService(ref);
});

// Stream Providers for Features
final studentsStreamProvider = StreamProvider<List<Student>>((ref) {
  return ref.watch(databaseServiceProvider).getStudentsStream();
});

final lessonsStreamProvider = StreamProvider<List<Lesson>>((ref) {
  return ref.watch(databaseServiceProvider).getLessonsStream();
});

final paymentsStreamProvider = StreamProvider<List<Payment>>((ref) {
  return ref.watch(databaseServiceProvider).getPaymentsStream();
});

final notesStreamProvider = StreamProvider<List<Note>>((ref) {
  return ref.watch(databaseServiceProvider).getNotesStream();
});

final feePolicyStreamProvider = StreamProvider<FeePolicy>((ref) {
  return ref.watch(databaseServiceProvider).getFeePolicyStream();
});

class DatabaseService {
  final Ref _ref;
  final AuthService _authService;
  final FirebaseFirestore? _firestore;
  bool _useMockMode = false;

  // Reactivity for Mock mode
  final StreamController<List<Student>> _studentsController =
      StreamController<List<Student>>.broadcast();
  final StreamController<List<Lesson>> _lessonsController =
      StreamController<List<Lesson>>.broadcast();
  final StreamController<List<Payment>> _paymentsController =
      StreamController<List<Payment>>.broadcast();
  final StreamController<List<Note>> _notesController =
      StreamController<List<Note>>.broadcast();
  final StreamController<FeePolicy> _feePolicyController =
      StreamController<FeePolicy>.broadcast();

  // In-memory collections for mock mode
  final List<Student> _mockStudents = [];
  final List<Lesson> _mockLessons = [];
  final List<Payment> _mockPayments = [];
  final List<Note> _mockNotes = [];
  FeePolicy _mockFeePolicy = const FeePolicy();

  DatabaseService(this._ref)
      : _authService = _ref.watch(authServiceProvider),
        _firestore = _initFirestore() {
    if (_firestore == null || _authService.isMockMode) {
      _useMockMode = true;
      _populateMockData();

      // Configure onListen callbacks to ensure subscribers receive the loaded mock collections immediately
      _studentsController.onListen = () {
        _studentsController.add(List.unmodifiable(_mockStudents));
      };
      _lessonsController.onListen = () {
        _lessonsController.add(List.unmodifiable(_mockLessons));
      };
      _paymentsController.onListen = () {
        _paymentsController.add(List.unmodifiable(_mockPayments));
      };
      _notesController.onListen = () {
        _notesController.add(List.unmodifiable(_mockNotes));
      };
      _feePolicyController.onListen = () {
        _feePolicyController.add(_mockFeePolicy);
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

  /// Firebase Auth'tan doğrudan UID okur. _authService.getCurrentUser() gibi
  /// async timing sorunlarından bağımsız, her zaman güvenilir şekilde çalışır.
  String get _uid {
    if (_useMockMode) return 'mock_teacher_id';
    final uid = fb.FirebaseAuth.instance.currentUser?.uid;
    if (uid == null || uid.isEmpty) return 'default';
    return uid;
  }

  void _populateMockData() {
    // 1. Prepopulate Mock Students
    final now = DateTime.now();
    _mockStudents.addAll([
      Student(
        id: 's1',
        teacherId: 't1',
        nickname: 'Derin Aksoy',
        gradeLevel: '12. Sınıf',
        subject: 'Matematik (Ayt)',
        hourlyRate: 800,
        isActive: true,
        createdAt: now.subtract(const Duration(days: 30)),
      ),
      Student(
        id: 's2',
        teacherId: 't1',
        nickname: 'Mert Kaya',
        gradeLevel: '8. Sınıf',
        subject: 'LGS Fen Bilgisi',
        hourlyRate: 600,
        isActive: true,
        createdAt: now.subtract(const Duration(days: 20)),
      ),
      Student(
        id: 's3',
        teacherId: 't1',
        nickname: 'Selin Şahin',
        gradeLevel: '11. Sınıf',
        subject: 'TYT Fizik',
        hourlyRate: 900,
        isActive: true,
        createdAt: now.subtract(const Duration(days: 15)),
      ),
      Student(
        id: 's4',
        teacherId: 't1',
        nickname: 'Efe Yılmaz',
        gradeLevel: '10. Sınıf',
        subject: 'Geometri',
        hourlyRate: 750,
        isActive: true,
        createdAt: now.subtract(const Duration(days: 10)),
      ),
    ]);

    // 2. Prepopulate Mock Lessons
    _mockLessons.addAll([
      Lesson(
        id: 'l1',
        teacherId: 't1',
        studentId: 's1',
        studentName: 'Derin Aksoy',
        dateTime: DateTime(now.year, now.month, now.day, 16, 0),
        durationMinutes: 90,
        price: 1200,
        topic: 'Limit ve Süreklilik',
        status: 'scheduled',
        createdAt: now.subtract(const Duration(days: 31)),
      ),
      Lesson(
        id: 'l2',
        teacherId: 't1',
        studentId: 's3',
        studentName: 'Selin Şahin',
        dateTime: now.subtract(const Duration(days: 1, hours: 2)),
        durationMinutes: 60,
        price: 900,
        topic: 'Newtonun Hareket Yasaları',
        status: 'completed',
        createdAt: now.subtract(const Duration(days: 16)),
      ),
      Lesson(
        id: 'l3',
        teacherId: 't1',
        studentId: 's2',
        studentName: 'Mert Kaya',
        dateTime: now.add(const Duration(days: 1, hours: 4)),
        durationMinutes: 60,
        price: 600,
        topic: 'DNA ve Genetik Kod',
        status: 'scheduled',
        createdAt: now.subtract(const Duration(days: 10)),
      ),
    ]);

    // 3. Prepopulate Mock Payments
    _mockPayments.addAll([
      Payment(
        id: 'p1',
        teacherId: 't1',
        studentId: 's1',
        studentName: 'Derin Aksoy',
        amount: 2400,
        dueDate: now.subtract(const Duration(days: 2)),
        paymentDate: now.subtract(const Duration(days: 2)),
        status: 'paid',
      ),
      Payment(
        id: 'p2',
        teacherId: 't1',
        studentId: 's3',
        studentName: 'Selin Şahin',
        amount: 900,
        dueDate: now.add(const Duration(days: 2)),
        status: 'pending',
      ),
      Payment(
        id: 'p3',
        teacherId: 't1',
        studentId: 's4',
        studentName: 'Efe Yılmaz',
        amount: 1500,
        dueDate: now.subtract(const Duration(days: 5)),
        status: 'overdue',
      ),
    ]);

    // 4. Prepopulate Mock Notes
    _mockNotes.addAll([
      Note(
        id: 'n1',
        title: 'Derin Aksoy - Ödev Takibi',
        content:
            'Logaritma konusuyla alakalı test kitabı 3. bölümdeki 50 soru çözülecek. Limit konusuna giriş yapılacak.',
        studentId: 's1',
        studentName: 'Derin Aksoy',
        createdAt: now.subtract(const Duration(days: 3)),
        colorValue: 0xFF4F46E5, // Premium Indigo
      ),
      Note(
        id: 'n2',
        title: 'Yazılı Hazırlık Takvimi',
        content:
            'Okul yazılıları Haziran ilk haftası başlıyor. Öğrencilerin çalışma programlarını buna göre güncellemeli.',
        createdAt: now.subtract(const Duration(days: 1)),
        colorValue: 0xFF0D9488, // Emerald Teal
      ),
      Note(
        id: 'n3',
        title: 'Mert Kaya - Fen Gelişimi',
        content:
            'Mert\'in kalıtım konusundaki eksikleri kapandı, basınç ünitesiyle devam edeceğiz.',
        studentId: 's2',
        studentName: 'Mert Kaya',
        createdAt: now.subtract(const Duration(days: 5)),
        colorValue: 0xFFF59E0B, // Amber Yellow
      ),
    ]);

    // Trigger initial streams
    _notifyAll();
  }

  void _notifyAll() {
    _studentsController.add(List.unmodifiable(_mockStudents));
    _lessonsController.add(List.unmodifiable(_mockLessons));
    _paymentsController.add(List.unmodifiable(_mockPayments));
    _notesController.add(List.unmodifiable(_mockNotes));
    _feePolicyController.add(_mockFeePolicy);
  }

  // --- Reactive Streams API ---

  Stream<List<Student>> getStudentsStream() {
    if (_useMockMode) {
      return _studentsController.stream;
    } else {
      return _firestore!
          .collection('teachers')
          .doc(_uid)
          .collection('students')
          .snapshots()
          .map((snapshot) {
        final list = snapshot.docs
            .map((doc) => Student.fromMap(doc.data(), doc.id))
            .toList();
        // Sort client-side to avoid Firestore index requirements
        list.sort((a, b) => b.createdAt.compareTo(a.createdAt));
        return list;
      });
    }
  }

  Stream<List<Lesson>> getLessonsStream() {
    if (_useMockMode) {
      return _lessonsController.stream;
    } else {
      return _firestore!
          .collection('teachers')
          .doc(_uid)
          .collection('lessons')
          .snapshots()
          .map((snapshot) {
        final list = snapshot.docs
            .map((doc) {
              try {
                return Lesson.fromMap(doc.data(), doc.id);
              } catch (e) {
                return null;
              }
            })
            .whereType<Lesson>()
            .toList();
        // Sort client-side to avoid Firestore index requirements
        list.sort((a, b) => a.dateTime.compareTo(b.dateTime));
        return list;
      });
    }
  }

  Stream<List<Payment>> getPaymentsStream() {
    if (_useMockMode) {
      return _paymentsController.stream;
    } else {
      return _firestore!
          .collection('teachers')
          .doc(_uid)
          .collection('payments')
          .snapshots()
          .map((snapshot) {
        final list = snapshot.docs
            .map((doc) {
              try {
                return Payment.fromMap(doc.data(), doc.id);
              } catch (e) {
                return null;
              }
            })
            .whereType<Payment>()
            .toList();
        // Sort client-side to avoid Firestore index requirements
        list.sort((a, b) => b.dueDate.compareTo(a.dueDate));
        return list;
      });
    }
  }

  Stream<List<Note>> getNotesStream() {
    if (_useMockMode) {
      return _notesController.stream;
    } else {
      return _firestore!
          .collection('teachers')
          .doc(_uid)
          .collection('notes')
          .snapshots()
          .map((snapshot) {
        final list = snapshot.docs
            .map((doc) {
              try {
                return Note.fromMap(doc.data(), doc.id);
              } catch (e) {
                return null;
              }
            })
            .whereType<Note>()
            .toList();
        // Sort client-side to avoid Firestore index requirements
        list.sort((a, b) => b.createdAt.compareTo(a.createdAt));
        return list;
      });
    }
  }

  Stream<FeePolicy> getFeePolicyStream() {
    if (_useMockMode) {
      return _feePolicyController.stream;
    } else {
      return _firestore!
          .collection('teachers')
          .doc(_uid)
          .collection('settings')
          .doc('fee_policy')
          .snapshots()
          .map((snapshot) {
        if (!snapshot.exists || snapshot.data() == null) {
          return const FeePolicy();
        }
        try {
          return FeePolicy.fromJson(snapshot.data()!);
        } catch (_) {
          return const FeePolicy();
        }
      });
    }
  }

  FeePolicy get currentFeePolicy => _mockFeePolicy;

  Future<void> updateFeePolicy(FeePolicy policy) async {
    _mockFeePolicy = policy;
    _feePolicyController.add(_mockFeePolicy);
    if (!_useMockMode && _firestore != null) {
      await _firestore
          .collection('teachers')
          .doc(_uid)
          .collection('settings')
          .doc('fee_policy')
          .set(policy.toJson());
    }
  }

  FeeCalculationResult calculateLessonFee({
    required Lesson lesson,
    required LessonStatus newStatus,
    Student? student,
    FeePolicy? explicitPolicy,
    DateTime? statusUpdatedAt,
  }) {
    final policy = explicitPolicy ??
        student?.resolvePolicy(_mockFeePolicy) ??
        _mockFeePolicy;
    return policy.calculateCharge(
      lessonPrice: lesson.price,
      lessonDateTime: lesson.dateTime,
      status: newStatus,
      statusUpdatedAt: statusUpdatedAt ?? DateTime.now(),
    );
  }

  // --- Mutations (Add / Edit / Delete) ---

  // STUDENTS
  Future<Student> addStudent(Student student) async {
    if (_useMockMode) {
      final newStudent = student.copyWith(
        id: 's_${DateTime.now().millisecondsSinceEpoch}',
      );
      _mockStudents.insert(0, newStudent);
      _studentsController.add(List.from(_mockStudents));
      if (_ref.read(notificationsEnabledProvider)) {
        await _ref
            .read(notificationServiceProvider)
            .sendWelcomeNotification(studentName: student.nickname);
      }
      return newStudent;
    } else {
      final studentRef = await _firestore!
          .collection('teachers')
          .doc(_uid)
          .collection('students')
          .add(student.toMap());
      if (_ref.read(notificationsEnabledProvider)) {
        await _ref
            .read(notificationServiceProvider)
            .sendWelcomeNotification(studentName: student.nickname);
      }
      return student.copyWith(id: studentRef.id);
    }
  }

  Future<void> deleteStudent(String studentId) async {
    if (_useMockMode) {
      _mockStudents.removeWhere((student) => student.id == studentId);
      _studentsController.add(List.from(_mockStudents));
    } else {
      await _firestore!
          .collection('teachers')
          .doc(_uid)
          .collection('students')
          .doc(studentId)
          .delete();
    }
  }

  Future<void> updateStudent(Student student) async {
    if (_useMockMode) {
      final index = _mockStudents.indexWhere((s) => s.id == student.id);
      if (index != -1) {
        _mockStudents[index] = student;
        _studentsController.add(List.from(_mockStudents));
      }
    } else {
      await _firestore!
          .collection('teachers')
          .doc(_uid)
          .collection('students')
          .doc(student.id)
          .update(student.toMap());
    }
  }

  // LESSONS
  Future<void> addLesson(Lesson lesson) async {
    if (_useMockMode) {
      final newLesson = lesson.copyWith(
        id: 'l_${DateTime.now().millisecondsSinceEpoch}',
      );
      _mockLessons.add(newLesson);
      // Sort lessons chronologically
      _mockLessons.sort((a, b) => a.dateTime.compareTo(b.dateTime));
      _lessonsController.add(List.from(_mockLessons));

      // Auto-generate a pending payment record for that lesson!
      final newPayment = Payment(
        id: 'p_${DateTime.now().millisecondsSinceEpoch}',
        teacherId: lesson.teacherId,
        studentId: lesson.studentId,
        studentName: lesson.studentName,
        lessonId: lesson.id,
        amount: lesson.price,
        dueDate: lesson.dateTime,
        status: 'pending',
      );
      _mockPayments.insert(0, newPayment);
      _paymentsController.add(List.from(_mockPayments));
      if (_ref.read(notificationsEnabledProvider)) {
        await _ref.read(notificationServiceProvider).schedulePaymentReminder(
              dateTime: lesson.dateTime,
              studentName: lesson.studentName,
            );
      }
    } else {
      // Write lesson to Firestore
      final lessonRef = await _firestore!
          .collection('teachers')
          .doc(_uid)
          .collection('lessons')
          .add(lesson.toMap());

      // Auto-generate payment in firestore using the actual lesson ID
      final payment = Payment(
        id: '',
        teacherId: lesson.teacherId,
        studentId: lesson.studentId,
        studentName: lesson.studentName,
        lessonId: lessonRef.id,
        amount: lesson.price,
        dueDate: lesson.dateTime,
        status: 'pending',
      );
      await _firestore
          .collection('teachers')
          .doc(_uid)
          .collection('payments')
          .add(payment.toMap());
      if (_ref.read(notificationsEnabledProvider)) {
        await _ref.read(notificationServiceProvider).schedulePaymentReminder(
              dateTime: lesson.dateTime,
              studentName: lesson.studentName,
            );
      }
    }
  }

  Future<void> updateLessonStatus({
    required String lessonId,
    required LessonStatus newStatus,
    String? reason,
    DateTime? statusUpdatedAt,
    FeePolicy? explicitPolicy,
  }) async {
    final updatedAt = statusUpdatedAt ?? DateTime.now();

    if (_useMockMode) {
      final index = _mockLessons.indexWhere((l) => l.id == lessonId);
      if (index != -1) {
        final lesson = _mockLessons[index];
        final student = _mockStudents.cast<Student?>().firstWhere(
              (s) => s?.id == lesson.studentId,
              orElse: () => null,
            );
        final effectivePolicy = explicitPolicy ??
            (student != null &&
                    student.useCustomFeePolicy &&
                    student.customFeePolicy != null
                ? student.customFeePolicy!
                : _mockFeePolicy);
        final feeResult = effectivePolicy.calculateCharge(
          lessonPrice: lesson.price,
          lessonDateTime: lesson.dateTime,
          status: newStatus,
          statusUpdatedAt: updatedAt,
        );

        _mockLessons[index] = lesson.copyWith(
          status: newStatus.name,
          isCompleted: newStatus == LessonStatus.completed,
          statusUpdatedAt: updatedAt,
          cancellationReason: reason,
          calculatedCharge: feeResult.calculatedCharge,
          chargePercentage: feeResult.chargePercentage,
          createsCompensation: feeResult.createsCompensation,
        );
        _lessonsController.add(List.from(_mockLessons));

        // FAZ 2: Öğretmen iptal → telafi hakkı otomatik oluştur
        if (feeResult.createsCompensation && lesson.studentId.isNotEmpty) {
          await incrementCompensationCount(lesson.studentId);
        }
      }
    } else {
      final lessonDoc = await _firestore!
          .collection('teachers')
          .doc(_uid)
          .collection('lessons')
          .doc(lessonId)
          .get();

      if (lessonDoc.exists && lessonDoc.data() != null) {
        final lesson = Lesson.fromMap(lessonDoc.data()!, lessonDoc.id);
        FeePolicy policy = explicitPolicy ?? const FeePolicy();

        if (explicitPolicy == null) {
          try {
            final studentDoc = await _firestore
                .collection('teachers')
                .doc(_uid)
                .collection('students')
                .doc(lesson.studentId)
                .get();

            FeePolicy globalPolicy = const FeePolicy();
            final policyDoc = await _firestore
                .collection('teachers')
                .doc(_uid)
                .collection('settings')
                .doc('fee_policy')
                .get();
            if (policyDoc.exists && policyDoc.data() != null) {
              globalPolicy = FeePolicy.fromJson(policyDoc.data()!);
            }

            if (studentDoc.exists && studentDoc.data() != null) {
              final student =
                  Student.fromMap(studentDoc.data()!, studentDoc.id);
              policy = student.resolvePolicy(globalPolicy);
            } else {
              policy = globalPolicy;
            }
          } catch (_) {
            policy = const FeePolicy();
          }
        }

        final feeResult = policy.calculateCharge(
          lessonPrice: lesson.price,
          lessonDateTime: lesson.dateTime,
          status: newStatus,
          statusUpdatedAt: updatedAt,
        );

        await _firestore
            .collection('teachers')
            .doc(_uid)
            .collection('lessons')
            .doc(lessonId)
            .update({
          'status': newStatus.name,
          'isCompleted': newStatus == LessonStatus.completed,
          'statusUpdatedAt': updatedAt.toIso8601String(),
          'cancellationReason': reason,
          'calculatedCharge': feeResult.calculatedCharge,
          'chargePercentage': feeResult.chargePercentage,
          'createsCompensation': feeResult.createsCompensation,
        });

        // FAZ 2: Öğretmen iptal → telafi hakkı otomatik oluştur
        if (feeResult.createsCompensation && lesson.studentId.isNotEmpty) {
          await incrementCompensationCount(lesson.studentId);
        }
      }
    }
  }

  /// FAZ 2: Orijinal dersi 'rescheduled' yapıp yeni ders oluşturur.
  /// İki ders birbirine [rescheduleFromLessonId] / [rescheduleToLessonId] ile bağlanır.
  Future<Lesson> rescheduleLesson({
    required String originalLessonId,
    required DateTime newDateTime,
    String? reason,
    FeePolicy? explicitPolicy,
  }) async {
    final now = DateTime.now();

    if (_useMockMode) {
      final index = _mockLessons.indexWhere((l) => l.id == originalLessonId);
      if (index == -1) throw Exception('Ders bulunamadı: $originalLessonId');

      final original = _mockLessons[index];

      // Yeni dersin ID'si
      final newId = 'l_rescheduled_${now.millisecondsSinceEpoch}';

      // Orijinali 'rescheduled' durumuna çek ve yeni derse bağla
      _mockLessons[index] = original.copyWith(
        status: LessonStatus.rescheduled.name,
        isCompleted: false,
        statusUpdatedAt: now,
        cancellationReason: reason,
        rescheduleToLessonId: newId,
      );

      // Yeni ders
      final newLesson = original.copyWith(
        id: newId,
        dateTime: newDateTime,
        status: LessonStatus.scheduled.name,
        isCompleted: false,
        statusUpdatedAt: null,
        cancellationReason: null,
        calculatedCharge: null,
        chargePercentage: null,
        createsCompensation: false,
        rescheduleFromLessonId: originalLessonId,
        rescheduleToLessonId: null,
        isCompensation: false,
        compensationForLessonId: null,
        createdAt: now,
      );
      _mockLessons.add(newLesson);
      _mockLessons.sort((a, b) => a.dateTime.compareTo(b.dateTime));
      _lessonsController.add(List.from(_mockLessons));
      return newLesson;
    } else {
      final lessonDoc = await _firestore!
          .collection('teachers')
          .doc(_uid)
          .collection('lessons')
          .doc(originalLessonId)
          .get();

      if (!lessonDoc.exists || lessonDoc.data() == null) {
        throw Exception('Ders bulunamadı: $originalLessonId');
      }

      final original = Lesson.fromMap(lessonDoc.data()!, lessonDoc.id);

      // Yeni ders referansı (önce oluşturup ID alalım)
      final newRef = _firestore!
          .collection('teachers')
          .doc(_uid)
          .collection('lessons')
          .doc();

      final newLesson = original.copyWith(
        id: newRef.id,
        dateTime: newDateTime,
        status: LessonStatus.scheduled.name,
        isCompleted: false,
        statusUpdatedAt: null,
        cancellationReason: null,
        calculatedCharge: null,
        chargePercentage: null,
        createsCompensation: false,
        rescheduleFromLessonId: originalLessonId,
        rescheduleToLessonId: null,
        isCompensation: false,
        compensationForLessonId: null,
        createdAt: now,
      );

      // Batch write
      final batch = _firestore!.batch();
      batch.update(
        _firestore!
            .collection('teachers')
            .doc(_uid)
            .collection('lessons')
            .doc(originalLessonId),
        {
          'status': LessonStatus.rescheduled.name,
          'isCompleted': false,
          'statusUpdatedAt': now.toIso8601String(),
          'cancellationReason': reason,
          'rescheduleToLessonId': newRef.id,
        },
      );
      final newMap = newLesson.toMap();
      newMap['id'] = newRef.id; // toMap() removes id, re-add for doc set
      batch.set(newRef, newLesson.toMap());
      await batch.commit();
      return newLesson;
    }
  }

  /// FAZ 2: Öğrencinin bekleyen telafi sayısını 1 artırır.
  Future<void> incrementCompensationCount(String studentId) async {
    if (_useMockMode) {
      final index = _mockStudents.indexWhere((s) => s.id == studentId);
      if (index != -1) {
        _mockStudents[index] = _mockStudents[index].copyWith(
          pendingCompensationCount:
              _mockStudents[index].pendingCompensationCount + 1,
        );
        _studentsController.add(List.from(_mockStudents));
      }
    } else {
      await _firestore!
          .collection('teachers')
          .doc(_uid)
          .collection('students')
          .doc(studentId)
          .update({
        'pendingCompensationCount': FieldValue.increment(1),
      });
    }
  }

  /// FAZ 2: Telafi dersini gerçek derse dönüştürür; pendingCompensationCount'u azaltır.
  Future<Lesson> createCompensationLesson({
    required Student student,
    required String teacherId,
    required DateTime dateTime,
    int durationMinutes = 60,
    String? compensationForLessonId,
  }) async {
    final now = DateTime.now();

    final compensationLesson = Lesson(
      id: '',
      teacherId: teacherId,
      studentId: student.id,
      studentName: student.nickname,
      dateTime: dateTime,
      durationMinutes: durationMinutes,
      price: 0, // Telafi ücretsiz
      topic: 'Telafi Dersi',
      status: LessonStatus.scheduled.name,
      isCompleted: false,
      notes: '',
      createdAt: now,
      isCompensation: true,
      compensationForLessonId: compensationForLessonId,
    );

    if (_useMockMode) {
      final newId = 'l_comp_${now.millisecondsSinceEpoch}';
      final created = compensationLesson.copyWith(id: newId);
      _mockLessons.add(created);
      _mockLessons.sort((a, b) => a.dateTime.compareTo(b.dateTime));
      _lessonsController.add(List.from(_mockLessons));

      // Telafi sayısını azalt
      final idx = _mockStudents.indexWhere((s) => s.id == student.id);
      if (idx != -1) {
        final current = _mockStudents[idx].pendingCompensationCount;
        _mockStudents[idx] = _mockStudents[idx].copyWith(
          pendingCompensationCount: (current - 1).clamp(0, 999),
        );
        _studentsController.add(List.from(_mockStudents));
      }
      return created;
    } else {
      final lessonRef = await _firestore!
          .collection('teachers')
          .doc(_uid)
          .collection('lessons')
          .add(compensationLesson.toMap());

      // Telafi sayısını azalt
      await _firestore!
          .collection('teachers')
          .doc(_uid)
          .collection('students')
          .doc(student.id)
          .update({
        'pendingCompensationCount': FieldValue.increment(-1),
      });

      return compensationLesson.copyWith(id: lessonRef.id);
    }
  }

  Future<void> updateLessonCompletion(String lessonId, bool completed) async {
    await updateLessonStatus(
      lessonId: lessonId,
      newStatus: completed ? LessonStatus.completed : LessonStatus.scheduled,
    );
  }

  Future<void> deleteLesson(String lessonId) async {
    if (_useMockMode) {
      _mockLessons.removeWhere((l) => l.id == lessonId);
      _lessonsController.add(List.from(_mockLessons));
    } else {
      await _firestore!
          .collection('teachers')
          .doc(_uid)
          .collection('lessons')
          .doc(lessonId)
          .delete();
    }
  }

  // PAYMENTS
  Future<void> addPayment(Payment payment) async {
    if (_useMockMode) {
      final newPayment = payment.copyWith(
        id: 'p_${DateTime.now().millisecondsSinceEpoch}',
      );
      _mockPayments.insert(0, newPayment);
      _paymentsController.add(List.from(_mockPayments));
    } else {
      await _firestore!
          .collection('teachers')
          .doc(_uid)
          .collection('payments')
          .add(payment.toMap());
    }
  }

  Future<void> updatePayment(Payment payment) async {
    if (_useMockMode) {
      final index = _mockPayments.indexWhere((p) => p.id == payment.id);
      if (index != -1) {
        _mockPayments[index] = payment;
        _paymentsController.add(List.from(_mockPayments));
      }
    } else {
      await _firestore!
          .collection('teachers')
          .doc(_uid)
          .collection('payments')
          .doc(payment.id)
          .update(payment.toMap());
    }
  }

  Future<void> markPaymentAsPaid(String paymentId) async {
    if (_useMockMode) {
      final index = _mockPayments.indexWhere((p) => p.id == paymentId);
      if (index != -1) {
        _mockPayments[index] = _mockPayments[index].copyWith(
          status: 'paid',
          paymentDate: DateTime.now(),
        );
        _paymentsController.add(List.from(_mockPayments));
      }
    } else {
      await _firestore!
          .collection('teachers')
          .doc(_uid)
          .collection('payments')
          .doc(paymentId)
          .update({
        'status': 'paid',
        'paymentDate': DateTime.now().toIso8601String(),
      });
    }
  }

  // NOTES
  Future<void> addNote(Note note) async {
    if (_useMockMode) {
      final newNote = note.copyWith(
        id: 'n_${DateTime.now().millisecondsSinceEpoch}',
      );
      _mockNotes.insert(0, newNote);
      _notesController.add(List.from(_mockNotes));
    } else {
      await _firestore!
          .collection('teachers')
          .doc(_uid)
          .collection('notes')
          .add(note.toMap());
    }
  }

  Future<void> updateNote(Note note) async {
    if (_useMockMode) {
      final index = _mockNotes.indexWhere((n) => n.id == note.id);
      if (index != -1) {
        _mockNotes[index] = note;
        _notesController.add(List.from(_mockNotes));
      }
    } else {
      await _firestore!
          .collection('teachers')
          .doc(_uid)
          .collection('notes')
          .doc(note.id)
          .update(note.toMap());
    }
  }

  Future<void> deleteNote(String noteId) async {
    if (_useMockMode) {
      _mockNotes.removeWhere((n) => n.id == noteId);
      _notesController.add(List.from(_mockNotes));
    } else {
      await _firestore!
          .collection('teachers')
          .doc(_uid)
          .collection('notes')
          .doc(noteId)
          .delete();
    }
  }
}
