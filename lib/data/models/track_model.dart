import 'package:freezed_annotation/freezed_annotation.dart';

part 'track_model.freezed.dart';
part 'track_model.g.dart';

@freezed
class Track with _$Track {
  const factory Track({
    required String id,
    required String title,
    required String artistId,
    required String audioUrl,
    required String audioStoragePath,
    required int duration,
    @Default(false) bool isGuided,
    required DateTime createdAt,
    required DateTime updatedAt,
  }) = _Track;

  factory Track.fromJson(Map<String, dynamic> json) => _$TrackFromJson(json);
} 