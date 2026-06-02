import 'package:freezed_annotation/freezed_annotation.dart';

part 'progress_note.freezed.dart';
part 'progress_note.g.dart';

@freezed
class ProgressNote with _$ProgressNote {
  const factory ProgressNote({
    required String id,
    required String studentId,
    required String teacherId,
    required String topic,
    required List<String> strengths,
    required List<String> weaknesses,
    required String goals,
    required DateTime createdAt,
  }) = _ProgressNote;

  factory ProgressNote.fromJson(Map<String, dynamic> json) =>
      _$ProgressNoteFromJson(json);
}
