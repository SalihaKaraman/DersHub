import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/lesson.dart';
import 'firestore_service.dart';

// Ders servisindeki loading durumunu yöneten provider.
final lessonServiceLoadingProvider = StateProvider<bool>((ref) => false);
// Ders servisindeki hata durumunu tutan provider.
final lessonServiceErrorProvider = StateProvider<String?>((ref) => null);
// LessonService sağlayıcısı. FirestoreService kullanarak ders CRUD işlemlerini yapar.
final lessonServiceProvider = Provider<LessonService>((ref) {
  return LessonService(ref.watch(firestoreServiceProvider), ref);
});

class LessonService {
  static const String collectionName = 'lessons';

  final FirestoreService _firestoreService;
  final Ref _ref;

  LessonService(this._firestoreService, this._ref);

  Future<Lesson> addLesson(Lesson lesson) async {
    _ref.read(lessonServiceLoadingProvider.notifier).state = true;
    _ref.read(lessonServiceErrorProvider.notifier).state = null;
    try {
      final payload = lesson.toJson()..remove('id');
      return await _firestoreService.create<Lesson>(
        collectionName,
        payload,
        Lesson.fromJson,
      );
    } catch (e) {
      _ref.read(lessonServiceErrorProvider.notifier).state = e.toString();
      rethrow;
    } finally {
      _ref.read(lessonServiceLoadingProvider.notifier).state = false;
    }
  }

  Future<List<Lesson>> getLessons(String teacherId) async {
    _ref.read(lessonServiceLoadingProvider.notifier).state = true;
    _ref.read(lessonServiceErrorProvider.notifier).state = null;
    try {
      return await _firestoreService.query<Lesson>(
        collectionName,
        Lesson.fromJson,
        filters: {'teacherId': teacherId},
      );
    } catch (e) {
      _ref.read(lessonServiceErrorProvider.notifier).state = e.toString();
      rethrow;
    } finally {
      _ref.read(lessonServiceLoadingProvider.notifier).state = false;
    }
  }

  Future<Lesson> updateLesson(Lesson lesson) async {
    _ref.read(lessonServiceLoadingProvider.notifier).state = true;
    _ref.read(lessonServiceErrorProvider.notifier).state = null;
    try {
      final payload = lesson.toJson()..remove('id');
      return await _firestoreService.update<Lesson>(
        collectionName,
        lesson.id,
        payload,
        Lesson.fromJson,
      );
    } catch (e) {
      _ref.read(lessonServiceErrorProvider.notifier).state = e.toString();
      rethrow;
    } finally {
      _ref.read(lessonServiceLoadingProvider.notifier).state = false;
    }
  }

  Future<void> deleteLesson(String lessonId) async {
    _ref.read(lessonServiceLoadingProvider.notifier).state = true;
    _ref.read(lessonServiceErrorProvider.notifier).state = null;
    try {
      await _firestoreService.delete(collectionName, lessonId);
    } catch (e) {
      _ref.read(lessonServiceErrorProvider.notifier).state = e.toString();
      rethrow;
    } finally {
      _ref.read(lessonServiceLoadingProvider.notifier).state = false;
    }
  }

  Future<Lesson> getLessonById(String lessonId) async {
    _ref.read(lessonServiceLoadingProvider.notifier).state = true;
    _ref.read(lessonServiceErrorProvider.notifier).state = null;
    try {
      return await _firestoreService.read<Lesson>(
        collectionName,
        lessonId,
        Lesson.fromJson,
      );
    } catch (e) {
      _ref.read(lessonServiceErrorProvider.notifier).state = e.toString();
      rethrow;
    } finally {
      _ref.read(lessonServiceLoadingProvider.notifier).state = false;
    }
  }
}
