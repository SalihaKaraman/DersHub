// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'report.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

T _$identity<T>(T value) => value;

final _privateConstructorUsedError = UnsupportedError(
  'It seems like you constructed your class using `MyClass._()`. This constructor is only meant to be used by freezed and you are not supposed to need it nor use it.\nPlease check the documentation here for more information: https://github.com/rrousselGit/freezed#adding-getters-and-methods-to-our-models',
);

TopicProgress _$TopicProgressFromJson(Map<String, dynamic> json) {
  return _TopicProgress.fromJson(json);
}

/// @nodoc
mixin _$TopicProgress {
  String get topic => throw _privateConstructorUsedError;
  int get lessonsCount => throw _privateConstructorUsedError;
  String get level =>
      throw _privateConstructorUsedError; // "Başlangıç", "Orta", "İleri"
  double get proficiency => throw _privateConstructorUsedError; // 0.0 - 1.0
  String get notes => throw _privateConstructorUsedError;

  /// Serializes this TopicProgress to a JSON map.
  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;

  /// Create a copy of TopicProgress
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $TopicProgressCopyWith<TopicProgress> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $TopicProgressCopyWith<$Res> {
  factory $TopicProgressCopyWith(
    TopicProgress value,
    $Res Function(TopicProgress) then,
  ) = _$TopicProgressCopyWithImpl<$Res, TopicProgress>;
  @useResult
  $Res call({
    String topic,
    int lessonsCount,
    String level,
    double proficiency,
    String notes,
  });
}

/// @nodoc
class _$TopicProgressCopyWithImpl<$Res, $Val extends TopicProgress>
    implements $TopicProgressCopyWith<$Res> {
  _$TopicProgressCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of TopicProgress
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? topic = null,
    Object? lessonsCount = null,
    Object? level = null,
    Object? proficiency = null,
    Object? notes = null,
  }) {
    return _then(
      _value.copyWith(
            topic: null == topic
                ? _value.topic
                : topic // ignore: cast_nullable_to_non_nullable
                      as String,
            lessonsCount: null == lessonsCount
                ? _value.lessonsCount
                : lessonsCount // ignore: cast_nullable_to_non_nullable
                      as int,
            level: null == level
                ? _value.level
                : level // ignore: cast_nullable_to_non_nullable
                      as String,
            proficiency: null == proficiency
                ? _value.proficiency
                : proficiency // ignore: cast_nullable_to_non_nullable
                      as double,
            notes: null == notes
                ? _value.notes
                : notes // ignore: cast_nullable_to_non_nullable
                      as String,
          )
          as $Val,
    );
  }
}

/// @nodoc
abstract class _$$TopicProgressImplCopyWith<$Res>
    implements $TopicProgressCopyWith<$Res> {
  factory _$$TopicProgressImplCopyWith(
    _$TopicProgressImpl value,
    $Res Function(_$TopicProgressImpl) then,
  ) = __$$TopicProgressImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call({
    String topic,
    int lessonsCount,
    String level,
    double proficiency,
    String notes,
  });
}

/// @nodoc
class __$$TopicProgressImplCopyWithImpl<$Res>
    extends _$TopicProgressCopyWithImpl<$Res, _$TopicProgressImpl>
    implements _$$TopicProgressImplCopyWith<$Res> {
  __$$TopicProgressImplCopyWithImpl(
    _$TopicProgressImpl _value,
    $Res Function(_$TopicProgressImpl) _then,
  ) : super(_value, _then);

  /// Create a copy of TopicProgress
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? topic = null,
    Object? lessonsCount = null,
    Object? level = null,
    Object? proficiency = null,
    Object? notes = null,
  }) {
    return _then(
      _$TopicProgressImpl(
        topic: null == topic
            ? _value.topic
            : topic // ignore: cast_nullable_to_non_nullable
                  as String,
        lessonsCount: null == lessonsCount
            ? _value.lessonsCount
            : lessonsCount // ignore: cast_nullable_to_non_nullable
                  as int,
        level: null == level
            ? _value.level
            : level // ignore: cast_nullable_to_non_nullable
                  as String,
        proficiency: null == proficiency
            ? _value.proficiency
            : proficiency // ignore: cast_nullable_to_non_nullable
                  as double,
        notes: null == notes
            ? _value.notes
            : notes // ignore: cast_nullable_to_non_nullable
                  as String,
      ),
    );
  }
}

/// @nodoc
@JsonSerializable()
class _$TopicProgressImpl implements _TopicProgress {
  const _$TopicProgressImpl({
    required this.topic,
    required this.lessonsCount,
    required this.level,
    required this.proficiency,
    this.notes = '',
  });

  factory _$TopicProgressImpl.fromJson(Map<String, dynamic> json) =>
      _$$TopicProgressImplFromJson(json);

  @override
  final String topic;
  @override
  final int lessonsCount;
  @override
  final String level;
  // "Başlangıç", "Orta", "İleri"
  @override
  final double proficiency;
  // 0.0 - 1.0
  @override
  @JsonKey()
  final String notes;

  @override
  String toString() {
    return 'TopicProgress(topic: $topic, lessonsCount: $lessonsCount, level: $level, proficiency: $proficiency, notes: $notes)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$TopicProgressImpl &&
            (identical(other.topic, topic) || other.topic == topic) &&
            (identical(other.lessonsCount, lessonsCount) ||
                other.lessonsCount == lessonsCount) &&
            (identical(other.level, level) || other.level == level) &&
            (identical(other.proficiency, proficiency) ||
                other.proficiency == proficiency) &&
            (identical(other.notes, notes) || other.notes == notes));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode =>
      Object.hash(runtimeType, topic, lessonsCount, level, proficiency, notes);

  /// Create a copy of TopicProgress
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$TopicProgressImplCopyWith<_$TopicProgressImpl> get copyWith =>
      __$$TopicProgressImplCopyWithImpl<_$TopicProgressImpl>(this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$$TopicProgressImplToJson(this);
  }
}

abstract class _TopicProgress implements TopicProgress {
  const factory _TopicProgress({
    required final String topic,
    required final int lessonsCount,
    required final String level,
    required final double proficiency,
    final String notes,
  }) = _$TopicProgressImpl;

  factory _TopicProgress.fromJson(Map<String, dynamic> json) =
      _$TopicProgressImpl.fromJson;

  @override
  String get topic;
  @override
  int get lessonsCount;
  @override
  String get level; // "Başlangıç", "Orta", "İleri"
  @override
  double get proficiency; // 0.0 - 1.0
  @override
  String get notes;

  /// Create a copy of TopicProgress
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$TopicProgressImplCopyWith<_$TopicProgressImpl> get copyWith =>
      throw _privateConstructorUsedError;
}

StudentReport _$StudentReportFromJson(Map<String, dynamic> json) {
  return _StudentReport.fromJson(json);
}

/// @nodoc
mixin _$StudentReport {
  String get id => throw _privateConstructorUsedError;
  String get teacherId => throw _privateConstructorUsedError;
  String get studentId => throw _privateConstructorUsedError;
  String get studentName => throw _privateConstructorUsedError;
  String get teacherName => throw _privateConstructorUsedError;
  DateTime get reportDate => throw _privateConstructorUsedError;
  String get period =>
      throw _privateConstructorUsedError; // "Eylül 2026", "Ağustos 2026"
  int get totalLessons => throw _privateConstructorUsedError;
  int get totalHours => throw _privateConstructorUsedError;
  List<TopicProgress> get topicProgress => throw _privateConstructorUsedError;
  String get overallFeedback => throw _privateConstructorUsedError;
  List<String> get strengths => throw _privateConstructorUsedError;
  List<String> get areasForImprovement => throw _privateConstructorUsedError;
  Map<String, int> get monthlyLessonCount => throw _privateConstructorUsedError;
  double get averageScore => throw _privateConstructorUsedError;
  String get reportType =>
      throw _privateConstructorUsedError; // "progress_report" veya "certificate"
  String? get certificateId =>
      throw _privateConstructorUsedError; // "DK-2026-CERT-01"
  String get title => throw _privateConstructorUsedError;
  DateTime? get createdAt => throw _privateConstructorUsedError;

  /// Serializes this StudentReport to a JSON map.
  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;

  /// Create a copy of StudentReport
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $StudentReportCopyWith<StudentReport> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $StudentReportCopyWith<$Res> {
  factory $StudentReportCopyWith(
    StudentReport value,
    $Res Function(StudentReport) then,
  ) = _$StudentReportCopyWithImpl<$Res, StudentReport>;
  @useResult
  $Res call({
    String id,
    String teacherId,
    String studentId,
    String studentName,
    String teacherName,
    DateTime reportDate,
    String period,
    int totalLessons,
    int totalHours,
    List<TopicProgress> topicProgress,
    String overallFeedback,
    List<String> strengths,
    List<String> areasForImprovement,
    Map<String, int> monthlyLessonCount,
    double averageScore,
    String reportType,
    String? certificateId,
    String title,
    DateTime? createdAt,
  });
}

/// @nodoc
class _$StudentReportCopyWithImpl<$Res, $Val extends StudentReport>
    implements $StudentReportCopyWith<$Res> {
  _$StudentReportCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of StudentReport
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? teacherId = null,
    Object? studentId = null,
    Object? studentName = null,
    Object? teacherName = null,
    Object? reportDate = null,
    Object? period = null,
    Object? totalLessons = null,
    Object? totalHours = null,
    Object? topicProgress = null,
    Object? overallFeedback = null,
    Object? strengths = null,
    Object? areasForImprovement = null,
    Object? monthlyLessonCount = null,
    Object? averageScore = null,
    Object? reportType = null,
    Object? certificateId = freezed,
    Object? title = null,
    Object? createdAt = freezed,
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
            studentId: null == studentId
                ? _value.studentId
                : studentId // ignore: cast_nullable_to_non_nullable
                      as String,
            studentName: null == studentName
                ? _value.studentName
                : studentName // ignore: cast_nullable_to_non_nullable
                      as String,
            teacherName: null == teacherName
                ? _value.teacherName
                : teacherName // ignore: cast_nullable_to_non_nullable
                      as String,
            reportDate: null == reportDate
                ? _value.reportDate
                : reportDate // ignore: cast_nullable_to_non_nullable
                      as DateTime,
            period: null == period
                ? _value.period
                : period // ignore: cast_nullable_to_non_nullable
                      as String,
            totalLessons: null == totalLessons
                ? _value.totalLessons
                : totalLessons // ignore: cast_nullable_to_non_nullable
                      as int,
            totalHours: null == totalHours
                ? _value.totalHours
                : totalHours // ignore: cast_nullable_to_non_nullable
                      as int,
            topicProgress: null == topicProgress
                ? _value.topicProgress
                : topicProgress // ignore: cast_nullable_to_non_nullable
                      as List<TopicProgress>,
            overallFeedback: null == overallFeedback
                ? _value.overallFeedback
                : overallFeedback // ignore: cast_nullable_to_non_nullable
                      as String,
            strengths: null == strengths
                ? _value.strengths
                : strengths // ignore: cast_nullable_to_non_nullable
                      as List<String>,
            areasForImprovement: null == areasForImprovement
                ? _value.areasForImprovement
                : areasForImprovement // ignore: cast_nullable_to_non_nullable
                      as List<String>,
            monthlyLessonCount: null == monthlyLessonCount
                ? _value.monthlyLessonCount
                : monthlyLessonCount // ignore: cast_nullable_to_non_nullable
                      as Map<String, int>,
            averageScore: null == averageScore
                ? _value.averageScore
                : averageScore // ignore: cast_nullable_to_non_nullable
                      as double,
            reportType: null == reportType
                ? _value.reportType
                : reportType // ignore: cast_nullable_to_non_nullable
                      as String,
            certificateId: freezed == certificateId
                ? _value.certificateId
                : certificateId // ignore: cast_nullable_to_non_nullable
                      as String?,
            title: null == title
                ? _value.title
                : title // ignore: cast_nullable_to_non_nullable
                      as String,
            createdAt: freezed == createdAt
                ? _value.createdAt
                : createdAt // ignore: cast_nullable_to_non_nullable
                      as DateTime?,
          )
          as $Val,
    );
  }
}

/// @nodoc
abstract class _$$StudentReportImplCopyWith<$Res>
    implements $StudentReportCopyWith<$Res> {
  factory _$$StudentReportImplCopyWith(
    _$StudentReportImpl value,
    $Res Function(_$StudentReportImpl) then,
  ) = __$$StudentReportImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call({
    String id,
    String teacherId,
    String studentId,
    String studentName,
    String teacherName,
    DateTime reportDate,
    String period,
    int totalLessons,
    int totalHours,
    List<TopicProgress> topicProgress,
    String overallFeedback,
    List<String> strengths,
    List<String> areasForImprovement,
    Map<String, int> monthlyLessonCount,
    double averageScore,
    String reportType,
    String? certificateId,
    String title,
    DateTime? createdAt,
  });
}

/// @nodoc
class __$$StudentReportImplCopyWithImpl<$Res>
    extends _$StudentReportCopyWithImpl<$Res, _$StudentReportImpl>
    implements _$$StudentReportImplCopyWith<$Res> {
  __$$StudentReportImplCopyWithImpl(
    _$StudentReportImpl _value,
    $Res Function(_$StudentReportImpl) _then,
  ) : super(_value, _then);

  /// Create a copy of StudentReport
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? teacherId = null,
    Object? studentId = null,
    Object? studentName = null,
    Object? teacherName = null,
    Object? reportDate = null,
    Object? period = null,
    Object? totalLessons = null,
    Object? totalHours = null,
    Object? topicProgress = null,
    Object? overallFeedback = null,
    Object? strengths = null,
    Object? areasForImprovement = null,
    Object? monthlyLessonCount = null,
    Object? averageScore = null,
    Object? reportType = null,
    Object? certificateId = freezed,
    Object? title = null,
    Object? createdAt = freezed,
  }) {
    return _then(
      _$StudentReportImpl(
        id: null == id
            ? _value.id
            : id // ignore: cast_nullable_to_non_nullable
                  as String,
        teacherId: null == teacherId
            ? _value.teacherId
            : teacherId // ignore: cast_nullable_to_non_nullable
                  as String,
        studentId: null == studentId
            ? _value.studentId
            : studentId // ignore: cast_nullable_to_non_nullable
                  as String,
        studentName: null == studentName
            ? _value.studentName
            : studentName // ignore: cast_nullable_to_non_nullable
                  as String,
        teacherName: null == teacherName
            ? _value.teacherName
            : teacherName // ignore: cast_nullable_to_non_nullable
                  as String,
        reportDate: null == reportDate
            ? _value.reportDate
            : reportDate // ignore: cast_nullable_to_non_nullable
                  as DateTime,
        period: null == period
            ? _value.period
            : period // ignore: cast_nullable_to_non_nullable
                  as String,
        totalLessons: null == totalLessons
            ? _value.totalLessons
            : totalLessons // ignore: cast_nullable_to_non_nullable
                  as int,
        totalHours: null == totalHours
            ? _value.totalHours
            : totalHours // ignore: cast_nullable_to_non_nullable
                  as int,
        topicProgress: null == topicProgress
            ? _value._topicProgress
            : topicProgress // ignore: cast_nullable_to_non_nullable
                  as List<TopicProgress>,
        overallFeedback: null == overallFeedback
            ? _value.overallFeedback
            : overallFeedback // ignore: cast_nullable_to_non_nullable
                  as String,
        strengths: null == strengths
            ? _value._strengths
            : strengths // ignore: cast_nullable_to_non_nullable
                  as List<String>,
        areasForImprovement: null == areasForImprovement
            ? _value._areasForImprovement
            : areasForImprovement // ignore: cast_nullable_to_non_nullable
                  as List<String>,
        monthlyLessonCount: null == monthlyLessonCount
            ? _value._monthlyLessonCount
            : monthlyLessonCount // ignore: cast_nullable_to_non_nullable
                  as Map<String, int>,
        averageScore: null == averageScore
            ? _value.averageScore
            : averageScore // ignore: cast_nullable_to_non_nullable
                  as double,
        reportType: null == reportType
            ? _value.reportType
            : reportType // ignore: cast_nullable_to_non_nullable
                  as String,
        certificateId: freezed == certificateId
            ? _value.certificateId
            : certificateId // ignore: cast_nullable_to_non_nullable
                  as String?,
        title: null == title
            ? _value.title
            : title // ignore: cast_nullable_to_non_nullable
                  as String,
        createdAt: freezed == createdAt
            ? _value.createdAt
            : createdAt // ignore: cast_nullable_to_non_nullable
                  as DateTime?,
      ),
    );
  }
}

/// @nodoc
@JsonSerializable()
class _$StudentReportImpl extends _StudentReport {
  const _$StudentReportImpl({
    required this.id,
    required this.teacherId,
    required this.studentId,
    required this.studentName,
    this.teacherName = '',
    required this.reportDate,
    required this.period,
    required this.totalLessons,
    required this.totalHours,
    required final List<TopicProgress> topicProgress,
    required this.overallFeedback,
    required final List<String> strengths,
    required final List<String> areasForImprovement,
    final Map<String, int> monthlyLessonCount = const {},
    this.averageScore = 0.0,
    this.reportType = 'progress_report',
    this.certificateId,
    this.title = 'Aylık İlerleme Raporu',
    this.createdAt,
  }) : _topicProgress = topicProgress,
       _strengths = strengths,
       _areasForImprovement = areasForImprovement,
       _monthlyLessonCount = monthlyLessonCount,
       super._();

  factory _$StudentReportImpl.fromJson(Map<String, dynamic> json) =>
      _$$StudentReportImplFromJson(json);

  @override
  final String id;
  @override
  final String teacherId;
  @override
  final String studentId;
  @override
  final String studentName;
  @override
  @JsonKey()
  final String teacherName;
  @override
  final DateTime reportDate;
  @override
  final String period;
  // "Eylül 2026", "Ağustos 2026"
  @override
  final int totalLessons;
  @override
  final int totalHours;
  final List<TopicProgress> _topicProgress;
  @override
  List<TopicProgress> get topicProgress {
    if (_topicProgress is EqualUnmodifiableListView) return _topicProgress;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableListView(_topicProgress);
  }

  @override
  final String overallFeedback;
  final List<String> _strengths;
  @override
  List<String> get strengths {
    if (_strengths is EqualUnmodifiableListView) return _strengths;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableListView(_strengths);
  }

  final List<String> _areasForImprovement;
  @override
  List<String> get areasForImprovement {
    if (_areasForImprovement is EqualUnmodifiableListView)
      return _areasForImprovement;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableListView(_areasForImprovement);
  }

  final Map<String, int> _monthlyLessonCount;
  @override
  @JsonKey()
  Map<String, int> get monthlyLessonCount {
    if (_monthlyLessonCount is EqualUnmodifiableMapView)
      return _monthlyLessonCount;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableMapView(_monthlyLessonCount);
  }

  @override
  @JsonKey()
  final double averageScore;
  @override
  @JsonKey()
  final String reportType;
  // "progress_report" veya "certificate"
  @override
  final String? certificateId;
  // "DK-2026-CERT-01"
  @override
  @JsonKey()
  final String title;
  @override
  final DateTime? createdAt;

  @override
  String toString() {
    return 'StudentReport(id: $id, teacherId: $teacherId, studentId: $studentId, studentName: $studentName, teacherName: $teacherName, reportDate: $reportDate, period: $period, totalLessons: $totalLessons, totalHours: $totalHours, topicProgress: $topicProgress, overallFeedback: $overallFeedback, strengths: $strengths, areasForImprovement: $areasForImprovement, monthlyLessonCount: $monthlyLessonCount, averageScore: $averageScore, reportType: $reportType, certificateId: $certificateId, title: $title, createdAt: $createdAt)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$StudentReportImpl &&
            (identical(other.id, id) || other.id == id) &&
            (identical(other.teacherId, teacherId) ||
                other.teacherId == teacherId) &&
            (identical(other.studentId, studentId) ||
                other.studentId == studentId) &&
            (identical(other.studentName, studentName) ||
                other.studentName == studentName) &&
            (identical(other.teacherName, teacherName) ||
                other.teacherName == teacherName) &&
            (identical(other.reportDate, reportDate) ||
                other.reportDate == reportDate) &&
            (identical(other.period, period) || other.period == period) &&
            (identical(other.totalLessons, totalLessons) ||
                other.totalLessons == totalLessons) &&
            (identical(other.totalHours, totalHours) ||
                other.totalHours == totalHours) &&
            const DeepCollectionEquality().equals(
              other._topicProgress,
              _topicProgress,
            ) &&
            (identical(other.overallFeedback, overallFeedback) ||
                other.overallFeedback == overallFeedback) &&
            const DeepCollectionEquality().equals(
              other._strengths,
              _strengths,
            ) &&
            const DeepCollectionEquality().equals(
              other._areasForImprovement,
              _areasForImprovement,
            ) &&
            const DeepCollectionEquality().equals(
              other._monthlyLessonCount,
              _monthlyLessonCount,
            ) &&
            (identical(other.averageScore, averageScore) ||
                other.averageScore == averageScore) &&
            (identical(other.reportType, reportType) ||
                other.reportType == reportType) &&
            (identical(other.certificateId, certificateId) ||
                other.certificateId == certificateId) &&
            (identical(other.title, title) || other.title == title) &&
            (identical(other.createdAt, createdAt) ||
                other.createdAt == createdAt));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode => Object.hashAll([
    runtimeType,
    id,
    teacherId,
    studentId,
    studentName,
    teacherName,
    reportDate,
    period,
    totalLessons,
    totalHours,
    const DeepCollectionEquality().hash(_topicProgress),
    overallFeedback,
    const DeepCollectionEquality().hash(_strengths),
    const DeepCollectionEquality().hash(_areasForImprovement),
    const DeepCollectionEquality().hash(_monthlyLessonCount),
    averageScore,
    reportType,
    certificateId,
    title,
    createdAt,
  ]);

  /// Create a copy of StudentReport
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$StudentReportImplCopyWith<_$StudentReportImpl> get copyWith =>
      __$$StudentReportImplCopyWithImpl<_$StudentReportImpl>(this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$$StudentReportImplToJson(this);
  }
}

abstract class _StudentReport extends StudentReport {
  const factory _StudentReport({
    required final String id,
    required final String teacherId,
    required final String studentId,
    required final String studentName,
    final String teacherName,
    required final DateTime reportDate,
    required final String period,
    required final int totalLessons,
    required final int totalHours,
    required final List<TopicProgress> topicProgress,
    required final String overallFeedback,
    required final List<String> strengths,
    required final List<String> areasForImprovement,
    final Map<String, int> monthlyLessonCount,
    final double averageScore,
    final String reportType,
    final String? certificateId,
    final String title,
    final DateTime? createdAt,
  }) = _$StudentReportImpl;
  const _StudentReport._() : super._();

  factory _StudentReport.fromJson(Map<String, dynamic> json) =
      _$StudentReportImpl.fromJson;

  @override
  String get id;
  @override
  String get teacherId;
  @override
  String get studentId;
  @override
  String get studentName;
  @override
  String get teacherName;
  @override
  DateTime get reportDate;
  @override
  String get period; // "Eylül 2026", "Ağustos 2026"
  @override
  int get totalLessons;
  @override
  int get totalHours;
  @override
  List<TopicProgress> get topicProgress;
  @override
  String get overallFeedback;
  @override
  List<String> get strengths;
  @override
  List<String> get areasForImprovement;
  @override
  Map<String, int> get monthlyLessonCount;
  @override
  double get averageScore;
  @override
  String get reportType; // "progress_report" veya "certificate"
  @override
  String? get certificateId; // "DK-2026-CERT-01"
  @override
  String get title;
  @override
  DateTime? get createdAt;

  /// Create a copy of StudentReport
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$StudentReportImplCopyWith<_$StudentReportImpl> get copyWith =>
      throw _privateConstructorUsedError;
}
