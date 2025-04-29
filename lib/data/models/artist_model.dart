import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:json_annotation/json_annotation.dart';

part 'artist_model.freezed.dart';
part 'artist_model.g.dart';

DateTime _dateTimeFromJson(String date) => DateTime.parse(date);
String _dateTimeToJson(DateTime date) => date.toIso8601String();

@freezed
class Artist with _$Artist {
  const factory Artist({
    required String id,
    required String name,
    required String bio,
    @JsonKey(name: 'short_bio') required String shortBio,
    @JsonKey(name: 'image_url') required String imageUrl,
    @Default(false) bool featured,
    @JsonKey(name: 'revenue_share_percentage') @Default(50) int revenueSharePercentage,
    @JsonKey(name: 'referral_code') required String referralCode,
    @JsonKey(name: 'created_at') required DateTime createdAt,
    @JsonKey(name: 'updated_at') required DateTime updatedAt,
  }) = _Artist;

  factory Artist.fromJson(Map<String, dynamic> json) => _$ArtistFromJson(json);
} 