class Teacher {
  final String id;
  final String email;
  final String fullName;
  final String? subject;

  Teacher({
    required this.id,
    required this.email,
    required this.fullName,
    this.subject,
  });

  factory Teacher.fromMap(Map<String, dynamic> map, String documentId) {
    return Teacher(
      id: documentId,
      email: map['email'] ?? '',
      fullName: map['fullName'] ?? '',
      subject: map['subject'],
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'email': email,
      'fullName': fullName,
      'subject': subject,
    };
  }

  Teacher copyWith({
    String? id,
    String? email,
    String? fullName,
    String? subject,
  }) {
    return Teacher(
      id: id ?? this.id,
      email: email ?? this.email,
      fullName: fullName ?? this.fullName,
      subject: subject ?? this.subject,
    );
  }
}
