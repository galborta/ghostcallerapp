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

MeditationSession _$MeditationSessionFromJson(Map<String, dynamic> json) {
  return _MeditationSession.fromJson(json);
}

/// @nodoc
mixin _$MeditationSession {
  String get id => throw _privateConstructorUsedError;
  String get userId => throw _privateConstructorUsedError;
  String get trackId => throw _privateConstructorUsedError;
  DateTime get startTime => throw _privateConstructorUsedError;
  DateTime get endTime => throw _privateConstructorUsedError;
  Duration get duration => throw _privateConstructorUsedError;
  bool get isCompleted => throw _privateConstructorUsedError;

  /// Serializes this MeditationSession to a JSON map.
  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;

  /// Create a copy of MeditationSession
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $MeditationSessionCopyWith<MeditationSession> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $MeditationSessionCopyWith<$Res> {
  factory $MeditationSessionCopyWith(
          MeditationSession value, $Res Function(MeditationSession) then) =
      _$MeditationSessionCopyWithImpl<$Res, MeditationSession>;
  @useResult
  $Res call(
      {String id,
      String userId,
      String trackId,
      DateTime startTime,
      DateTime endTime,
      Duration duration,
      bool isCompleted});
}

/// @nodoc
class _$MeditationSessionCopyWithImpl<$Res, $Val extends MeditationSession>
    implements $MeditationSessionCopyWith<$Res> {
  _$MeditationSessionCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of MeditationSession
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
    Object? isCompleted = null,
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
      isCompleted: null == isCompleted
          ? _value.isCompleted
          : isCompleted // ignore: cast_nullable_to_non_nullable
              as bool,
    ) as $Val);
  }
}

/// @nodoc
abstract class _$$MeditationSessionImplCopyWith<$Res>
    implements $MeditationSessionCopyWith<$Res> {
  factory _$$MeditationSessionImplCopyWith(_$MeditationSessionImpl value,
          $Res Function(_$MeditationSessionImpl) then) =
      __$$MeditationSessionImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call(
      {String id,
      String userId,
      String trackId,
      DateTime startTime,
      DateTime endTime,
      Duration duration,
      bool isCompleted});
}

/// @nodoc
class __$$MeditationSessionImplCopyWithImpl<$Res>
    extends _$MeditationSessionCopyWithImpl<$Res, _$MeditationSessionImpl>
    implements _$$MeditationSessionImplCopyWith<$Res> {
  __$$MeditationSessionImplCopyWithImpl(_$MeditationSessionImpl _value,
      $Res Function(_$MeditationSessionImpl) _then)
      : super(_value, _then);

  /// Create a copy of MeditationSession
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
    Object? isCompleted = null,
  }) {
    return _then(_$MeditationSessionImpl(
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
      isCompleted: null == isCompleted
          ? _value.isCompleted
          : isCompleted // ignore: cast_nullable_to_non_nullable
              as bool,
    ));
  }
}

/// @nodoc
@JsonSerializable()
class _$MeditationSessionImpl implements _MeditationSession {
  const _$MeditationSessionImpl(
      {required this.id,
      required this.userId,
      required this.trackId,
      required this.startTime,
      required this.endTime,
      required this.duration,
      required this.isCompleted});

  factory _$MeditationSessionImpl.fromJson(Map<String, dynamic> json) =>
      _$$MeditationSessionImplFromJson(json);

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
  final bool isCompleted;

  @override
  String toString() {
    return 'MeditationSession(id: $id, userId: $userId, trackId: $trackId, startTime: $startTime, endTime: $endTime, duration: $duration, isCompleted: $isCompleted)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$MeditationSessionImpl &&
            (identical(other.id, id) || other.id == id) &&
            (identical(other.userId, userId) || other.userId == userId) &&
            (identical(other.trackId, trackId) || other.trackId == trackId) &&
            (identical(other.startTime, startTime) ||
                other.startTime == startTime) &&
            (identical(other.endTime, endTime) || other.endTime == endTime) &&
            (identical(other.duration, duration) ||
                other.duration == duration) &&
            (identical(other.isCompleted, isCompleted) ||
                other.isCompleted == isCompleted));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode => Object.hash(runtimeType, id, userId, trackId, startTime,
      endTime, duration, isCompleted);

  /// Create a copy of MeditationSession
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$MeditationSessionImplCopyWith<_$MeditationSessionImpl> get copyWith =>
      __$$MeditationSessionImplCopyWithImpl<_$MeditationSessionImpl>(
          this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$$MeditationSessionImplToJson(
      this,
    );
  }
}

abstract class _MeditationSession implements MeditationSession {
  const factory _MeditationSession(
      {required final String id,
      required final String userId,
      required final String trackId,
      required final DateTime startTime,
      required final DateTime endTime,
      required final Duration duration,
      required final bool isCompleted}) = _$MeditationSessionImpl;

  factory _MeditationSession.fromJson(Map<String, dynamic> json) =
      _$MeditationSessionImpl.fromJson;

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
  bool get isCompleted;

  /// Create a copy of MeditationSession
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$MeditationSessionImplCopyWith<_$MeditationSessionImpl> get copyWith =>
      throw _privateConstructorUsedError;
}
