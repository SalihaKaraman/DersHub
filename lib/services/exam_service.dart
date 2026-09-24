import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/exam.dart';

final examServiceProvider = Provider<ExamService>((ref) {
  return ExamService();
});

final studentExamsStreamProvider = StreamProvider.family<List<Exam>, String>((ref, studentId) {
  return ref.watch(examServiceProvider).getExamsForStudent(studentId);
});

class ExamService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final String _collection = 'exams';

  // Sınav ekleme
  Future<void> addExam(Exam exam) async {
    final docRef = _firestore.collection(_collection).doc();
    final newExam = exam.copyWith(id: docRef.id);
    await docRef.set(newExam.toMap());
  }

  // Sınav güncelleme
  Future<void> updateExam(Exam exam) async {
    await _firestore.collection(_collection).doc(exam.id).update(exam.toMap());
  }

  // Sınav silme
  Future<void> deleteExam(String examId) async {
    await _firestore.collection(_collection).doc(examId).delete();
  }

  // Bir öğrenciye ait sınavları getirme (Stream)
  Stream<List<Exam>> getExamsForStudent(String studentId) {
    return _firestore
        .collection(_collection)
        .where('studentId', isEqualTo: studentId)
        .orderBy('date', descending: true)
        .snapshots()
        .map((snapshot) {
      return snapshot.docs.map((doc) => Exam.fromMap(doc.data(), doc.id)).toList();
    });
  }
}
