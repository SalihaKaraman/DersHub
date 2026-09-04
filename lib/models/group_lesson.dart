import 'package:freezed_annotation/freezed_annotation.dart';

part 'group_lesson.freezed.dart';
part 'group_lesson.g.dart';

@freezed
class GroupLessonNote with _$GroupLessonNote {
  const factory GroupLessonNote({
    required String studentId,
    required String studentName,
    @Default('') String personalNote,
    @Default(true) bool attended,
    double? score,
  }) = _GroupLessonNote;

  factory GroupLessonNote.fromJson(Map<String, dynamic> json) =>
      _$GroupLessonNoteFromJson(json);
}

@freezed
class GroupLesson with _$GroupLesson {
  const factory GroupLesson({
    required String id,
    required String teacherId,
    required String groupName,
    required String subject,
    required String topic,
    required List<String> studentIds,
    required List<String> studentNames,
    required DateTime dateTime,
    required int durationMinutes,
    required double pricePerStudent,
    @Default('') String notes,
    @Default([]) List<GroupLessonNote> individualNotes,
    @Default(false) bool isCompleted,
    required DateTime createdAt,
  }) = _GroupLesson;

  const GroupLesson._();

  double get totalPrice => pricePerStudent * studentIds.length;
  int get attendedCount =>
      individualNotes.where((n) => n.attended).length;

  factory GroupLesson.fromJson(Map<String, dynamic> json) =>
      _$GroupLessonFromJson(json);

  factory GroupLesson.fromMap(Map<String, dynamic> map, String id) {
    final rawNotes = map['individualNotes'];
    final List<GroupLessonNote> notesList = [];
    if (rawNotes is List) {
      for (final item in rawNotes) {
        if (item is GroupLessonNote) {
          notesList.add(item);
        } else if (item is Map) {
          notesList.add(
            GroupLessonNote.fromJson(Map<String, dynamic>.from(item)),
          );
        }
      }
    }

    return GroupLesson(
      id: id,
      teacherId: map['teacherId'] as String? ?? '',
      groupName: map['groupName'] as String? ?? '',
      subject: map['subject'] as String? ?? '',
      topic: map['topic'] as String? ?? '',
      studentIds: List<String>.from(map['studentIds'] ?? []),
      studentNames: List<String>.from(map['studentNames'] ?? []),
      dateTime: map['dateTime'] is String
          ? DateTime.parse(map['dateTime'] as String)
          : (map['dateTime'] != null
              ? (map['dateTime']).toDate()
              : DateTime.now()),
      durationMinutes: (map['durationMinutes'] as num?)?.toInt() ?? 60,
      pricePerStudent: (map['pricePerStudent'] as num?)?.toDouble() ?? 0.0,
      notes: map['notes'] as String? ?? '',
      individualNotes: notesList,
      isCompleted: map['isCompleted'] as bool? ?? false,
      createdAt: map['createdAt'] is String
          ? DateTime.parse(map['createdAt'] as String)
          : (map['createdAt'] != null
              ? (map['createdAt']).toDate()
              : DateTime.now()),
    );
  }

  Map<String, dynamic> toMap() {
    final json = toJson();
    json.remove('id');
    json['individualNotes'] =
        individualNotes.map((e) => e.toJson()).toList();
    return json;
  }
}
