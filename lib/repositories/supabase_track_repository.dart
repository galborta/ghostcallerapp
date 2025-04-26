import 'package:supabase_flutter/supabase_flutter.dart';
import '../models/track_model.dart';
import '../exceptions/repository_exception.dart';
import 'track_repository.dart';

class SupabaseTrackRepository implements TrackRepository {
  final SupabaseClient _client;
  static const String _tableName = 'tracks';

  SupabaseTrackRepository(this._client);

  @override
  Future<List<Track>> getAllTracks() async {
    try {
      final response = await _client
          .from(_tableName)
          .select();

      if (response == null) {
        throw RepositoryException('Failed to get tracks: No data returned');
      }

      final List<dynamic> data = response as List<dynamic>;
      return data.map((json) => Track.fromJson(json)).toList();
    } catch (e) {
      throw RepositoryException('Failed to get tracks: ${e.toString()}');
    }
  }

  @override
  Future<Track> getTrackById(String id) async {
    try {
      final response = await _client
          .from(_tableName)
          .select()
          .eq('id', id)
          .single();

      if (response == null) {
        throw RepositoryException('Track not found');
      }

      return Track.fromJson(response as Map<String, dynamic>);
    } catch (e) {
      throw RepositoryException('Failed to get track: ${e.toString()}');
    }
  }

  @override
  Future<List<Track>> getTracksByArtist(String artist) async {
    try {
      final response = await _client
          .from(_tableName)
          .select()
          .eq('artist', artist);

      if (response == null) {
        throw RepositoryException('No tracks found for artist');
      }

      final List<dynamic> data = response as List<dynamic>;
      if (data.isEmpty) {
        throw RepositoryException('No tracks found for artist');
      }
      
      return data.map((json) => Track.fromJson(json)).toList();
    } catch (e) {
      throw RepositoryException('Failed to get tracks by artist: ${e.toString()}');
    }
  }
} 