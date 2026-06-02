import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

// Firestore işlemleri için global loading durumunu takip eden provider.
final firestoreLoadingProvider = StateProvider<bool>((ref) => false);
// Firestore işlemlerinde oluşan hataları saklayan provider.
final firestoreErrorProvider = StateProvider<String?>((ref) => null);

// Generic Firestore servisini sağlayan provider.
// Bu servis CRUD, sorgu ve stream işlemlerini soyutlar.
final firestoreServiceProvider = Provider<FirestoreService>((ref) {
  return FirestoreService(ref);
});

class FirestoreService {
  final Ref _ref;
  final FirebaseFirestore _firestore;

  FirestoreService(this._ref) : _firestore = FirebaseFirestore.instance;

  Query<Map<String, dynamic>> _buildQuery(
    Query<Map<String, dynamic>> collection,
    Map<String, dynamic>? filters,
  ) {
    var query = collection;
    if (filters != null) {
      filters.forEach((field, value) {
        query = query.where(field, isEqualTo: value);
      });
    }
    return query;
  }

  Future<T> create<T>(
    String collection,
    Map<String, dynamic> data,
    T Function(Map<String, dynamic> json) fromJson,
  ) async {
    _ref.read(firestoreLoadingProvider.notifier).state = true;
    _ref.read(firestoreErrorProvider.notifier).state = null;

    try {
      final docRef = await _firestore.collection(collection).add(data);
      final snapshot = await docRef.get();
      final rawData = snapshot.data();
      if (rawData == null) {
        throw Exception('Belge verisi boş döndü.');
      }
      rawData['id'] = snapshot.id;
      return fromJson(rawData);
    } catch (e) {
      _ref.read(firestoreErrorProvider.notifier).state = e.toString();
      rethrow;
    } finally {
      _ref.read(firestoreLoadingProvider.notifier).state = false;
    }
  }

  Future<T> read<T>(
    String collection,
    String id,
    T Function(Map<String, dynamic> json) fromJson,
  ) async {
    _ref.read(firestoreLoadingProvider.notifier).state = true;
    _ref.read(firestoreErrorProvider.notifier).state = null;

    try {
      final snapshot = await _firestore.collection(collection).doc(id).get();
      if (!snapshot.exists || snapshot.data() == null) {
        throw Exception('Belge bulunamadı: $id');
      }
      final rawData = snapshot.data()!;
      rawData['id'] = snapshot.id;
      return fromJson(rawData);
    } catch (e) {
      _ref.read(firestoreErrorProvider.notifier).state = e.toString();
      rethrow;
    } finally {
      _ref.read(firestoreLoadingProvider.notifier).state = false;
    }
  }

  Future<T> update<T>(
    String collection,
    String id,
    Map<String, dynamic> data,
    T Function(Map<String, dynamic> json) fromJson,
  ) async {
    _ref.read(firestoreLoadingProvider.notifier).state = true;
    _ref.read(firestoreErrorProvider.notifier).state = null;

    try {
      await _firestore.collection(collection).doc(id).update(data);
      final snapshot = await _firestore.collection(collection).doc(id).get();
      if (!snapshot.exists || snapshot.data() == null) {
        throw Exception('Belge güncelleme sonrası bulunamadı: $id');
      }
      final rawData = snapshot.data()!;
      rawData['id'] = snapshot.id;
      return fromJson(rawData);
    } catch (e) {
      _ref.read(firestoreErrorProvider.notifier).state = e.toString();
      rethrow;
    } finally {
      _ref.read(firestoreLoadingProvider.notifier).state = false;
    }
  }

  Future<void> delete(String collection, String id) async {
    _ref.read(firestoreLoadingProvider.notifier).state = true;
    _ref.read(firestoreErrorProvider.notifier).state = null;

    try {
      await _firestore.collection(collection).doc(id).delete();
    } catch (e) {
      _ref.read(firestoreErrorProvider.notifier).state = e.toString();
      rethrow;
    } finally {
      _ref.read(firestoreLoadingProvider.notifier).state = false;
    }
  }

  Future<List<T>> query<T>(
    String collection,
    T Function(Map<String, dynamic> json) fromJson, {
    Map<String, dynamic>? filters,
  }) async {
    _ref.read(firestoreLoadingProvider.notifier).state = true;
    _ref.read(firestoreErrorProvider.notifier).state = null;

    try {
      final collectionRef = _firestore.collection(collection);
      final query = _buildQuery(collectionRef, filters);
      final snapshot = await query.get();
      return snapshot.docs.map((doc) {
        final rawData = doc.data();
        rawData['id'] = doc.id;
        return fromJson(rawData);
      }).toList();
    } catch (e) {
      _ref.read(firestoreErrorProvider.notifier).state = e.toString();
      rethrow;
    } finally {
      _ref.read(firestoreLoadingProvider.notifier).state = false;
    }
  }

  Stream<List<T>> stream<T>(
    String collection,
    T Function(Map<String, dynamic> json) fromJson, {
    Map<String, dynamic>? filters,
  }) {
    final collectionRef = _firestore.collection(collection);
    final query = _buildQuery(collectionRef, filters);
    return query.snapshots().map((snapshot) {
      return snapshot.docs.map((doc) {
        final rawData = doc.data();
        rawData['id'] = doc.id;
        return fromJson(rawData);
      }).toList();
    });
  }
}
