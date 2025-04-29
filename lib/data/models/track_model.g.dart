// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'track_model.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_$TrackImpl _$$TrackImplFromJson(Map<String, dynamic> json) => _$TrackImpl(
      id: json['id'] as String,
      title: json['title'] as String,
      description: json['description'] as String?,
      artistId: json['artist_id'] as String,
      audioUrl: json['audio_url'] as String,
      audioStoragePath: json['audio_storage_path'] as String,
      coverImageUrl: json['cover_image_url'] as String?,
      coverImageStoragePath: json['cover_image_storage_path'] as String?,
      duration: (json['duration'] as num).toInt(),
      isGuided: json['is_guided'] as bool,
      category: json['category'] as String,
      tags: (json['tags'] as List<dynamic>?)?.map((e) => e as String).toList(),
      isPremium: json['is_premium'] as bool? ?? false,
      price: (json['price'] as num?)?.toDouble(),
      createdAt: json['created_at'] == null
          ? null
          : DateTime.parse(json['created_at'] as String),
      updatedAt: json['updated_at'] == null
          ? null
          : DateTime.parse(json['updated_at'] as String),
    );

Map<String, dynamic> _$$TrackImplToJson(_$TrackImpl instance) =>
    <String, dynamic>{
      'id': instance.id,
      'title': instance.title,
      'description': instance.description,
      'artist_id': instance.artistId,
      'audio_url': instance.audioUrl,
      'audio_storage_path': instance.audioStoragePath,
      'cover_image_url': instance.coverImageUrl,
      'cover_image_storage_path': instance.coverImageStoragePath,
      'duration': instance.duration,
      'is_guided': instance.isGuided,
      'category': instance.category,
      'tags': instance.tags,
      'is_premium': instance.isPremium,
      'price': instance.price,
      'created_at': instance.createdAt?.toIso8601String(),
      'updated_at': instance.updatedAt?.toIso8601String(),
    };
