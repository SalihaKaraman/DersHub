import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/student.dart';
import '../models/lesson.dart';
import '../models/parent.dart';
import '../models/app_user.dart';
import 'auth_service.dart';
import 'database_service.dart';

/// Velinin bağlı olduğu öğrencileri ve derslerini yöneten servis.
final parentServiceProvider = Provider<ParentService>((ref) {
  return ParentService(ref);
});

/// Velinin bağlı olduğu öğrencileri stream olarak dinler.
final parentStudentsStreamProvider = StreamProvider<List<Student>>((ref) {
  return ref.watch(parentServiceProvider).getLinkedStudentsStream();
});

/// Belirli bir öğrencinin derslerini stream olarak dinler (veli perspektifi – sadece okunur).
final parentStudentLessonsProvider =
    StreamProvider.family<List<Lesson>, String>((ref, studentId) {
  return ref
      .watch(parentServiceProvider)
      .getStudentLessonsStream(studentId);
});

class ParentService {
  final Ref _ref;
  final FirebaseFirestore? _firestore;

  ParentService(this._ref) : _firestore = _initFirestore();

  static FirebaseFirestore? _initFirestore() {
    try {
      return FirebaseFirestore.instance;
    } catch (_) {
      return null;
    }
  }

  Parent? _getCurrentParent() {
    final AppUser? user = _ref.read(authServiceProvider).getCurrentUser();
    if (user is Parent) return user;
    return null;
  }

  /// Velinin bağlı olduğu öğrencileri döndürür.
  Stream<List<Student>> getLinkedStudentsStream() {
    if (_firestore == null || _ref.read(authServiceProvider).isMockMode) {
      final parent = _getCurrentParent();
      final linkedIds = parent?.linkedStudentIds.isNotEmpty == true
          ? parent!.linkedStudentIds
          : ['s1', 's2'];
      return _ref.watch(databaseServiceProvider).getStudentsStream().map(
            (students) =>
                students.where((s) => linkedIds.contains(s.id)).toList(),
          );
    }

    final parent = _getCurrentParent();
    if (parent == null || parent.linkedStudentIds.isEmpty) {
      return Stream.value([]);
    }

    final db = _firestore;
    return db
        .collection('students')
        .where(FieldPath.documentId, whereIn: parent.linkedStudentIds)
        .snapshots()
        .map((snap) => snap.docs
            .map((doc) => Student.fromMap(doc.data(), doc.id))
            .toList());
  }

  /// Belirli bir öğrencinin derslerini döndürür (READ ONLY).
  Stream<List<Lesson>> getStudentLessonsStream(String studentId) {
    if (_firestore == null || _ref.read(authServiceProvider).isMockMode) {
      return _ref.watch(databaseServiceProvider).getLessonsStream().map(
            (lessons) =>
                lessons.where((l) => l.studentId == studentId).toList(),
          );
    }

    final db = _firestore;
    return db
        .collection('lessons')
        .where('studentId', isEqualTo: studentId)
        .orderBy('dateTime', descending: true)
        .snapshots()
        .map((snap) => snap.docs
            .map((doc) => Lesson.fromMap(doc.data(), doc.id))
            .toList());
  }

  /// Öğrenciye bağlı öğretmenin bilgilerini getirir.
  Future<Map<String, dynamic>?> getTeacherInfo(String teacherId) async {
    if (_firestore == null) {
      return {
        'fullName': 'Saliha Öğretmen',
        'subject': 'Matematik & Fen Bilimleri',
        'email': 'ogretmen@dershub.com',
      };
    }
    try {
      final doc = await _firestore.collection('teachers').doc(teacherId).get();
      return doc.data();
    } catch (_) {
      return null;
    }
  }
}
