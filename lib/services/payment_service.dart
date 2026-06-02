import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/payment.dart';
import 'firestore_service.dart';

// Ödeme servisindeki loading durumunu takip eden provider.
final paymentServiceLoadingProvider = StateProvider<bool>((ref) => false);
// Ödeme servisindeki hata mesajlarını tutan provider.
final paymentServiceErrorProvider = StateProvider<String?>((ref) => null);
// PaymentService sağlayıcısı. FirestoreService aracılığıyla ödeme CRUD işlemleri yapar.
final paymentServiceProvider = Provider<PaymentService>((ref) {
  return PaymentService(ref.watch(firestoreServiceProvider), ref);
});

class PaymentService {
  static const String collectionName = 'payments';

  final FirestoreService _firestoreService;
  final Ref _ref;

  PaymentService(this._firestoreService, this._ref);

  Future<Payment> addPayment(Payment payment) async {
    _ref.read(paymentServiceLoadingProvider.notifier).state = true;
    _ref.read(paymentServiceErrorProvider.notifier).state = null;
    try {
      final payload = payment.toJson()..remove('id');
      return await _firestoreService.create<Payment>(
        collectionName,
        payload,
        Payment.fromJson,
      );
    } catch (e) {
      _ref.read(paymentServiceErrorProvider.notifier).state = e.toString();
      rethrow;
    } finally {
      _ref.read(paymentServiceLoadingProvider.notifier).state = false;
    }
  }

  Future<List<Payment>> getPayments(String teacherId) async {
    _ref.read(paymentServiceLoadingProvider.notifier).state = true;
    _ref.read(paymentServiceErrorProvider.notifier).state = null;
    try {
      return await _firestoreService.query<Payment>(
        collectionName,
        Payment.fromJson,
        filters: {'teacherId': teacherId},
      );
    } catch (e) {
      _ref.read(paymentServiceErrorProvider.notifier).state = e.toString();
      rethrow;
    } finally {
      _ref.read(paymentServiceLoadingProvider.notifier).state = false;
    }
  }

  Future<Payment> updatePayment(Payment payment) async {
    _ref.read(paymentServiceLoadingProvider.notifier).state = true;
    _ref.read(paymentServiceErrorProvider.notifier).state = null;
    try {
      final payload = payment.toJson()..remove('id');
      return await _firestoreService.update<Payment>(
        collectionName,
        payment.id,
        payload,
        Payment.fromJson,
      );
    } catch (e) {
      _ref.read(paymentServiceErrorProvider.notifier).state = e.toString();
      rethrow;
    } finally {
      _ref.read(paymentServiceLoadingProvider.notifier).state = false;
    }
  }

  Future<void> deletePayment(String paymentId) async {
    _ref.read(paymentServiceLoadingProvider.notifier).state = true;
    _ref.read(paymentServiceErrorProvider.notifier).state = null;
    try {
      await _firestoreService.delete(collectionName, paymentId);
    } catch (e) {
      _ref.read(paymentServiceErrorProvider.notifier).state = e.toString();
      rethrow;
    } finally {
      _ref.read(paymentServiceLoadingProvider.notifier).state = false;
    }
  }

  Future<Payment> getPaymentById(String paymentId) async {
    _ref.read(paymentServiceLoadingProvider.notifier).state = true;
    _ref.read(paymentServiceErrorProvider.notifier).state = null;
    try {
      return await _firestoreService.read<Payment>(
        collectionName,
        paymentId,
        Payment.fromJson,
      );
    } catch (e) {
      _ref.read(paymentServiceErrorProvider.notifier).state = e.toString();
      rethrow;
    } finally {
      _ref.read(paymentServiceLoadingProvider.notifier).state = false;
    }
  }
}
