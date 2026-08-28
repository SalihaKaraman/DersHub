// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'parent.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

T _$identity<T>(T value) => value;

final _privateConstructorUsedError = UnsupportedError(
  'It seems like you constructed your class using `MyClass._()`. This constructor is only meant to be used by freezed and you are not supposed to need it nor use it.\nPlease check the documentation here for more information: https://github.com/rrousselGit/freezed#adding-getters-and-methods-to-our-models',
);

Parent _$ParentFromJson(Map<String, dynamic> json) {
  return _Parent.fromJson(json);
}

/// @nodoc
mixin _$Parent {
  String get id => throw _privateConstructorUsedError;
  String get email => throw _privateConstructorUsedError;
  String get fullName => throw _privateConstructorUsedError;
  String get phone => throw _privateConstructorUsedError;
  List<String> get linkedStudentIds => throw _privateConstructorUsedError;
  List<String> get linkedTeacherIds => throw _privateConstructorUsedError;
  DateTime get createdAt => throw _privateConstructorUsedError;

  /// Serializes this Parent to a JSON map.
  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;

  /// Create a copy of Parent
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $ParentCopyWith<Parent> get copyWith => throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $ParentCopyWith<$Res> {
  factory $ParentCopyWith(Parent value, $Res Function(Parent) then) =
      _$ParentCopyWithImpl<$Res, Parent>;
  @useResult
  $Res call({
    String id,
    String email,
    String fullName,
    String phone,
    List<String> linkedStudentIds,
    List<String> linkedTeacherIds,
    DateTime createdAt,
  });
}

/// @nodoc
class _$ParentCopyWithImpl<$Res, $Val extends Parent>
    implements $ParentCopyWith<$Res> {
  _$ParentCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of Parent
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? email = null,
    Object? fullName = null,
    Object? phone = null,
    Object? linkedStudentIds = null,
    Object? linkedTeacherIds = null,
    Object? createdAt = null,
  }) {
    return _then(
      _value.copyWith(
            id: null == id
                ? _value.id
                : id // ignore: cast_nullable_to_non_nullable
                      as String,
            email: null == email
                ? _value.email
                : email // ignore: cast_nullable_to_non_nullable
                      as String,
            fullName: null == fullName
                ? _value.fullName
                : fullName // ignore: cast_nullable_to_non_nullable
                      as String,
            phone: null == phone
                ? _value.phone
                : phone // ignore: cast_nullable_to_non_nullable
                      as String,
            linkedStudentIds: null == linkedStudentIds
                ? _value.linkedStudentIds
                : linkedStudentIds // ignore: cast_nullable_to_non_nullable
                      as List<String>,
            linkedTeacherIds: null == linkedTeacherIds
                ? _value.linkedTeacherIds
                : linkedTeacherIds // ignore: cast_nullable_to_non_nullable
                      as List<String>,
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
abstract class _$$ParentImplCopyWith<$Res> implements $ParentCopyWith<$Res> {
  factory _$$ParentImplCopyWith(
    _$ParentImpl value,
    $Res Function(_$ParentImpl) then,
  ) = __$$ParentImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call({
    String id,
    String email,
    String fullName,
    String phone,
    List<String> linkedStudentIds,
    List<String> linkedTeacherIds,
    DateTime createdAt,
  });
}

/// @nodoc
class __$$ParentImplCopyWithImpl<$Res>
    extends _$ParentCopyWithImpl<$Res, _$ParentImpl>
    implements _$$ParentImplCopyWith<$Res> {
  __$$ParentImplCopyWithImpl(
    _$ParentImpl _value,
    $Res Function(_$ParentImpl) _then,
  ) : super(_value, _then);

  /// Create a copy of Parent
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? email = null,
    Object? fullName = null,
    Object? phone = null,
    Object? linkedStudentIds = null,
    Object? linkedTeacherIds = null,
    Object? createdAt = null,
  }) {
    return _then(
      _$ParentImpl(
        id: null == id
            ? _value.id
            : id // ignore: cast_nullable_to_non_nullable
                  as String,
        email: null == email
            ? _value.email
            : email // ignore: cast_nullable_to_non_nullable
                  as String,
        fullName: null == fullName
            ? _value.fullName
            : fullName // ignore: cast_nullable_to_non_nullable
                  as String,
        phone: null == phone
            ? _value.phone
            : phone // ignore: cast_nullable_to_non_nullable
                  as String,
        linkedStudentIds: null == linkedStudentIds
            ? _value._linkedStudentIds
            : linkedStudentIds // ignore: cast_nullable_to_non_nullable
                  as List<String>,
        linkedTeacherIds: null == linkedTeacherIds
            ? _value._linkedTeacherIds
            : linkedTeacherIds // ignore: cast_nullable_to_non_nullable
                  as List<String>,
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
class _$ParentImpl extends _Parent {
  const _$ParentImpl({
    required this.id,
    required this.email,
    required this.fullName,
    required this.phone,
    required final List<String> linkedStudentIds,
    required final List<String> linkedTeacherIds,
    required this.createdAt,
  }) : _linkedStudentIds = linkedStudentIds,
       _linkedTeacherIds = linkedTeacherIds,
       super._();

  factory _$ParentImpl.fromJson(Map<String, dynamic> json) =>
      _$$ParentImplFromJson(json);

  @override
  final String id;
  @override
  final String email;
  @override
  final String fullName;
  @override
  final String phone;
  final List<String> _linkedStudentIds;
  @override
  List<String> get linkedStudentIds {
    if (_linkedStudentIds is EqualUnmodifiableListView)
      return _linkedStudentIds;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableListView(_linkedStudentIds);
  }

  final List<String> _linkedTeacherIds;
  @override
  List<String> get linkedTeacherIds {
    if (_linkedTeacherIds is EqualUnmodifiableListView)
      return _linkedTeacherIds;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableListView(_linkedTeacherIds);
  }

  @override
  final DateTime createdAt;

  @override
  String toString() {
    return 'Parent(id: $id, email: $email, fullName: $fullName, phone: $phone, linkedStudentIds: $linkedStudentIds, linkedTeacherIds: $linkedTeacherIds, createdAt: $createdAt)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$ParentImpl &&
            (identical(other.id, id) || other.id == id) &&
            (identical(other.email, email) || other.email == email) &&
            (identical(other.fullName, fullName) ||
                other.fullName == fullName) &&
            (identical(other.phone, phone) || other.phone == phone) &&
            const DeepCollectionEquality().equals(
              other._linkedStudentIds,
              _linkedStudentIds,
            ) &&
            const DeepCollectionEquality().equals(
              other._linkedTeacherIds,
              _linkedTeacherIds,
            ) &&
            (identical(other.createdAt, createdAt) ||
                other.createdAt == createdAt));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode => Object.hash(
    runtimeType,
    id,
    email,
    fullName,
    phone,
    const DeepCollectionEquality().hash(_linkedStudentIds),
    const DeepCollectionEquality().hash(_linkedTeacherIds),
    createdAt,
  );

  /// Create a copy of Parent
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$ParentImplCopyWith<_$ParentImpl> get copyWith =>
      __$$ParentImplCopyWithImpl<_$ParentImpl>(this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$$ParentImplToJson(this);
  }
}

abstract class _Parent extends Parent {
  const factory _Parent({
    required final String id,
    required final String email,
    required final String fullName,
    required final String phone,
    required final List<String> linkedStudentIds,
    required final List<String> linkedTeacherIds,
    required final DateTime createdAt,
  }) = _$ParentImpl;
  const _Parent._() : super._();

  factory _Parent.fromJson(Map<String, dynamic> json) = _$ParentImpl.fromJson;

  @override
  String get id;
  @override
  String get email;
  @override
  String get fullName;
  @override
  String get phone;
  @override
  List<String> get linkedStudentIds;
  @override
  List<String> get linkedTeacherIds;
  @override
  DateTime get createdAt;

  /// Create a copy of Parent
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$ParentImplCopyWith<_$ParentImpl> get copyWith =>
      throw _privateConstructorUsedError;
}
