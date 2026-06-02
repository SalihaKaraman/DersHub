import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/progress_note.dart';
import 'firestore_service.dart';

// İlerleme notu servisinin loading durumunu yöneten provider.
final progressNoteServiceLoadingProvider = StateProvider<bool>((ref) => false);
// İlerleme notu servisindeki hata mesajlarını saklayan provider.
final progressNoteServiceErrorProvider = StateProvider<String?>((ref) => null);
// ProgressNoteService sağlayıcısı. FirestoreService üzerinden ilerleme notu CRUD işlemlerini yapar.
final progressNoteServiceProvider = Provider<ProgressNoteService>((ref) {
  return ProgressNoteService(ref.watch(firestoreServiceProvider), ref);
});

class ProgressNoteService {
  static const String collectionName = 'progressNotes';

  final FirestoreService _firestoreService;
  final Ref _ref;

  ProgressNoteService(this._firestoreService, this._ref);

  Future<ProgressNote> addProgressNote(ProgressNote note) async {
    _ref.read(progressNoteServiceLoadingProvider.notifier).state = true;
    _ref.read(progressNoteServiceErrorProvider.notifier).state = null;
    try {
      final payload = note.toJson()..remove('id');
      return await _firestoreService.create<ProgressNote>(
        collectionName,
        payload,
        ProgressNote.fromJson,
      );
    } catch (e) {
      _ref.read(progressNoteServiceErrorProvider.notifier).state = e.toString();
      rethrow;
    } finally {
      _ref.read(progressNoteServiceLoadingProvider.notifier).state = false;
    }
  }

  Future<List<ProgressNote>> getProgressNotes(String teacherId) async {
    _ref.read(progressNoteServiceLoadingProvider.notifier).state = true;
    _ref.read(progressNoteServiceErrorProvider.notifier).state = null;
    try {
      return await _firestoreService.query<ProgressNote>(
        collectionName,
        ProgressNote.fromJson,
        filters: {'teacherId': teacherId},
      );
    } catch (e) {
      _ref.read(progressNoteServiceErrorProvider.notifier).state = e.toString();
      rethrow;
    } finally {
      _ref.read(progressNoteServiceLoadingProvider.notifier).state = false;
    }
  }

  Future<ProgressNote> updateProgressNote(ProgressNote note) async {
    _ref.read(progressNoteServiceLoadingProvider.notifier).state = true;
    _ref.read(progressNoteServiceErrorProvider.notifier).state = null;
    try {
      final payload = note.toJson()..remove('id');
      return await _firestoreService.update<ProgressNote>(
        collectionName,
        note.id,
        payload,
        ProgressNote.fromJson,
      );
    } catch (e) {
      _ref.read(progressNoteServiceErrorProvider.notifier).state = e.toString();
      rethrow;
    } finally {
      _ref.read(progressNoteServiceLoadingProvider.notifier).state = false;
    }
  }

  Future<void> deleteProgressNote(String noteId) async {
    _ref.read(progressNoteServiceLoadingProvider.notifier).state = true;
    _ref.read(progressNoteServiceErrorProvider.notifier).state = null;
    try {
      await _firestoreService.delete(collectionName, noteId);
    } catch (e) {
      _ref.read(progressNoteServiceErrorProvider.notifier).state = e.toString();
      rethrow;
    } finally {
      _ref.read(progressNoteServiceLoadingProvider.notifier).state = false;
    }
  }

  Future<ProgressNote> getProgressNoteById(String noteId) async {
    _ref.read(progressNoteServiceLoadingProvider.notifier).state = true;
    _ref.read(progressNoteServiceErrorProvider.notifier).state = null;
    try {
      return await _firestoreService.read<ProgressNote>(
        collectionName,
        noteId,
        ProgressNote.fromJson,
      );
    } catch (e) {
      _ref.read(progressNoteServiceErrorProvider.notifier).state = e.toString();
      rethrow;
    } finally {
      _ref.read(progressNoteServiceLoadingProvider.notifier).state = false;
    }
  }
}
