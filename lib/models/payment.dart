import 'package:freezed_annotation/freezed_annotation.dart';

part 'payment.freezed.dart';
part 'payment.g.dart';

@freezed
class Payment with _$Payment {
  const factory Payment({
    required String id,
    required String teacherId,
    required String studentId,
    required String studentName,
    String? lessonId,
    required double amount,
    required String status,
    required DateTime dueDate,
    DateTime? paymentDate,
    String? paymentMethod,
  }) = _Payment;

  const Payment._();

  factory Payment.fromJson(Map<String, dynamic> json) =>
      _$PaymentFromJson(json);

  factory Payment.fromMap(Map<String, dynamic> map, String id) {
    return Payment.fromJson({...map, 'id': id});
  }

  Map<String, dynamic> toMap() {
    final json = toJson();
    json.remove('id');
    return json;
  }
}
