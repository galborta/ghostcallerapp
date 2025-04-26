import '../models/track_model.dart';

/// Abstract class defining the contract for track operations
abstract class TrackRepository {
  /// Get all tracks by a specific artist ID
  Future<List<Track>> getTracksByArtist(String artistId);

  /// Get a specific track by its ID
  Future<Track?> getTrackById(String id);

  /// Upload a track file and create a track record
  Future<Track> uploadTrack({
    required String title,
    required String artistId,
    required String filePath,
    required bool isGuided,
    required int duration,
    String category = 'meditation',
  });

  /// Delete a track and its associated file
  Future<void> deleteTrack(String id);
} 