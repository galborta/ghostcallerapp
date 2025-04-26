// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'artist_model.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_$ArtistImpl _$$ArtistImplFromJson(Map<String, dynamic> json) => _$ArtistImpl(
      id: json['id'] as String,
      name: json['name'] as String,
      bio: json['bio'] as String,
      shortBio: json['short_bio'] as String,
      imageUrl: json['image_url'] as String,
      featured: json['featured'] as bool,
      revenueSharePercentage:
          (json['revenue_share_percentage'] as num).toDouble(),
      referralCode: json['referral_code'] as String,
      createdAt: DateTime.parse(json['created_at'] as String),
      updatedAt: DateTime.parse(json['updated_at'] as String),
    );

Map<String, dynamic> _$$ArtistImplToJson(_$ArtistImpl instance) =>
    <String, dynamic>{
      'id': instance.id,
      'name': instance.name,
      'bio': instance.bio,
      'short_bio': instance.shortBio,
      'image_url': instance.imageUrl,
      'featured': instance.featured,
      'revenue_share_percentage': instance.revenueSharePercentage,
      'referral_code': instance.referralCode,
      'created_at': instance.createdAt.toIso8601String(),
      'updated_at': instance.updatedAt.toIso8601String(),
    };
