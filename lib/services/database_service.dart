import 'dart:async';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart' as fb;
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/student.dart';
import '../models/lesson.dart';
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

  // In-memory collections for mock mode
  final List<Student> _mockStudents = [];
  final List<Lesson> _mockLessons = [];
  final List<Payment> _mockPayments = [];
  final List<Note> _mockNotes = [];

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
            final list = snapshot.docs.map((doc) {
              try {
                return Lesson.fromMap(doc.data(), doc.id);
              } catch (e) {
                return null;
              }
            }).whereType<Lesson>().toList();
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
            final list = snapshot.docs.map((doc) {
              try {
                return Payment.fromMap(doc.data(), doc.id);
              } catch (e) {
                return null;
              }
            }).whereType<Payment>().toList();
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
            final list = snapshot.docs.map((doc) {
              try {
                return Note.fromMap(doc.data(), doc.id);
              } catch (e) {
                return null;
              }
            }).whereType<Note>().toList();
            // Sort client-side to avoid Firestore index requirements
            list.sort((a, b) => b.createdAt.compareTo(a.createdAt));
            return list;
          });
    }
  }

  // --- Mutations (Add / Edit / Delete) ---

  // STUDENTS
  Future<void> addStudent(Student student) async {
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
    } else {
      await _firestore!
          .collection('teachers')
          .doc(_uid)
          .collection('students')
          .add(student.toMap());
      if (_ref.read(notificationsEnabledProvider)) {
        await _ref
            .read(notificationServiceProvider)
            .sendWelcomeNotification(studentName: student.nickname);
      }
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
        await _ref
            .read(notificationServiceProvider)
            .schedulePaymentReminder(
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
        await _ref
            .read(notificationServiceProvider)
            .schedulePaymentReminder(
              dateTime: lesson.dateTime,
              studentName: lesson.studentName,
            );
      }
    }
  }

  Future<void> updateLessonStatus(String lessonId, String status) async {
    if (_useMockMode) {
      final index = _mockLessons.indexWhere((l) => l.id == lessonId);
      if (index != -1) {
        _mockLessons[index] = _mockLessons[index].copyWith(status: status);
        _lessonsController.add(List.from(_mockLessons));
      }
    } else {
      await _firestore!
          .collection('teachers')
          .doc(_uid)
          .collection('lessons')
          .doc(lessonId)
          .update({'status': status});
    }
  }

  Future<void> updateLessonCompletion(String lessonId, bool completed) async {
    if (_useMockMode) {
      final index = _mockLessons.indexWhere((l) => l.id == lessonId);
      if (index != -1) {
        _mockLessons[index] = _mockLessons[index].copyWith(
          isCompleted: completed,
        );
        _lessonsController.add(List.from(_mockLessons));
      }
    } else {
      await _firestore!
          .collection('teachers')
          .doc(_uid)
          .collection('lessons')
          .doc(lessonId)
          .update({'isCompleted': completed});
    }
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
