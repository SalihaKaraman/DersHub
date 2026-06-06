import 'dart:async';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/foundation.dart';
import 'package:firebase_auth/firebase_auth.dart' as fb;
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/teacher.dart';

// Auth işlemleri için global loading durumunu takip eden provider.
final authLoadingProvider = StateProvider<bool>((ref) => false);
// Auth işlemlerinde oluşan hataları saklayan provider.
final authErrorProvider = StateProvider<String?>((ref) => null);

// Auth servisini sağlayan provider. Bu servis, uygulamadaki auth işlemlerini gerçekleştirir.
final authServiceProvider = Provider<AuthService>((ref) {
  return AuthService(ref);
});

final authStateProvider = StreamProvider<Teacher?>((ref) {
  final authService = ref.watch(authServiceProvider);
  return authService.authStateChanges;
});

class AuthService {
  final Ref _ref;
  final fb.FirebaseAuth? _firebaseAuth;
  final StreamController<Teacher?> _mockAuthStateController =
      StreamController<Teacher?>.broadcast();
  Teacher? _currentMockUser;
  Teacher? _currentTeacher;
  bool _useMockMode = false;

  AuthService(this._ref) : _firebaseAuth = _initFirebaseAuth() {
    // Initialize mock mode when Firebase is unavailable (e.g. initialization failed or not configured)
    if (_firebaseAuth == null) {
      _useMockMode = true;
      _currentMockUser = null;
      // Send the current mock user status when a subscriber starts listening
      _mockAuthStateController.onListen = () {
        _mockAuthStateController.add(_currentMockUser);
      };
    }
  }

  static fb.FirebaseAuth? _initFirebaseAuth() {
    try {
      return fb.FirebaseAuth.instance;
    } catch (_) {
      return null;
    }
  }

  bool get isMockMode => _useMockMode;

  Stream<Teacher?> get authStateChanges {
    if (_useMockMode) {
      return _mockAuthStateController.stream;
    } else {
      return _firebaseAuth!.authStateChanges().asyncMap((fbUser) async {
        if (fbUser == null) {
          _currentTeacher = null;
          return null;
        }

        try {
          final doc = await FirebaseFirestore.instance
              .collection('teachers')
              .doc(fbUser.uid)
              .get();
          if (doc.exists && doc.data() != null) {
            final teacher = Teacher.fromMap(doc.data()!, doc.id);
            _currentTeacher = teacher;
            return teacher;
          }
        } catch (e) {
          debugPrint('Error loading teacher profile: $e');
        }

        final teacher = Teacher(
          id: fbUser.uid,
          email: fbUser.email ?? '',
          fullName: fbUser.displayName ?? 'Öğretmen',
          subject: 'Genel',
        );
        _currentTeacher = teacher;
        return teacher;
      });
    }
  }

  Teacher? getCurrentUser() {
    if (_useMockMode) {
      return _currentMockUser;
    }
    if (_currentTeacher != null) {
      return _currentTeacher;
    }
    final currentUser = _firebaseAuth?.currentUser;
    if (currentUser != null) {
      return Teacher(
        id: currentUser.uid,
        email: currentUser.email ?? '',
        fullName: currentUser.displayName ?? 'Öğretmen',
        subject: 'Genel',
      );
    }
    return null;
  }

  Future<Teacher> signIn(String email, String password) async {
    _ref.read(authLoadingProvider.notifier).state = true;
    _ref.read(authErrorProvider.notifier).state = null;

    try {
      if (_useMockMode) {
        await Future.delayed(const Duration(milliseconds: 800));
        if (email.contains('error')) {
          throw Exception('Giriş başarısız. Bilgilerinizi kontrol edin.');
        }
        final user = Teacher(
          id: 'mock_teacher_id',
          email: email,
          fullName: 'Ahmet Yılmaz',
          subject: 'Matematik',
        );
        _currentMockUser = user;
        _mockAuthStateController.add(user);
        return user;
      }

      final credential = await _firebaseAuth!.signInWithEmailAndPassword(
        email: email.trim(),
        password: password,
      );
      final fbUser = credential.user!;
      
      // Load from firestore
      Teacher? teacher;
      try {
        final doc = await FirebaseFirestore.instance
            .collection('teachers')
            .doc(fbUser.uid)
            .get();
        if (doc.exists && doc.data() != null) {
          teacher = Teacher.fromMap(doc.data()!, doc.id);
          _currentTeacher = teacher;
        }
      } catch (e) {
        debugPrint('Error fetching teacher profile on sign-in: $e');
      }

      return teacher ?? Teacher(
        id: fbUser.uid,
        email: fbUser.email ?? '',
        fullName: fbUser.displayName ?? 'Öğretmen',
        subject: 'Genel',
      );
    } catch (e) {
      _ref.read(authErrorProvider.notifier).state = e.toString();
      rethrow;
    } finally {
      _ref.read(authLoadingProvider.notifier).state = false;
    }
  }

  Future<Teacher> signUp(
    String email,
    String password, {
    String fullName = 'Öğretmen',
    String subject = 'Genel',
  }) async {
    _ref.read(authLoadingProvider.notifier).state = true;
    _ref.read(authErrorProvider.notifier).state = null;

    try {
      if (_useMockMode) {
        await Future.delayed(const Duration(milliseconds: 1000));
        final user = Teacher(
          id: 'mock_teacher_id',
          email: email,
          fullName: fullName,
          subject: subject,
        );
        _currentMockUser = user;
        _mockAuthStateController.add(user);
        return user;
      }

      final credential = await _firebaseAuth!.createUserWithEmailAndPassword(
        email: email.trim(),
        password: password,
      );
      final fbUser = credential.user!;
      await fbUser.updateDisplayName(fullName);

      // Create new Teacher document in Firestore
      final newTeacher = Teacher(
        id: fbUser.uid,
        email: fbUser.email ?? email,
        fullName: fullName,
        subject: subject,
      );

      await FirebaseFirestore.instance
          .collection('teachers')
          .doc(fbUser.uid)
          .set(newTeacher.toMap());

      _currentTeacher = newTeacher;
      return newTeacher;
    } catch (e) {
      _ref.read(authErrorProvider.notifier).state = e.toString();
      rethrow;
    } finally {
      _ref.read(authLoadingProvider.notifier).state = false;
    }
  }

  Future<void> resetPassword(String email) async {
    _ref.read(authLoadingProvider.notifier).state = true;
    _ref.read(authErrorProvider.notifier).state = null;

    try {
      if (_useMockMode) {
        await Future.delayed(const Duration(milliseconds: 800));
        return;
      }
      await _firebaseAuth!.sendPasswordResetEmail(email: email.trim());
    } catch (e) {
      _ref.read(authErrorProvider.notifier).state = e.toString();
      rethrow;
    } finally {
      _ref.read(authLoadingProvider.notifier).state = false;
    }
  }

  Future<void> signOut() async {
    _ref.read(authLoadingProvider.notifier).state = true;
    _ref.read(authErrorProvider.notifier).state = null;

    try {
      if (_useMockMode) {
        await Future.delayed(const Duration(milliseconds: 500));
        _currentMockUser = null;
        _mockAuthStateController.add(null);
        return;
      }
      await _firebaseAuth!.signOut();
    } catch (e) {
      _ref.read(authErrorProvider.notifier).state = e.toString();
      rethrow;
    } finally {
      _ref.read(authLoadingProvider.notifier).state = false;
    }
  }

  Future<void> updateTeacherProfile({
    required String fullName,
    required String subject,
  }) async {
    _ref.read(authLoadingProvider.notifier).state = true;
    _ref.read(authErrorProvider.notifier).state = null;

    try {
      if (_useMockMode) {
        await Future.delayed(const Duration(milliseconds: 500));
        if (_currentMockUser != null) {
          _currentMockUser = _currentMockUser!.copyWith(
            fullName: fullName,
            subject: subject,
          );
          _mockAuthStateController.add(_currentMockUser);
        }
        return;
      }

      final fbUser = _firebaseAuth!.currentUser;
      if (fbUser == null) throw Exception('Kullanıcı oturumu bulunamadı.');

      await fbUser.updateDisplayName(fullName);

      await FirebaseFirestore.instance
          .collection('teachers')
          .doc(fbUser.uid)
          .set({
        'fullName': fullName,
        'subject': subject,
        'email': fbUser.email ?? '',
      }, SetOptions(merge: true));

      _currentTeacher = _currentTeacher?.copyWith(
        fullName: fullName,
        subject: subject,
      );
      // Re-emit so listeners pick up the update
      if (_currentTeacher != null) {
        _mockAuthStateController.add(_currentTeacher);
      }
    } catch (e) {
      _ref.read(authErrorProvider.notifier).state = e.toString();
      rethrow;
    } finally {
      _ref.read(authLoadingProvider.notifier).state = false;
    }
  }

  Future<void> deleteAccount() async {
    _ref.read(authLoadingProvider.notifier).state = true;
    _ref.read(authErrorProvider.notifier).state = null;

    try {
      if (_useMockMode) {
        await Future.delayed(const Duration(milliseconds: 800));
        _currentMockUser = null;
        _mockAuthStateController.add(null);
        return;
      }

      final fbUser = _firebaseAuth!.currentUser;
      if (fbUser == null) throw Exception('Kullanıcı oturumu bulunamadı.');

      // Delete teacher document from Firestore
      await FirebaseFirestore.instance
          .collection('teachers')
          .doc(fbUser.uid)
          .delete();

      // Delete the Firebase Auth account
      await fbUser.delete();
      _currentTeacher = null;
    } catch (e) {
      _ref.read(authErrorProvider.notifier).state = e.toString();
      rethrow;
    } finally {
      _ref.read(authLoadingProvider.notifier).state = false;
    }
  }
}
