// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'meditation_session_model.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_$MeditationSessionImpl _$$MeditationSessionImplFromJson(
        Map<String, dynamic> json) =>
    _$MeditationSessionImpl(
      id: json['id'] as String,
      userId: json['userId'] as String,
      trackId: json['trackId'] as String,
      startTime: DateTime.parse(json['startTime'] as String),
      endTime: DateTime.parse(json['endTime'] as String),
      duration: Duration(microseconds: (json['duration'] as num).toInt()),
      isCompleted: json['isCompleted'] as bool,
    );

Map<String, dynamic> _$$MeditationSessionImplToJson(
        _$MeditationSessionImpl instance) =>
    <String, dynamic>{
      'id': instance.id,
      'userId': instance.userId,
      'trackId': instance.trackId,
      'startTime': instance.startTime.toIso8601String(),
      'endTime': instance.endTime.toIso8601String(),
      'duration': instance.duration.inMicroseconds,
      'isCompleted': instance.isCompleted,
    };
