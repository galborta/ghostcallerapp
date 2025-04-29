// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'meditation_session_model.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_$MeditationSessionRecordImpl _$$MeditationSessionRecordImplFromJson(
        Map<String, dynamic> json) =>
    _$MeditationSessionRecordImpl(
      id: json['id'] as String,
      userId: json['userId'] as String,
      trackId: json['trackId'] as String,
      startTime: DateTime.parse(json['startTime'] as String),
      endTime: DateTime.parse(json['endTime'] as String),
      duration: Duration(microseconds: (json['duration'] as num).toInt()),
      completedDuration:
          Duration(microseconds: (json['completedDuration'] as num).toInt()),
      wasCompleted: json['wasCompleted'] as bool,
      notes: json['notes'] as String?,
    );

Map<String, dynamic> _$$MeditationSessionRecordImplToJson(
        _$MeditationSessionRecordImpl instance) =>
    <String, dynamic>{
      'id': instance.id,
      'userId': instance.userId,
      'trackId': instance.trackId,
      'startTime': instance.startTime.toIso8601String(),
      'endTime': instance.endTime.toIso8601String(),
      'duration': instance.duration.inMicroseconds,
      'completedDuration': instance.completedDuration.inMicroseconds,
      'wasCompleted': instance.wasCompleted,
      'notes': instance.notes,
    };
