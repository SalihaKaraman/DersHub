import 'dart:async';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart' as fb;
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/group_lesson.dart';
import 'auth_service.dart';

final groupLessonServiceProvider = Provider<GroupLessonService>((ref) {
  return GroupLessonService(ref);
});

final groupLessonsStreamProvider = StreamProvider<List<GroupLesson>>((ref) {
  return ref.watch(groupLessonServiceProvider).getGroupLessonsStream();
});

final studentGroupLessonsStreamProvider =
    StreamProvider.family<List<GroupLesson>, String>((ref, studentId) {
  return ref
      .watch(groupLessonServiceProvider)
      .getStudentGroupLessonsStream(studentId);
});

class GroupLessonService {
  final AuthService _authService;
  final FirebaseFirestore? _firestore;
  bool _useMockMode = false;

  final StreamController<List<GroupLesson>> _groupLessonsController =
      StreamController<List<GroupLesson>>.broadcast();
  final List<GroupLesson> _mockGroupLessons = [];

  GroupLessonService(Ref ref)
      : _authService = ref.watch(authServiceProvider),
        _firestore = _initFirestore() {
    if (_firestore == null || _authService.isMockMode) {
      _useMockMode = true;
      _populateMockGroupLessons();
      _groupLessonsController.onListen = () {
        _groupLessonsController.add(List.unmodifiable(_mockGroupLessons));
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

  void _populateMockGroupLessons() {
    final now = DateTime.now();
    _mockGroupLessons.addAll([
      GroupLesson(
        id: 'gl-001',
        teacherId: 'mock_teacher_id',
        groupName: '12-A AYT Matematik Grubu',
        subject: 'Matematik',
        topic: 'Trigonometrik Denklemler Soru Kampı',
        studentIds: const ['s1', 's2'],
        studentNames: const ['Derin Aksoy', 'Mert Kaya'],
        dateTime: DateTime(now.year, now.month, now.day, 16, 30),
        durationMinutes: 90,
        pricePerStudent: 450.0,
        notes: 'ÖSYM çıkmış son 5 yılın trigonometri soruları çözülecek.',
        individualNotes: const [
          GroupLessonNote(
            studentId: 's1',
            studentName: 'Derin Aksoy',
            personalNote: 'Temel kavramlara çok hakim, zor soruları çözdü.',
            attended: true,
            score: 95.0,
          ),
          GroupLessonNote(
            studentId: 's2',
            studentName: 'Mert Kaya',
            personalNote: 'Dönüşüm formüllerini tekrar etmesi gerek.',
            attended: true,
            score: 80.0,
          ),
        ],
        isCompleted: false,
        createdAt: now.subtract(const Duration(days: 2)),
      ),
      GroupLesson(
        id: 'gl-002',
        teacherId: 'mock_teacher_id',
        groupName: 'LGS Fen Etüt Grubu',
        subject: 'Fen Bilimleri',
        topic: 'Mevsimler ve İklim - Grafik Okuma',
        studentIds: const ['s2'],
        studentNames: const ['Mert Kaya'],
        dateTime: DateTime(now.year, now.month, now.day + 1, 14, 0),
        durationMinutes: 60,
        pricePerStudent: 350.0,
        notes: 'Deney soruları ve grafik yorumlama odaklı çalışma.',
        individualNotes: const [
          GroupLessonNote(
            studentId: 's2',
            studentName: 'Mert Kaya',
            personalNote: 'Ödev soruları incelendi.',
            attended: true,
          ),
        ],
        isCompleted: false,
        createdAt: now.subtract(const Duration(days: 1)),
      ),
    ]);
  }

  /// Öğretmenin tüm grup derslerini stream olarak getirir
  Stream<List<GroupLesson>> getGroupLessonsStream() {
    if (_useMockMode || _firestore == null) {
      return _groupLessonsController.stream;
    }

    return _firestore
        .collection('group_lessons')
        .where('teacherId', isEqualTo: _currentTeacherId)
        .orderBy('dateTime', descending: false)
        .snapshots()
        .map((snap) => snap.docs
            .map((doc) => GroupLesson.fromMap(doc.data(), doc.id))
            .toList());
  }

  /// Belirli bir öğrencinin dahil olduğu grup derslerini stream olarak getirir
  Stream<List<GroupLesson>> getStudentGroupLessonsStream(String studentId) {
    if (_useMockMode || _firestore == null) {
      return _groupLessonsController.stream.map(
        (lessons) =>
            lessons.where((gl) => gl.studentIds.contains(studentId)).toList(),
      );
    }

    return _firestore
        .collection('group_lessons')
        .where('studentIds', arrayContains: studentId)
        .orderBy('dateTime', descending: true)
        .snapshots()
        .map((snap) => snap.docs
            .map((doc) => GroupLesson.fromMap(doc.data(), doc.id))
            .toList());
  }

  /// Yeni grup dersi ekler
  Future<GroupLesson> addGroupLesson(GroupLesson lesson) async {
    final lessonToSave = lesson.id.isEmpty
        ? lesson.copyWith(
            id: 'gl-${DateTime.now().millisecondsSinceEpoch}',
            teacherId: lesson.teacherId.isEmpty
                ? _currentTeacherId
                : lesson.teacherId,
            createdAt: DateTime.now(),
          )
        : lesson;

    if (_useMockMode || _firestore == null) {
      _mockGroupLessons.add(lessonToSave);
      _mockGroupLessons.sort((a, b) => a.dateTime.compareTo(b.dateTime));
      _groupLessonsController.add(List.unmodifiable(_mockGroupLessons));
      return lessonToSave;
    }

    await _firestore
        .collection('group_lessons')
        .doc(lessonToSave.id)
        .set(lessonToSave.toMap());

    return lessonToSave;
  }

  /// Grup dersini günceller
  Future<void> updateGroupLesson(GroupLesson lesson) async {
    if (_useMockMode || _firestore == null) {
      final index =
          _mockGroupLessons.indexWhere((l) => l.id == lesson.id);
      if (index >= 0) {
        _mockGroupLessons[index] = lesson;
        _mockGroupLessons.sort((a, b) => a.dateTime.compareTo(b.dateTime));
        _groupLessonsController.add(List.unmodifiable(_mockGroupLessons));
      }
      return;
    }

    await _firestore
        .collection('group_lessons')
        .doc(lesson.id)
        .set(lesson.toMap());
  }

  /// Grup dersini siler
  Future<void> deleteGroupLesson(String id) async {
    if (_useMockMode || _firestore == null) {
      _mockGroupLessons.removeWhere((l) => l.id == id);
      _groupLessonsController.add(List.unmodifiable(_mockGroupLessons));
      return;
    }

    await _firestore.collection('group_lessons').doc(id).delete();
  }

  /// Dersi tamamlandı olarak işaretler veya geri alır
  Future<void> toggleLessonCompletion(String id, bool isCompleted) async {
    if (_useMockMode || _firestore == null) {
      final index = _mockGroupLessons.indexWhere((l) => l.id == id);
      if (index >= 0) {
        _mockGroupLessons[index] =
            _mockGroupLessons[index].copyWith(isCompleted: isCompleted);
        _groupLessonsController.add(List.unmodifiable(_mockGroupLessons));
      }
      return;
    }

    await _firestore
        .collection('group_lessons')
        .doc(id)
        .update({'isCompleted': isCompleted});
  }

  /// Yoklama ve öğrenci özel notlarını günceller
  Future<void> updateAttendanceAndNotes(
    String lessonId,
    List<GroupLessonNote> notes,
  ) async {
    if (_useMockMode || _firestore == null) {
      final index =
          _mockGroupLessons.indexWhere((l) => l.id == lessonId);
      if (index >= 0) {
        _mockGroupLessons[index] =
            _mockGroupLessons[index].copyWith(individualNotes: notes);
        _groupLessonsController.add(List.unmodifiable(_mockGroupLessons));
      }
      return;
    }

    await _firestore.collection('group_lessons').doc(lessonId).update({
      'individualNotes': notes.map((n) => n.toJson()).toList(),
    });
  }
}
