class Note {
  final String id;
  final String title;
  final String content;
  final String? studentId;
  final String? studentName;
  final DateTime createdAt;
  final int colorValue; // For custom colorful note tiles

  Note({
    required this.id,
    required this.title,
    required this.content,
    this.studentId,
    this.studentName,
    required this.createdAt,
    this.colorValue = 0xFF4F46E5, // Default indigo
  });

  factory Note.fromMap(Map<String, dynamic> map, String documentId) {
    return Note(
      id: documentId,
      title: map['title'] ?? '',
      content: map['content'] ?? '',
      studentId: map['studentId'],
      studentName: map['studentName'],
      createdAt: map['createdAt'] != null
          ? DateTime.fromMillisecondsSinceEpoch(map['createdAt'])
          : DateTime.now(),
      colorValue: map['colorValue'] ?? 0xFF4F46E5,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'title': title,
      'content': content,
      'studentId': studentId,
      'studentName': studentName,
      'createdAt': createdAt.millisecondsSinceEpoch,
      'colorValue': colorValue,
    };
  }

  Note copyWith({
    String? id,
    String? title,
    String? content,
    String? studentId,
    String? studentName,
    DateTime? createdAt,
    int? colorValue,
  }) {
    return Note(
      id: id ?? this.id,
      title: title ?? this.title,
      content: content ?? this.content,
      studentId: studentId ?? this.studentId,
      studentName: studentName ?? this.studentName,
      createdAt: createdAt ?? this.createdAt,
      colorValue: colorValue ?? this.colorValue,
    );
  }
}
