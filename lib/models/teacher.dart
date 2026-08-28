import 'app_user.dart';
import 'user_role.dart';

class Teacher implements AppUser {
  final String id;
  final String email;
  final String fullName;
  final String? subject;
  final List<String> parentContacts;

  Teacher({
    required this.id,
    required this.email,
    required this.fullName,
    this.subject,
    this.parentContacts = const [],
  });

  @override
  UserRole get role => UserRole.teacher;

  factory Teacher.fromMap(Map<String, dynamic> map, String documentId) {
    return Teacher(
      id: documentId,
      email: map['email'] ?? '',
      fullName: map['fullName'] ?? '',
      subject: map['subject'],
      parentContacts: List<String>.from(map['parentContacts'] ?? []),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'email': email,
      'fullName': fullName,
      'subject': subject,
      'parentContacts': parentContacts,
    };
  }

  Teacher copyWith({
    String? id,
    String? email,
    String? fullName,
    String? subject,
    List<String>? parentContacts,
  }) {
    return Teacher(
      id: id ?? this.id,
      email: email ?? this.email,
      fullName: fullName ?? this.fullName,
      subject: subject ?? this.subject,
      parentContacts: parentContacts ?? this.parentContacts,
    );
  }
}
