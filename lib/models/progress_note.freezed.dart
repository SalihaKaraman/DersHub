// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'progress_note.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

T _$identity<T>(T value) => value;

final _privateConstructorUsedError = UnsupportedError(
  'It seems like you constructed your class using `MyClass._()`. This constructor is only meant to be used by freezed and you are not supposed to need it nor use it.\nPlease check the documentation here for more information: https://github.com/rrousselGit/freezed#adding-getters-and-methods-to-our-models',
);

ProgressNote _$ProgressNoteFromJson(Map<String, dynamic> json) {
  return _ProgressNote.fromJson(json);
}

/// @nodoc
mixin _$ProgressNote {
  String get id => throw _privateConstructorUsedError;
  String get studentId => throw _privateConstructorUsedError;
  String get teacherId => throw _privateConstructorUsedError;
  String get topic => throw _privateConstructorUsedError;
  List<String> get strengths => throw _privateConstructorUsedError;
  List<String> get weaknesses => throw _privateConstructorUsedError;
  String get goals => throw _privateConstructorUsedError;
  DateTime get createdAt => throw _privateConstructorUsedError;

  /// Serializes this ProgressNote to a JSON map.
  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;

  /// Create a copy of ProgressNote
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $ProgressNoteCopyWith<ProgressNote> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $ProgressNoteCopyWith<$Res> {
  factory $ProgressNoteCopyWith(
    ProgressNote value,
    $Res Function(ProgressNote) then,
  ) = _$ProgressNoteCopyWithImpl<$Res, ProgressNote>;
  @useResult
  $Res call({
    String id,
    String studentId,
    String teacherId,
    String topic,
    List<String> strengths,
    List<String> weaknesses,
    String goals,
    DateTime createdAt,
  });
}

/// @nodoc
class _$ProgressNoteCopyWithImpl<$Res, $Val extends ProgressNote>
    implements $ProgressNoteCopyWith<$Res> {
  _$ProgressNoteCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of ProgressNote
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? studentId = null,
    Object? teacherId = null,
    Object? topic = null,
    Object? strengths = null,
    Object? weaknesses = null,
    Object? goals = null,
    Object? createdAt = null,
  }) {
    return _then(
      _value.copyWith(
            id: null == id
                ? _value.id
                : id // ignore: cast_nullable_to_non_nullable
                      as String,
            studentId: null == studentId
                ? _value.studentId
                : studentId // ignore: cast_nullable_to_non_nullable
                      as String,
            teacherId: null == teacherId
                ? _value.teacherId
                : teacherId // ignore: cast_nullable_to_non_nullable
                      as String,
            topic: null == topic
                ? _value.topic
                : topic // ignore: cast_nullable_to_non_nullable
                      as String,
            strengths: null == strengths
                ? _value.strengths
                : strengths // ignore: cast_nullable_to_non_nullable
                      as List<String>,
            weaknesses: null == weaknesses
                ? _value.weaknesses
                : weaknesses // ignore: cast_nullable_to_non_nullable
                      as List<String>,
            goals: null == goals
                ? _value.goals
                : goals // ignore: cast_nullable_to_non_nullable
                      as String,
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
abstract class _$$ProgressNoteImplCopyWith<$Res>
    implements $ProgressNoteCopyWith<$Res> {
  factory _$$ProgressNoteImplCopyWith(
    _$ProgressNoteImpl value,
    $Res Function(_$ProgressNoteImpl) then,
  ) = __$$ProgressNoteImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call({
    String id,
    String studentId,
    String teacherId,
    String topic,
    List<String> strengths,
    List<String> weaknesses,
    String goals,
    DateTime createdAt,
  });
}

/// @nodoc
class __$$ProgressNoteImplCopyWithImpl<$Res>
    extends _$ProgressNoteCopyWithImpl<$Res, _$ProgressNoteImpl>
    implements _$$ProgressNoteImplCopyWith<$Res> {
  __$$ProgressNoteImplCopyWithImpl(
    _$ProgressNoteImpl _value,
    $Res Function(_$ProgressNoteImpl) _then,
  ) : super(_value, _then);

  /// Create a copy of ProgressNote
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? studentId = null,
    Object? teacherId = null,
    Object? topic = null,
    Object? strengths = null,
    Object? weaknesses = null,
    Object? goals = null,
    Object? createdAt = null,
  }) {
    return _then(
      _$ProgressNoteImpl(
        id: null == id
            ? _value.id
            : id // ignore: cast_nullable_to_non_nullable
                  as String,
        studentId: null == studentId
            ? _value.studentId
            : studentId // ignore: cast_nullable_to_non_nullable
                  as String,
        teacherId: null == teacherId
            ? _value.teacherId
            : teacherId // ignore: cast_nullable_to_non_nullable
                  as String,
        topic: null == topic
            ? _value.topic
            : topic // ignore: cast_nullable_to_non_nullable
                  as String,
        strengths: null == strengths
            ? _value._strengths
            : strengths // ignore: cast_nullable_to_non_nullable
                  as List<String>,
        weaknesses: null == weaknesses
            ? _value._weaknesses
            : weaknesses // ignore: cast_nullable_to_non_nullable
                  as List<String>,
        goals: null == goals
            ? _value.goals
            : goals // ignore: cast_nullable_to_non_nullable
                  as String,
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
class _$ProgressNoteImpl implements _ProgressNote {
  const _$ProgressNoteImpl({
    required this.id,
    required this.studentId,
    required this.teacherId,
    required this.topic,
    required final List<String> strengths,
    required final List<String> weaknesses,
    required this.goals,
    required this.createdAt,
  }) : _strengths = strengths,
       _weaknesses = weaknesses;

  factory _$ProgressNoteImpl.fromJson(Map<String, dynamic> json) =>
      _$$ProgressNoteImplFromJson(json);

  @override
  final String id;
  @override
  final String studentId;
  @override
  final String teacherId;
  @override
  final String topic;
  final List<String> _strengths;
  @override
  List<String> get strengths {
    if (_strengths is EqualUnmodifiableListView) return _strengths;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableListView(_strengths);
  }

  final List<String> _weaknesses;
  @override
  List<String> get weaknesses {
    if (_weaknesses is EqualUnmodifiableListView) return _weaknesses;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableListView(_weaknesses);
  }

  @override
  final String goals;
  @override
  final DateTime createdAt;

  @override
  String toString() {
    return 'ProgressNote(id: $id, studentId: $studentId, teacherId: $teacherId, topic: $topic, strengths: $strengths, weaknesses: $weaknesses, goals: $goals, createdAt: $createdAt)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$ProgressNoteImpl &&
            (identical(other.id, id) || other.id == id) &&
            (identical(other.studentId, studentId) ||
                other.studentId == studentId) &&
            (identical(other.teacherId, teacherId) ||
                other.teacherId == teacherId) &&
            (identical(other.topic, topic) || other.topic == topic) &&
            const DeepCollectionEquality().equals(
              other._strengths,
              _strengths,
            ) &&
            const DeepCollectionEquality().equals(
              other._weaknesses,
              _weaknesses,
            ) &&
            (identical(other.goals, goals) || other.goals == goals) &&
            (identical(other.createdAt, createdAt) ||
                other.createdAt == createdAt));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode => Object.hash(
    runtimeType,
    id,
    studentId,
    teacherId,
    topic,
    const DeepCollectionEquality().hash(_strengths),
    const DeepCollectionEquality().hash(_weaknesses),
    goals,
    createdAt,
  );

  /// Create a copy of ProgressNote
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$ProgressNoteImplCopyWith<_$ProgressNoteImpl> get copyWith =>
      __$$ProgressNoteImplCopyWithImpl<_$ProgressNoteImpl>(this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$$ProgressNoteImplToJson(this);
  }
}

abstract class _ProgressNote implements ProgressNote {
  const factory _ProgressNote({
    required final String id,
    required final String studentId,
    required final String teacherId,
    required final String topic,
    required final List<String> strengths,
    required final List<String> weaknesses,
    required final String goals,
    required final DateTime createdAt,
  }) = _$ProgressNoteImpl;

  factory _ProgressNote.fromJson(Map<String, dynamic> json) =
      _$ProgressNoteImpl.fromJson;

  @override
  String get id;
  @override
  String get studentId;
  @override
  String get teacherId;
  @override
  String get topic;
  @override
  List<String> get strengths;
  @override
  List<String> get weaknesses;
  @override
  String get goals;
  @override
  DateTime get createdAt;

  /// Create a copy of ProgressNote
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$ProgressNoteImplCopyWith<_$ProgressNoteImpl> get copyWith =>
      throw _privateConstructorUsedError;
}
