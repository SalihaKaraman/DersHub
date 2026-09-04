// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'group_lesson.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

T _$identity<T>(T value) => value;

final _privateConstructorUsedError = UnsupportedError(
  'It seems like you constructed your class using `MyClass._()`. This constructor is only meant to be used by freezed and you are not supposed to need it nor use it.\nPlease check the documentation here for more information: https://github.com/rrousselGit/freezed#adding-getters-and-methods-to-our-models',
);

GroupLessonNote _$GroupLessonNoteFromJson(Map<String, dynamic> json) {
  return _GroupLessonNote.fromJson(json);
}

/// @nodoc
mixin _$GroupLessonNote {
  String get studentId => throw _privateConstructorUsedError;
  String get studentName => throw _privateConstructorUsedError;
  String get personalNote => throw _privateConstructorUsedError;
  bool get attended => throw _privateConstructorUsedError;
  double? get score => throw _privateConstructorUsedError;

  /// Serializes this GroupLessonNote to a JSON map.
  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;

  /// Create a copy of GroupLessonNote
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $GroupLessonNoteCopyWith<GroupLessonNote> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $GroupLessonNoteCopyWith<$Res> {
  factory $GroupLessonNoteCopyWith(
    GroupLessonNote value,
    $Res Function(GroupLessonNote) then,
  ) = _$GroupLessonNoteCopyWithImpl<$Res, GroupLessonNote>;
  @useResult
  $Res call({
    String studentId,
    String studentName,
    String personalNote,
    bool attended,
    double? score,
  });
}

/// @nodoc
class _$GroupLessonNoteCopyWithImpl<$Res, $Val extends GroupLessonNote>
    implements $GroupLessonNoteCopyWith<$Res> {
  _$GroupLessonNoteCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of GroupLessonNote
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? studentId = null,
    Object? studentName = null,
    Object? personalNote = null,
    Object? attended = null,
    Object? score = freezed,
  }) {
    return _then(
      _value.copyWith(
            studentId: null == studentId
                ? _value.studentId
                : studentId // ignore: cast_nullable_to_non_nullable
                      as String,
            studentName: null == studentName
                ? _value.studentName
                : studentName // ignore: cast_nullable_to_non_nullable
                      as String,
            personalNote: null == personalNote
                ? _value.personalNote
                : personalNote // ignore: cast_nullable_to_non_nullable
                      as String,
            attended: null == attended
                ? _value.attended
                : attended // ignore: cast_nullable_to_non_nullable
                      as bool,
            score: freezed == score
                ? _value.score
                : score // ignore: cast_nullable_to_non_nullable
                      as double?,
          )
          as $Val,
    );
  }
}

/// @nodoc
abstract class _$$GroupLessonNoteImplCopyWith<$Res>
    implements $GroupLessonNoteCopyWith<$Res> {
  factory _$$GroupLessonNoteImplCopyWith(
    _$GroupLessonNoteImpl value,
    $Res Function(_$GroupLessonNoteImpl) then,
  ) = __$$GroupLessonNoteImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call({
    String studentId,
    String studentName,
    String personalNote,
    bool attended,
    double? score,
  });
}

/// @nodoc
class __$$GroupLessonNoteImplCopyWithImpl<$Res>
    extends _$GroupLessonNoteCopyWithImpl<$Res, _$GroupLessonNoteImpl>
    implements _$$GroupLessonNoteImplCopyWith<$Res> {
  __$$GroupLessonNoteImplCopyWithImpl(
    _$GroupLessonNoteImpl _value,
    $Res Function(_$GroupLessonNoteImpl) _then,
  ) : super(_value, _then);

  /// Create a copy of GroupLessonNote
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? studentId = null,
    Object? studentName = null,
    Object? personalNote = null,
    Object? attended = null,
    Object? score = freezed,
  }) {
    return _then(
      _$GroupLessonNoteImpl(
        studentId: null == studentId
            ? _value.studentId
            : studentId // ignore: cast_nullable_to_non_nullable
                  as String,
        studentName: null == studentName
            ? _value.studentName
            : studentName // ignore: cast_nullable_to_non_nullable
                  as String,
        personalNote: null == personalNote
            ? _value.personalNote
            : personalNote // ignore: cast_nullable_to_non_nullable
                  as String,
        attended: null == attended
            ? _value.attended
            : attended // ignore: cast_nullable_to_non_nullable
                  as bool,
        score: freezed == score
            ? _value.score
            : score // ignore: cast_nullable_to_non_nullable
                  as double?,
      ),
    );
  }
}

/// @nodoc
@JsonSerializable()
class _$GroupLessonNoteImpl implements _GroupLessonNote {
  const _$GroupLessonNoteImpl({
    required this.studentId,
    required this.studentName,
    this.personalNote = '',
    this.attended = true,
    this.score,
  });

  factory _$GroupLessonNoteImpl.fromJson(Map<String, dynamic> json) =>
      _$$GroupLessonNoteImplFromJson(json);

  @override
  final String studentId;
  @override
  final String studentName;
  @override
  @JsonKey()
  final String personalNote;
  @override
  @JsonKey()
  final bool attended;
  @override
  final double? score;

  @override
  String toString() {
    return 'GroupLessonNote(studentId: $studentId, studentName: $studentName, personalNote: $personalNote, attended: $attended, score: $score)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$GroupLessonNoteImpl &&
            (identical(other.studentId, studentId) ||
                other.studentId == studentId) &&
            (identical(other.studentName, studentName) ||
                other.studentName == studentName) &&
            (identical(other.personalNote, personalNote) ||
                other.personalNote == personalNote) &&
            (identical(other.attended, attended) ||
                other.attended == attended) &&
            (identical(other.score, score) || other.score == score));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode => Object.hash(
    runtimeType,
    studentId,
    studentName,
    personalNote,
    attended,
    score,
  );

  /// Create a copy of GroupLessonNote
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$GroupLessonNoteImplCopyWith<_$GroupLessonNoteImpl> get copyWith =>
      __$$GroupLessonNoteImplCopyWithImpl<_$GroupLessonNoteImpl>(
        this,
        _$identity,
      );

  @override
  Map<String, dynamic> toJson() {
    return _$$GroupLessonNoteImplToJson(this);
  }
}

abstract class _GroupLessonNote implements GroupLessonNote {
  const factory _GroupLessonNote({
    required final String studentId,
    required final String studentName,
    final String personalNote,
    final bool attended,
    final double? score,
  }) = _$GroupLessonNoteImpl;

  factory _GroupLessonNote.fromJson(Map<String, dynamic> json) =
      _$GroupLessonNoteImpl.fromJson;

  @override
  String get studentId;
  @override
  String get studentName;
  @override
  String get personalNote;
  @override
  bool get attended;
  @override
  double? get score;

  /// Create a copy of GroupLessonNote
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$GroupLessonNoteImplCopyWith<_$GroupLessonNoteImpl> get copyWith =>
      throw _privateConstructorUsedError;
}

GroupLesson _$GroupLessonFromJson(Map<String, dynamic> json) {
  return _GroupLesson.fromJson(json);
}

/// @nodoc
mixin _$GroupLesson {
  String get id => throw _privateConstructorUsedError;
  String get teacherId => throw _privateConstructorUsedError;
  String get groupName => throw _privateConstructorUsedError;
  String get subject => throw _privateConstructorUsedError;
  String get topic => throw _privateConstructorUsedError;
  List<String> get studentIds => throw _privateConstructorUsedError;
  List<String> get studentNames => throw _privateConstructorUsedError;
  DateTime get dateTime => throw _privateConstructorUsedError;
  int get durationMinutes => throw _privateConstructorUsedError;
  double get pricePerStudent => throw _privateConstructorUsedError;
  String get notes => throw _privateConstructorUsedError;
  List<GroupLessonNote> get individualNotes =>
      throw _privateConstructorUsedError;
  bool get isCompleted => throw _privateConstructorUsedError;
  DateTime get createdAt => throw _privateConstructorUsedError;

  /// Serializes this GroupLesson to a JSON map.
  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;

  /// Create a copy of GroupLesson
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $GroupLessonCopyWith<GroupLesson> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $GroupLessonCopyWith<$Res> {
  factory $GroupLessonCopyWith(
    GroupLesson value,
    $Res Function(GroupLesson) then,
  ) = _$GroupLessonCopyWithImpl<$Res, GroupLesson>;
  @useResult
  $Res call({
    String id,
    String teacherId,
    String groupName,
    String subject,
    String topic,
    List<String> studentIds,
    List<String> studentNames,
    DateTime dateTime,
    int durationMinutes,
    double pricePerStudent,
    String notes,
    List<GroupLessonNote> individualNotes,
    bool isCompleted,
    DateTime createdAt,
  });
}

/// @nodoc
class _$GroupLessonCopyWithImpl<$Res, $Val extends GroupLesson>
    implements $GroupLessonCopyWith<$Res> {
  _$GroupLessonCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of GroupLesson
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? teacherId = null,
    Object? groupName = null,
    Object? subject = null,
    Object? topic = null,
    Object? studentIds = null,
    Object? studentNames = null,
    Object? dateTime = null,
    Object? durationMinutes = null,
    Object? pricePerStudent = null,
    Object? notes = null,
    Object? individualNotes = null,
    Object? isCompleted = null,
    Object? createdAt = null,
  }) {
    return _then(
      _value.copyWith(
            id: null == id
                ? _value.id
                : id // ignore: cast_nullable_to_non_nullable
                      as String,
            teacherId: null == teacherId
                ? _value.teacherId
                : teacherId // ignore: cast_nullable_to_non_nullable
                      as String,
            groupName: null == groupName
                ? _value.groupName
                : groupName // ignore: cast_nullable_to_non_nullable
                      as String,
            subject: null == subject
                ? _value.subject
                : subject // ignore: cast_nullable_to_non_nullable
                      as String,
            topic: null == topic
                ? _value.topic
                : topic // ignore: cast_nullable_to_non_nullable
                      as String,
            studentIds: null == studentIds
                ? _value.studentIds
                : studentIds // ignore: cast_nullable_to_non_nullable
                      as List<String>,
            studentNames: null == studentNames
                ? _value.studentNames
                : studentNames // ignore: cast_nullable_to_non_nullable
                      as List<String>,
            dateTime: null == dateTime
                ? _value.dateTime
                : dateTime // ignore: cast_nullable_to_non_nullable
                      as DateTime,
            durationMinutes: null == durationMinutes
                ? _value.durationMinutes
                : durationMinutes // ignore: cast_nullable_to_non_nullable
                      as int,
            pricePerStudent: null == pricePerStudent
                ? _value.pricePerStudent
                : pricePerStudent // ignore: cast_nullable_to_non_nullable
                      as double,
            notes: null == notes
                ? _value.notes
                : notes // ignore: cast_nullable_to_non_nullable
                      as String,
            individualNotes: null == individualNotes
                ? _value.individualNotes
                : individualNotes // ignore: cast_nullable_to_non_nullable
                      as List<GroupLessonNote>,
            isCompleted: null == isCompleted
                ? _value.isCompleted
                : isCompleted // ignore: cast_nullable_to_non_nullable
                      as bool,
            createdAt: null == createdAt
                ? _value.createdAt
                : createdAt // ignore: cast_nullable_to_non_nullable
                      as DateTime,
          )
          as $Val,
    );
  }
}

/// @nodoc
abstract class _$$GroupLessonImplCopyWith<$Res>
    implements $GroupLessonCopyWith<$Res> {
  factory _$$GroupLessonImplCopyWith(
    _$GroupLessonImpl value,
    $Res Function(_$GroupLessonImpl) then,
  ) = __$$GroupLessonImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call({
    String id,
    String teacherId,
    String groupName,
    String subject,
    String topic,
    List<String> studentIds,
    List<String> studentNames,
    DateTime dateTime,
    int durationMinutes,
    double pricePerStudent,
    String notes,
    List<GroupLessonNote> individualNotes,
    bool isCompleted,
    DateTime createdAt,
  });
}

/// @nodoc
class __$$GroupLessonImplCopyWithImpl<$Res>
    extends _$GroupLessonCopyWithImpl<$Res, _$GroupLessonImpl>
    implements _$$GroupLessonImplCopyWith<$Res> {
  __$$GroupLessonImplCopyWithImpl(
    _$GroupLessonImpl _value,
    $Res Function(_$GroupLessonImpl) _then,
  ) : super(_value, _then);

  /// Create a copy of GroupLesson
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? teacherId = null,
    Object? groupName = null,
    Object? subject = null,
    Object? topic = null,
    Object? studentIds = null,
    Object? studentNames = null,
    Object? dateTime = null,
    Object? durationMinutes = null,
    Object? pricePerStudent = null,
    Object? notes = null,
    Object? individualNotes = null,
    Object? isCompleted = null,
    Object? createdAt = null,
  }) {
    return _then(
      _$GroupLessonImpl(
        id: null == id
            ? _value.id
            : id // ignore: cast_nullable_to_non_nullable
                  as String,
        teacherId: null == teacherId
            ? _value.teacherId
            : teacherId // ignore: cast_nullable_to_non_nullable
                  as String,
        groupName: null == groupName
            ? _value.groupName
            : groupName // ignore: cast_nullable_to_non_nullable
                  as String,
        subject: null == subject
            ? _value.subject
            : subject // ignore: cast_nullable_to_non_nullable
                  as String,
        topic: null == topic
            ? _value.topic
            : topic // ignore: cast_nullable_to_non_nullable
                  as String,
        studentIds: null == studentIds
            ? _value._studentIds
            : studentIds // ignore: cast_nullable_to_non_nullable
                  as List<String>,
        studentNames: null == studentNames
            ? _value._studentNames
            : studentNames // ignore: cast_nullable_to_non_nullable
                  as List<String>,
        dateTime: null == dateTime
            ? _value.dateTime
            : dateTime // ignore: cast_nullable_to_non_nullable
                  as DateTime,
        durationMinutes: null == durationMinutes
            ? _value.durationMinutes
            : durationMinutes // ignore: cast_nullable_to_non_nullable
                  as int,
        pricePerStudent: null == pricePerStudent
            ? _value.pricePerStudent
            : pricePerStudent // ignore: cast_nullable_to_non_nullable
                  as double,
        notes: null == notes
            ? _value.notes
            : notes // ignore: cast_nullable_to_non_nullable
                  as String,
        individualNotes: null == individualNotes
            ? _value._individualNotes
            : individualNotes // ignore: cast_nullable_to_non_nullable
                  as List<GroupLessonNote>,
        isCompleted: null == isCompleted
            ? _value.isCompleted
            : isCompleted // ignore: cast_nullable_to_non_nullable
                  as bool,
        createdAt: null == createdAt
            ? _value.createdAt
            : createdAt // ignore: cast_nullable_to_non_nullable
                  as DateTime,
      ),
    );
  }
}

/// @nodoc
@JsonSerializable()
class _$GroupLessonImpl extends _GroupLesson {
  const _$GroupLessonImpl({
    required this.id,
    required this.teacherId,
    required this.groupName,
    required this.subject,
    required this.topic,
    required final List<String> studentIds,
    required final List<String> studentNames,
    required this.dateTime,
    required this.durationMinutes,
    required this.pricePerStudent,
    this.notes = '',
    final List<GroupLessonNote> individualNotes = const [],
    this.isCompleted = false,
    required this.createdAt,
  }) : _studentIds = studentIds,
       _studentNames = studentNames,
       _individualNotes = individualNotes,
       super._();

  factory _$GroupLessonImpl.fromJson(Map<String, dynamic> json) =>
      _$$GroupLessonImplFromJson(json);

  @override
  final String id;
  @override
  final String teacherId;
  @override
  final String groupName;
  @override
  final String subject;
  @override
  final String topic;
  final List<String> _studentIds;
  @override
  List<String> get studentIds {
    if (_studentIds is EqualUnmodifiableListView) return _studentIds;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableListView(_studentIds);
  }

  final List<String> _studentNames;
  @override
  List<String> get studentNames {
    if (_studentNames is EqualUnmodifiableListView) return _studentNames;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableListView(_studentNames);
  }

  @override
  final DateTime dateTime;
  @override
  final int durationMinutes;
  @override
  final double pricePerStudent;
  @override
  @JsonKey()
  final String notes;
  final List<GroupLessonNote> _individualNotes;
  @override
  @JsonKey()
  List<GroupLessonNote> get individualNotes {
    if (_individualNotes is EqualUnmodifiableListView) return _individualNotes;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableListView(_individualNotes);
  }

  @override
  @JsonKey()
  final bool isCompleted;
  @override
  final DateTime createdAt;

  @override
  String toString() {
    return 'GroupLesson(id: $id, teacherId: $teacherId, groupName: $groupName, subject: $subject, topic: $topic, studentIds: $studentIds, studentNames: $studentNames, dateTime: $dateTime, durationMinutes: $durationMinutes, pricePerStudent: $pricePerStudent, notes: $notes, individualNotes: $individualNotes, isCompleted: $isCompleted, createdAt: $createdAt)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$GroupLessonImpl &&
            (identical(other.id, id) || other.id == id) &&
            (identical(other.teacherId, teacherId) ||
                other.teacherId == teacherId) &&
            (identical(other.groupName, groupName) ||
                other.groupName == groupName) &&
            (identical(other.subject, subject) || other.subject == subject) &&
            (identical(other.topic, topic) || other.topic == topic) &&
            const DeepCollectionEquality().equals(
              other._studentIds,
              _studentIds,
            ) &&
            const DeepCollectionEquality().equals(
              other._studentNames,
              _studentNames,
            ) &&
            (identical(other.dateTime, dateTime) ||
                other.dateTime == dateTime) &&
            (identical(other.durationMinutes, durationMinutes) ||
                other.durationMinutes == durationMinutes) &&
            (identical(other.pricePerStudent, pricePerStudent) ||
                other.pricePerStudent == pricePerStudent) &&
            (identical(other.notes, notes) || other.notes == notes) &&
            const DeepCollectionEquality().equals(
              other._individualNotes,
              _individualNotes,
            ) &&
            (identical(other.isCompleted, isCompleted) ||
                other.isCompleted == isCompleted) &&
            (identical(other.createdAt, createdAt) ||
                other.createdAt == createdAt));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode => Object.hash(
    runtimeType,
    id,
    teacherId,
    groupName,
    subject,
    topic,
    const DeepCollectionEquality().hash(_studentIds),
    const DeepCollectionEquality().hash(_studentNames),
    dateTime,
    durationMinutes,
    pricePerStudent,
    notes,
    const DeepCollectionEquality().hash(_individualNotes),
    isCompleted,
    createdAt,
  );

  /// Create a copy of GroupLesson
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$GroupLessonImplCopyWith<_$GroupLessonImpl> get copyWith =>
      __$$GroupLessonImplCopyWithImpl<_$GroupLessonImpl>(this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$$GroupLessonImplToJson(this);
  }
}

abstract class _GroupLesson extends GroupLesson {
  const factory _GroupLesson({
    required final String id,
    required final String teacherId,
    required final String groupName,
    required final String subject,
    required final String topic,
    required final List<String> studentIds,
    required final List<String> studentNames,
    required final DateTime dateTime,
    required final int durationMinutes,
    required final double pricePerStudent,
    final String notes,
    final List<GroupLessonNote> individualNotes,
    final bool isCompleted,
    required final DateTime createdAt,
  }) = _$GroupLessonImpl;
  const _GroupLesson._() : super._();

  factory _GroupLesson.fromJson(Map<String, dynamic> json) =
      _$GroupLessonImpl.fromJson;

  @override
  String get id;
  @override
  String get teacherId;
  @override
  String get groupName;
  @override
  String get subject;
  @override
  String get topic;
  @override
  List<String> get studentIds;
  @override
  List<String> get studentNames;
  @override
  DateTime get dateTime;
  @override
  int get durationMinutes;
  @override
  double get pricePerStudent;
  @override
  String get notes;
  @override
  List<GroupLessonNote> get individualNotes;
  @override
  bool get isCompleted;
  @override
  DateTime get createdAt;

  /// Create a copy of GroupLesson
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$GroupLessonImplCopyWith<_$GroupLessonImpl> get copyWith =>
      throw _privateConstructorUsedError;
}
