// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'fee_policy.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

T _$identity<T>(T value) => value;

final _privateConstructorUsedError = UnsupportedError(
    'It seems like you constructed your class using `MyClass._()`. This constructor is only meant to be used by freezed and you are not supposed to need it nor use it.\nPlease check the documentation here for more information: https://github.com/rrousselGit/freezed#adding-getters-and-methods-to-our-models');

FeePolicy _$FeePolicyFromJson(Map<String, dynamic> json) {
  return _FeePolicy.fromJson(json);
}

/// @nodoc
mixin _$FeePolicy {
  int get earlyCancellationHours => throw _privateConstructorUsedError;
  double get earlyCancellationFeePercent => throw _privateConstructorUsedError;
  double get lateCancellationFeePercent => throw _privateConstructorUsedError;
  double get noShowFeePercent => throw _privateConstructorUsedError;
  bool get teacherCancellationCompensable => throw _privateConstructorUsedError;

  /// Serializes this FeePolicy to a JSON map.
  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;

  /// Create a copy of FeePolicy
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $FeePolicyCopyWith<FeePolicy> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $FeePolicyCopyWith<$Res> {
  factory $FeePolicyCopyWith(FeePolicy value, $Res Function(FeePolicy) then) =
      _$FeePolicyCopyWithImpl<$Res, FeePolicy>;
  @useResult
  $Res call(
      {int earlyCancellationHours,
      double earlyCancellationFeePercent,
      double lateCancellationFeePercent,
      double noShowFeePercent,
      bool teacherCancellationCompensable});
}

/// @nodoc
class _$FeePolicyCopyWithImpl<$Res, $Val extends FeePolicy>
    implements $FeePolicyCopyWith<$Res> {
  _$FeePolicyCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of FeePolicy
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? earlyCancellationHours = null,
    Object? earlyCancellationFeePercent = null,
    Object? lateCancellationFeePercent = null,
    Object? noShowFeePercent = null,
    Object? teacherCancellationCompensable = null,
  }) {
    return _then(_value.copyWith(
      earlyCancellationHours: null == earlyCancellationHours
          ? _value.earlyCancellationHours
          : earlyCancellationHours // ignore: cast_nullable_to_non_nullable
              as int,
      earlyCancellationFeePercent: null == earlyCancellationFeePercent
          ? _value.earlyCancellationFeePercent
          : earlyCancellationFeePercent // ignore: cast_nullable_to_non_nullable
              as double,
      lateCancellationFeePercent: null == lateCancellationFeePercent
          ? _value.lateCancellationFeePercent
          : lateCancellationFeePercent // ignore: cast_nullable_to_non_nullable
              as double,
      noShowFeePercent: null == noShowFeePercent
          ? _value.noShowFeePercent
          : noShowFeePercent // ignore: cast_nullable_to_non_nullable
              as double,
      teacherCancellationCompensable: null == teacherCancellationCompensable
          ? _value.teacherCancellationCompensable
          : teacherCancellationCompensable // ignore: cast_nullable_to_non_nullable
              as bool,
    ) as $Val);
  }
}

/// @nodoc
abstract class _$$FeePolicyImplCopyWith<$Res>
    implements $FeePolicyCopyWith<$Res> {
  factory _$$FeePolicyImplCopyWith(
          _$FeePolicyImpl value, $Res Function(_$FeePolicyImpl) then) =
      __$$FeePolicyImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call(
      {int earlyCancellationHours,
      double earlyCancellationFeePercent,
      double lateCancellationFeePercent,
      double noShowFeePercent,
      bool teacherCancellationCompensable});
}

/// @nodoc
class __$$FeePolicyImplCopyWithImpl<$Res>
    extends _$FeePolicyCopyWithImpl<$Res, _$FeePolicyImpl>
    implements _$$FeePolicyImplCopyWith<$Res> {
  __$$FeePolicyImplCopyWithImpl(
      _$FeePolicyImpl _value, $Res Function(_$FeePolicyImpl) _then)
      : super(_value, _then);

  /// Create a copy of FeePolicy
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? earlyCancellationHours = null,
    Object? earlyCancellationFeePercent = null,
    Object? lateCancellationFeePercent = null,
    Object? noShowFeePercent = null,
    Object? teacherCancellationCompensable = null,
  }) {
    return _then(_$FeePolicyImpl(
      earlyCancellationHours: null == earlyCancellationHours
          ? _value.earlyCancellationHours
          : earlyCancellationHours // ignore: cast_nullable_to_non_nullable
              as int,
      earlyCancellationFeePercent: null == earlyCancellationFeePercent
          ? _value.earlyCancellationFeePercent
          : earlyCancellationFeePercent // ignore: cast_nullable_to_non_nullable
              as double,
      lateCancellationFeePercent: null == lateCancellationFeePercent
          ? _value.lateCancellationFeePercent
          : lateCancellationFeePercent // ignore: cast_nullable_to_non_nullable
              as double,
      noShowFeePercent: null == noShowFeePercent
          ? _value.noShowFeePercent
          : noShowFeePercent // ignore: cast_nullable_to_non_nullable
              as double,
      teacherCancellationCompensable: null == teacherCancellationCompensable
          ? _value.teacherCancellationCompensable
          : teacherCancellationCompensable // ignore: cast_nullable_to_non_nullable
              as bool,
    ));
  }
}

/// @nodoc
@JsonSerializable()
class _$FeePolicyImpl extends _FeePolicy {
  const _$FeePolicyImpl(
      {this.earlyCancellationHours = 24,
      this.earlyCancellationFeePercent = 0.0,
      this.lateCancellationFeePercent = 50.0,
      this.noShowFeePercent = 100.0,
      this.teacherCancellationCompensable = true})
      : super._();

  factory _$FeePolicyImpl.fromJson(Map<String, dynamic> json) =>
      _$$FeePolicyImplFromJson(json);

  @override
  @JsonKey()
  final int earlyCancellationHours;
  @override
  @JsonKey()
  final double earlyCancellationFeePercent;
  @override
  @JsonKey()
  final double lateCancellationFeePercent;
  @override
  @JsonKey()
  final double noShowFeePercent;
  @override
  @JsonKey()
  final bool teacherCancellationCompensable;

  @override
  String toString() {
    return 'FeePolicy(earlyCancellationHours: $earlyCancellationHours, earlyCancellationFeePercent: $earlyCancellationFeePercent, lateCancellationFeePercent: $lateCancellationFeePercent, noShowFeePercent: $noShowFeePercent, teacherCancellationCompensable: $teacherCancellationCompensable)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$FeePolicyImpl &&
            (identical(other.earlyCancellationHours, earlyCancellationHours) ||
                other.earlyCancellationHours == earlyCancellationHours) &&
            (identical(other.earlyCancellationFeePercent,
                    earlyCancellationFeePercent) ||
                other.earlyCancellationFeePercent ==
                    earlyCancellationFeePercent) &&
            (identical(other.lateCancellationFeePercent,
                    lateCancellationFeePercent) ||
                other.lateCancellationFeePercent ==
                    lateCancellationFeePercent) &&
            (identical(other.noShowFeePercent, noShowFeePercent) ||
                other.noShowFeePercent == noShowFeePercent) &&
            (identical(other.teacherCancellationCompensable,
                    teacherCancellationCompensable) ||
                other.teacherCancellationCompensable ==
                    teacherCancellationCompensable));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode => Object.hash(
      runtimeType,
      earlyCancellationHours,
      earlyCancellationFeePercent,
      lateCancellationFeePercent,
      noShowFeePercent,
      teacherCancellationCompensable);

  /// Create a copy of FeePolicy
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$FeePolicyImplCopyWith<_$FeePolicyImpl> get copyWith =>
      __$$FeePolicyImplCopyWithImpl<_$FeePolicyImpl>(this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$$FeePolicyImplToJson(
      this,
    );
  }
}

abstract class _FeePolicy extends FeePolicy {
  const factory _FeePolicy(
      {final int earlyCancellationHours,
      final double earlyCancellationFeePercent,
      final double lateCancellationFeePercent,
      final double noShowFeePercent,
      final bool teacherCancellationCompensable}) = _$FeePolicyImpl;
  const _FeePolicy._() : super._();

  factory _FeePolicy.fromJson(Map<String, dynamic> json) =
      _$FeePolicyImpl.fromJson;

  @override
  int get earlyCancellationHours;
  @override
  double get earlyCancellationFeePercent;
  @override
  double get lateCancellationFeePercent;
  @override
  double get noShowFeePercent;
  @override
  bool get teacherCancellationCompensable;

  /// Create a copy of FeePolicy
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$FeePolicyImplCopyWith<_$FeePolicyImpl> get copyWith =>
      throw _privateConstructorUsedError;
}
