// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'track_model.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_$TrackImpl _$$TrackImplFromJson(Map<String, dynamic> json) => _$TrackImpl(
      id: json['id'] as String,
      title: json['title'] as String,
      artistId: json['artistId'] as String,
      audioUrl: json['audioUrl'] as String,
      audioStoragePath: json['audioStoragePath'] as String,
      duration: (json['duration'] as num).toInt(),
      isGuided: json['isGuided'] as bool? ?? false,
      createdAt: DateTime.parse(json['createdAt'] as String),
      updatedAt: DateTime.parse(json['updatedAt'] as String),
    );

Map<String, dynamic> _$$TrackImplToJson(_$TrackImpl instance) =>
    <String, dynamic>{
      'id': instance.id,
      'title': instance.title,
      'artistId': instance.artistId,
      'audioUrl': instance.audioUrl,
      'audioStoragePath': instance.audioStoragePath,
      'duration': instance.duration,
      'isGuided': instance.isGuided,
      'createdAt': instance.createdAt.toIso8601String(),
      'updatedAt': instance.updatedAt.toIso8601String(),
    };
