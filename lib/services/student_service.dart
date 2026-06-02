import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/student.dart';
import 'firestore_service.dart';

// Öğrenci servisindeki global loading durumunu takip eden provider.
final studentServiceLoadingProvider = StateProvider<bool>((ref) => false);
// Öğrenci servisindeki hata mesajlarını saklayan provider.
final studentServiceErrorProvider = StateProvider<String?>((ref) => null);
// StudentService sağlayıcısı. FirestoreService üzerinden öğrenci CRUD işlemlerini yapar.
final studentServiceProvider = Provider<StudentService>((ref) {
  return StudentService(ref.watch(firestoreServiceProvider), ref);
});

class StudentService {
  static const String collectionName = 'students';

  final FirestoreService _firestoreService;
  final Ref _ref;

  StudentService(this._firestoreService, this._ref);

  Future<Student> addStudent(Student student) async {
    _ref.read(studentServiceLoadingProvider.notifier).state = true;
    _ref.read(studentServiceErrorProvider.notifier).state = null;
    try {
      final payload = student.toJson()..remove('id');
      return await _firestoreService.create<Student>(
        collectionName,
        payload,
        Student.fromJson,
      );
    } catch (e) {
      _ref.read(studentServiceErrorProvider.notifier).state = e.toString();
      rethrow;
    } finally {
      _ref.read(studentServiceLoadingProvider.notifier).state = false;
    }
  }

  Future<List<Student>> getStudents(String teacherId) async {
    _ref.read(studentServiceLoadingProvider.notifier).state = true;
    _ref.read(studentServiceErrorProvider.notifier).state = null;
    try {
      return await _firestoreService.query<Student>(
        collectionName,
        Student.fromJson,
        filters: {'teacherId': teacherId},
      );
    } catch (e) {
      _ref.read(studentServiceErrorProvider.notifier).state = e.toString();
      rethrow;
    } finally {
      _ref.read(studentServiceLoadingProvider.notifier).state = false;
    }
  }

  Future<Student> updateStudent(Student student) async {
    _ref.read(studentServiceLoadingProvider.notifier).state = true;
    _ref.read(studentServiceErrorProvider.notifier).state = null;
    try {
      final payload = student.toJson()..remove('id');
      return await _firestoreService.update<Student>(
        collectionName,
        student.id,
        payload,
        Student.fromJson,
      );
    } catch (e) {
      _ref.read(studentServiceErrorProvider.notifier).state = e.toString();
      rethrow;
    } finally {
      _ref.read(studentServiceLoadingProvider.notifier).state = false;
    }
  }

  Future<void> deleteStudent(String studentId) async {
    _ref.read(studentServiceLoadingProvider.notifier).state = true;
    _ref.read(studentServiceErrorProvider.notifier).state = null;
    try {
      await _firestoreService.delete(collectionName, studentId);
    } catch (e) {
      _ref.read(studentServiceErrorProvider.notifier).state = e.toString();
      rethrow;
    } finally {
      _ref.read(studentServiceLoadingProvider.notifier).state = false;
    }
  }

  Future<Student> getStudentById(String studentId) async {
    _ref.read(studentServiceLoadingProvider.notifier).state = true;
    _ref.read(studentServiceErrorProvider.notifier).state = null;
    try {
      return await _firestoreService.read<Student>(
        collectionName,
        studentId,
        Student.fromJson,
      );
    } catch (e) {
      _ref.read(studentServiceErrorProvider.notifier).state = e.toString();
      rethrow;
    } finally {
      _ref.read(studentServiceLoadingProvider.notifier).state = false;
    }
  }
}
