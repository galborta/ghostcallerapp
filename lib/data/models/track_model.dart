import 'package:freezed_annotation/freezed_annotation.dart';

part 'track_model.freezed.dart';
part 'track_model.g.dart';

@freezed
class Track with _$Track {
  const factory Track({
    required String id,
    required String title,
    String? description,
    @JsonKey(name: 'artist_id') required String artistId,
    @JsonKey(name: 'audio_url') required String audioUrl,
    @JsonKey(name: 'audio_storage_path') required String audioStoragePath,
    @JsonKey(name: 'cover_image_url') String? coverImageUrl,
    @JsonKey(name: 'cover_image_storage_path') String? coverImageStoragePath,
    required int duration,
    @JsonKey(name: 'is_guided') required bool isGuided,
    required String category,
    List<String>? tags,
    @JsonKey(name: 'is_premium') @Default(false) bool isPremium,
    double? price,
    @JsonKey(name: 'created_at') DateTime? createdAt,
    @JsonKey(name: 'updated_at') DateTime? updatedAt,
  }) = _Track;

  factory Track.fromJson(Map<String, dynamic> json) => _$TrackFromJson(json);
}

/// Extension methods for Track
extension TrackExtension on Track {
  /// Alias for isGuided to maintain consistency with naming in the app
  bool get isGuidedMeditation => isGuided;
} 