// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'meditation_session_model.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

T _$identity<T>(T value) => value;

final _privateConstructorUsedError = UnsupportedError(
    'It seems like you constructed your class using `MyClass._()`. This constructor is only meant to be used by freezed and you are not supposed to need it nor use it.\nPlease check the documentation here for more information: https://github.com/rrousselGit/freezed#adding-getters-and-methods-to-our-models');

MeditationSessionRecord _$MeditationSessionRecordFromJson(
    Map<String, dynamic> json) {
  return _MeditationSessionRecord.fromJson(json);
}

/// @nodoc
mixin _$MeditationSessionRecord {
  String get id => throw _privateConstructorUsedError;
  String get userId => throw _privateConstructorUsedError;
  String get trackId => throw _privateConstructorUsedError;
  DateTime get startTime => throw _privateConstructorUsedError;
  DateTime get endTime => throw _privateConstructorUsedError;
  Duration get duration => throw _privateConstructorUsedError;
  Duration get completedDuration => throw _privateConstructorUsedError;
  bool get wasCompleted => throw _privateConstructorUsedError;
  String? get notes => throw _privateConstructorUsedError;

  /// Serializes this MeditationSessionRecord to a JSON map.
  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;

  /// Create a copy of MeditationSessionRecord
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $MeditationSessionRecordCopyWith<MeditationSessionRecord> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $MeditationSessionRecordCopyWith<$Res> {
  factory $MeditationSessionRecordCopyWith(MeditationSessionRecord value,
          $Res Function(MeditationSessionRecord) then) =
      _$MeditationSessionRecordCopyWithImpl<$Res, MeditationSessionRecord>;
  @useResult
  $Res call(
      {String id,
      String userId,
      String trackId,
      DateTime startTime,
      DateTime endTime,
      Duration duration,
      Duration completedDuration,
      bool wasCompleted,
      String? notes});
}

/// @nodoc
class _$MeditationSessionRecordCopyWithImpl<$Res,
        $Val extends MeditationSessionRecord>
    implements $MeditationSessionRecordCopyWith<$Res> {
  _$MeditationSessionRecordCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of MeditationSessionRecord
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? userId = null,
    Object? trackId = null,
    Object? startTime = null,
    Object? endTime = null,
    Object? duration = null,
    Object? completedDuration = null,
    Object? wasCompleted = null,
    Object? notes = freezed,
  }) {
    return _then(_value.copyWith(
      id: null == id
          ? _value.id
          : id // ignore: cast_nullable_to_non_nullable
              as String,
      userId: null == userId
          ? _value.userId
          : userId // ignore: cast_nullable_to_non_nullable
              as String,
      trackId: null == trackId
          ? _value.trackId
          : trackId // ignore: cast_nullable_to_non_nullable
              as String,
      startTime: null == startTime
          ? _value.startTime
          : startTime // ignore: cast_nullable_to_non_nullable
              as DateTime,
      endTime: null == endTime
          ? _value.endTime
          : endTime // ignore: cast_nullable_to_non_nullable
              as DateTime,
      duration: null == duration
          ? _value.duration
          : duration // ignore: cast_nullable_to_non_nullable
              as Duration,
      completedDuration: null == completedDuration
          ? _value.completedDuration
          : completedDuration // ignore: cast_nullable_to_non_nullable
              as Duration,
      wasCompleted: null == wasCompleted
          ? _value.wasCompleted
          : wasCompleted // ignore: cast_nullable_to_non_nullable
              as bool,
      notes: freezed == notes
          ? _value.notes
          : notes // ignore: cast_nullable_to_non_nullable
              as String?,
    ) as $Val);
  }
}

/// @nodoc
abstract class _$$MeditationSessionRecordImplCopyWith<$Res>
    implements $MeditationSessionRecordCopyWith<$Res> {
  factory _$$MeditationSessionRecordImplCopyWith(
          _$MeditationSessionRecordImpl value,
          $Res Function(_$MeditationSessionRecordImpl) then) =
      __$$MeditationSessionRecordImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call(
      {String id,
      String userId,
      String trackId,
      DateTime startTime,
      DateTime endTime,
      Duration duration,
      Duration completedDuration,
      bool wasCompleted,
      String? notes});
}

/// @nodoc
class __$$MeditationSessionRecordImplCopyWithImpl<$Res>
    extends _$MeditationSessionRecordCopyWithImpl<$Res,
        _$MeditationSessionRecordImpl>
    implements _$$MeditationSessionRecordImplCopyWith<$Res> {
  __$$MeditationSessionRecordImplCopyWithImpl(
      _$MeditationSessionRecordImpl _value,
      $Res Function(_$MeditationSessionRecordImpl) _then)
      : super(_value, _then);

  /// Create a copy of MeditationSessionRecord
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? userId = null,
    Object? trackId = null,
    Object? startTime = null,
    Object? endTime = null,
    Object? duration = null,
    Object? completedDuration = null,
    Object? wasCompleted = null,
    Object? notes = freezed,
  }) {
    return _then(_$MeditationSessionRecordImpl(
      id: null == id
          ? _value.id
          : id // ignore: cast_nullable_to_non_nullable
              as String,
      userId: null == userId
          ? _value.userId
          : userId // ignore: cast_nullable_to_non_nullable
              as String,
      trackId: null == trackId
          ? _value.trackId
          : trackId // ignore: cast_nullable_to_non_nullable
              as String,
      startTime: null == startTime
          ? _value.startTime
          : startTime // ignore: cast_nullable_to_non_nullable
              as DateTime,
      endTime: null == endTime
          ? _value.endTime
          : endTime // ignore: cast_nullable_to_non_nullable
              as DateTime,
      duration: null == duration
          ? _value.duration
          : duration // ignore: cast_nullable_to_non_nullable
              as Duration,
      completedDuration: null == completedDuration
          ? _value.completedDuration
          : completedDuration // ignore: cast_nullable_to_non_nullable
              as Duration,
      wasCompleted: null == wasCompleted
          ? _value.wasCompleted
          : wasCompleted // ignore: cast_nullable_to_non_nullable
              as bool,
      notes: freezed == notes
          ? _value.notes
          : notes // ignore: cast_nullable_to_non_nullable
              as String?,
    ));
  }
}

/// @nodoc
@JsonSerializable()
class _$MeditationSessionRecordImpl extends _MeditationSessionRecord {
  const _$MeditationSessionRecordImpl(
      {required this.id,
      required this.userId,
      required this.trackId,
      required this.startTime,
      required this.endTime,
      required this.duration,
      required this.completedDuration,
      required this.wasCompleted,
      this.notes})
      : super._();

  factory _$MeditationSessionRecordImpl.fromJson(Map<String, dynamic> json) =>
      _$$MeditationSessionRecordImplFromJson(json);

  @override
  final String id;
  @override
  final String userId;
  @override
  final String trackId;
  @override
  final DateTime startTime;
  @override
  final DateTime endTime;
  @override
  final Duration duration;
  @override
  final Duration completedDuration;
  @override
  final bool wasCompleted;
  @override
  final String? notes;

  @override
  String toString() {
    return 'MeditationSessionRecord(id: $id, userId: $userId, trackId: $trackId, startTime: $startTime, endTime: $endTime, duration: $duration, completedDuration: $completedDuration, wasCompleted: $wasCompleted, notes: $notes)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$MeditationSessionRecordImpl &&
            (identical(other.id, id) || other.id == id) &&
            (identical(other.userId, userId) || other.userId == userId) &&
            (identical(other.trackId, trackId) || other.trackId == trackId) &&
            (identical(other.startTime, startTime) ||
                other.startTime == startTime) &&
            (identical(other.endTime, endTime) || other.endTime == endTime) &&
            (identical(other.duration, duration) ||
                other.duration == duration) &&
            (identical(other.completedDuration, completedDuration) ||
                other.completedDuration == completedDuration) &&
            (identical(other.wasCompleted, wasCompleted) ||
                other.wasCompleted == wasCompleted) &&
            (identical(other.notes, notes) || other.notes == notes));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode => Object.hash(runtimeType, id, userId, trackId, startTime,
      endTime, duration, completedDuration, wasCompleted, notes);

  /// Create a copy of MeditationSessionRecord
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$MeditationSessionRecordImplCopyWith<_$MeditationSessionRecordImpl>
      get copyWith => __$$MeditationSessionRecordImplCopyWithImpl<
          _$MeditationSessionRecordImpl>(this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$$MeditationSessionRecordImplToJson(
      this,
    );
  }
}

abstract class _MeditationSessionRecord extends MeditationSessionRecord {
  const factory _MeditationSessionRecord(
      {required final String id,
      required final String userId,
      required final String trackId,
      required final DateTime startTime,
      required final DateTime endTime,
      required final Duration duration,
      required final Duration completedDuration,
      required final bool wasCompleted,
      final String? notes}) = _$MeditationSessionRecordImpl;
  const _MeditationSessionRecord._() : super._();

  factory _MeditationSessionRecord.fromJson(Map<String, dynamic> json) =
      _$MeditationSessionRecordImpl.fromJson;

  @override
  String get id;
  @override
  String get userId;
  @override
  String get trackId;
  @override
  DateTime get startTime;
  @override
  DateTime get endTime;
  @override
  Duration get duration;
  @override
  Duration get completedDuration;
  @override
  bool get wasCompleted;
  @override
  String? get notes;

  /// Create a copy of MeditationSessionRecord
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$MeditationSessionRecordImplCopyWith<_$MeditationSessionRecordImpl>
      get copyWith => throw _privateConstructorUsedError;
}
