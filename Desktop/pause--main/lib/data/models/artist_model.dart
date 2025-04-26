import 'package:freezed_annotation/freezed_annotation.dart';

part 'artist_model.freezed.dart';
part 'artist_model.g.dart';

@freezed
class Artist with _$Artist {
  const factory Artist({
    @JsonKey(name: 'id') required String id,
    @JsonKey(name: 'name') required String name,
    @JsonKey(name: 'bio') required String bio,
    @JsonKey(name: 'short_bio') required String shortBio,
    @JsonKey(name: 'image_url') required String imageUrl,
    @JsonKey(name: 'featured') @Default(false) bool featured,
    @JsonKey(name: 'revenue_share_percentage') @Default(50) int revenueSharePercentage,
    @JsonKey(name: 'referral_code') required String referralCode,
    @JsonKey(name: 'created_at') required DateTime createdAt,
    @JsonKey(name: 'updated_at') required DateTime updatedAt,
  }) = _Artist;

  factory Artist.fromJson(Map<String, dynamic> json) => _$ArtistFromJson(json);
} 