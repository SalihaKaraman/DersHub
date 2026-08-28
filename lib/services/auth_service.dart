import 'dart:async';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/foundation.dart';
import 'package:firebase_auth/firebase_auth.dart' as fb;
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/app_user.dart';
import '../models/teacher.dart';
import '../models/parent.dart';
import '../models/user_role.dart';

// Auth işlemleri için global loading durumunu takip eden provider.
final authLoadingProvider = StateProvider<bool>((ref) => false);
// Auth işlemlerinde oluşan hataları saklayan provider.
final authErrorProvider = StateProvider<String?>((ref) => null);

// Auth servisini sağlayan provider.
final authServiceProvider = Provider<AuthService>((ref) {
  return AuthService(ref);
});

// Artık Teacher? yerine AppUser? dönüyor.
final authStateProvider = StreamProvider<AppUser?>((ref) {
  final authService = ref.watch(authServiceProvider);
  return authService.authStateChanges;
});

class AuthService {
  final Ref _ref;
  final fb.FirebaseAuth? _firebaseAuth;
  final StreamController<AppUser?> _mockAuthStateController =
      StreamController<AppUser?>.broadcast();
  AppUser? _currentMockUser;
  AppUser? _currentUser;
  bool _useMockMode = false;

  AuthService(this._ref) : _firebaseAuth = _initFirebaseAuth() {
    if (_firebaseAuth == null) {
      _useMockMode = true;
      _currentMockUser = null;
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

  Stream<AppUser?> get authStateChanges {
    if (_useMockMode) {
      return _mockAuthStateController.stream;
    } else {
      return _firebaseAuth!.authStateChanges().asyncMap((fbUser) async {
        if (fbUser == null) {
          _currentUser = null;
          return null;
        }
        
        try {
          // Önce öğretmen mi diye kontrol et
          final teacherDoc = await FirebaseFirestore.instance
              .collection('teachers')
              .doc(fbUser.uid)
              .get();
          if (teacherDoc.exists && teacherDoc.data() != null) {
            final teacher = Teacher.fromMap(teacherDoc.data()!, teacherDoc.id);
            _currentUser = teacher;
            return teacher;
          }

          // Öğretmen değilse veli mi diye kontrol et
          final parentDoc = await FirebaseFirestore.instance
              .collection('parents')
              .doc(fbUser.uid)
              .get();
          if (parentDoc.exists && parentDoc.data() != null) {
            final parent = Parent.fromMap(parentDoc.data()!, parentDoc.id);
            _currentUser = parent;
            return parent;
          }
        } catch (e) {
          debugPrint('Error loading user profile: $e');
        }

        // Bulunamazsa varsayılan olarak öğretmen döndür (geriye dönük uyumluluk)
        final teacher = Teacher(
          id: fbUser.uid,
          email: fbUser.email ?? '',
          fullName: fbUser.displayName ?? 'Öğretmen',
          subject: 'Genel',
        );
        _currentUser = teacher;
        return teacher;
      });
    }
  }

  AppUser? getCurrentUser() {
    if (_useMockMode) return _currentMockUser;
    if (_currentUser != null) return _currentUser;
    
    final fbUser = _firebaseAuth?.currentUser;
    if (fbUser != null) {
      return Teacher(
        id: fbUser.uid,
        email: fbUser.email ?? '',
        fullName: fbUser.displayName ?? 'Öğretmen',
        subject: 'Genel',
      );
    }
    return null;
  }

  Future<AppUser> signIn(String email, String password) async {
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
      
      AppUser? appUser;
      try {
        final teacherDoc = await FirebaseFirestore.instance
            .collection('teachers')
            .doc(fbUser.uid)
            .get();
        if (teacherDoc.exists && teacherDoc.data() != null) {
          appUser = Teacher.fromMap(teacherDoc.data()!, teacherDoc.id);
        } else {
          final parentDoc = await FirebaseFirestore.instance
              .collection('parents')
              .doc(fbUser.uid)
              .get();
          if (parentDoc.exists && parentDoc.data() != null) {
            appUser = Parent.fromMap(parentDoc.data()!, parentDoc.id);
          }
        }
      } catch (e) {
        debugPrint('Error fetching user profile on sign-in: $e');
      }

      final finalUser = appUser ?? Teacher(
        id: fbUser.uid,
        email: fbUser.email ?? '',
        fullName: fbUser.displayName ?? 'Öğretmen',
        subject: 'Genel',
      );
      
      _currentUser = finalUser;
      return finalUser;
    } catch (e) {
      _ref.read(authErrorProvider.notifier).state = e.toString();
      rethrow;
    } finally {
      _ref.read(authLoadingProvider.notifier).state = false;
    }
  }

  Future<AppUser> signUp({
    required String email,
    required String password,
    required String fullName,
    required UserRole role,
    String? subject,
    String? phone,
  }) async {
    _ref.read(authLoadingProvider.notifier).state = true;
    _ref.read(authErrorProvider.notifier).state = null;

    try {
      if (_useMockMode) {
        await Future.delayed(const Duration(milliseconds: 1000));
        AppUser user;
        if (role == UserRole.teacher) {
          user = Teacher(
            id: 'mock_teacher_id',
            email: email,
            fullName: fullName,
            subject: subject ?? 'Genel',
          );
        } else {
          user = Parent(
            id: 'mock_parent_id',
            email: email,
            fullName: fullName,
            phone: phone ?? '',
            linkedStudentIds: [],
            linkedTeacherIds: [],
            createdAt: DateTime.now(),
          );
        }
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

      AppUser newUser;
      
      if (role == UserRole.teacher) {
        final teacher = Teacher(
          id: fbUser.uid,
          email: fbUser.email ?? email,
          fullName: fullName,
          subject: subject ?? 'Genel',
        );
        await FirebaseFirestore.instance
            .collection('teachers')
            .doc(fbUser.uid)
            .set(teacher.toMap());
        newUser = teacher;
      } else {
        final parent = Parent(
          id: fbUser.uid,
          email: fbUser.email ?? email,
          fullName: fullName,
          phone: phone ?? '',
          linkedStudentIds: [],
          linkedTeacherIds: [],
          createdAt: DateTime.now(),
        );
        await FirebaseFirestore.instance
            .collection('parents')
            .doc(fbUser.uid)
            .set(parent.toMap());
        newUser = parent;
      }

      // Ayrıca ileride sorguları kolaylaştırmak için users koleksiyonuna role bilgisi atalım
      await FirebaseFirestore.instance
          .collection('users')
          .doc(fbUser.uid)
          .set({
        'role': role.name,
        'email': email,
      }, SetOptions(merge: true));

      _currentUser = newUser;
      return newUser;
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
        if (_currentMockUser is Teacher) {
          _currentMockUser = (_currentMockUser as Teacher).copyWith(
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

      if (_currentUser is Teacher) {
        _currentUser = (_currentUser as Teacher).copyWith(
          fullName: fullName,
          subject: subject,
        );
        _mockAuthStateController.add(_currentUser);
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

      if (_currentUser is Teacher) {
        await FirebaseFirestore.instance.collection('teachers').doc(fbUser.uid).delete();
      } else if (_currentUser is Parent) {
        await FirebaseFirestore.instance.collection('parents').doc(fbUser.uid).delete();
      }
      await FirebaseFirestore.instance.collection('users').doc(fbUser.uid).delete();

      await fbUser.delete();
      _currentUser = null;
    } catch (e) {
      _ref.read(authErrorProvider.notifier).state = e.toString();
      rethrow;
    } finally {
      _ref.read(authLoadingProvider.notifier).state = false;
    }
  }
}
