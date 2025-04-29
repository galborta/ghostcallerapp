import 'dart:io';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:path/path.dart' as path;
import '../models/track_model.dart';
import 'track_repository.dart';

/// Implementation of [TrackRepository] using Supabase
class SupabaseTrackRepository implements TrackRepository {
  final SupabaseClient _client;
  static const _maxRetries = 3;
  static const _retryDelay = Duration(seconds: 2);
  static const _tableName = 'meditation_tracks';
  
  /// Constructor
  SupabaseTrackRepository(this._client);

  /// Helper method to retry operations with exponential backoff
  Future<T> _retry<T>(Future<T> Function() operation) async {
    int attempts = 0;
    while (true) {
      try {
        attempts++;
        return await operation();
      } catch (e) {
        if (attempts >= _maxRetries) rethrow;
        await Future.delayed(_retryDelay * attempts);
      }
    }
  }

  @override
  Future<List<Track>> getTracksByArtist(String artistId) async {
    final response = await _client
        .from(_tableName)
        .select()
        .eq('artist_id', artistId);
    
    return response.map((json) => Track.fromJson(json)).toList();
  }

  @override
  Future<Track?> getTrackById(String id) async {
    final response = await _client
        .from(_tableName)
        .select()
        .eq('id', id)
        .limit(1);
    
    final results = await response;
    if (results.isEmpty) return null;
    return Track.fromJson(results.first);
  }

  @override
  Future<Track> uploadTrack({
    required String title,
    required String artistId,
    required String filePath,
    required bool isGuided,
    required int duration,
    String category = 'meditation',
    String? description,
    String? coverImagePath,
    List<String>? tags,
    bool isPremium = false,
    double? price,
  }) async {
    // 1. Upload the audio file to storage with retry
    final file = File(filePath);
    final fileName = path.basename(filePath);
    final storagePath = 'tracks/$artistId/${DateTime.now().millisecondsSinceEpoch}_$fileName';
    
    await _retry(() => _client.storage.from('audio').upload(
      storagePath,
      file,
      fileOptions: const FileOptions(
        cacheControl: '3600',
        upsert: true,
      ),
    ));

    // 2. Get the public URL for the uploaded file
    final audioUrl = _client.storage.from('audio').getPublicUrl(storagePath);

    // 3. Upload cover image if provided with retry
    String? coverImageUrl;
    String? coverImageStoragePath;
    if (coverImagePath != null) {
      final coverFile = File(coverImagePath);
      final coverFileName = path.basename(coverImagePath);
      coverImageStoragePath = 'artists/$artistId/${DateTime.now().millisecondsSinceEpoch}_$coverFileName';
      
      await _retry(() => _client.storage.from('images').upload(
        coverImageStoragePath!,
        coverFile,
        fileOptions: const FileOptions(
          cacheControl: '3600',
          upsert: true,
        ),
      ));

      coverImageUrl = _client.storage.from('images').getPublicUrl(coverImageStoragePath);
    }

    // 4. Create the track record in the database with retry
    final response = await _retry(() => _client
        .from(_tableName)
        .insert({
          'title': title,
          'artist_id': artistId,
          'audio_url': audioUrl,
          'audio_storage_path': storagePath,
          'duration': duration,
          'is_guided': isGuided,
          'category': category,
          'description': description,
          'cover_image_url': coverImageUrl,
          'cover_image_storage_path': coverImageStoragePath,
          'tags': tags,
          'is_premium': isPremium,
          'price': price,
          'created_at': DateTime.now().toIso8601String(),
          'updated_at': DateTime.now().toIso8601String(),
        })
        .select()
        .single());

    return Track.fromJson(response);
  }

  @override
  Future<void> deleteTrack(String id) async {
    // 1. Get the track to find its storage path
    final track = await getTrackById(id);
    if (track == null) {
      throw Exception('Track not found');
    }

    // 2. Delete the audio file from storage with retry
    await _retry(() => _client.storage.from('audio').remove([track.audioStoragePath]));

    // 3. Delete the cover image if it exists with retry
    if (track.coverImageUrl != null) {
      final coverImagePath = track.coverImageUrl!.split('/').last;
      await _retry(() => _client.storage.from('images').remove(['artists/${track.artistId}/$coverImagePath']));
    }

    // 4. Delete the database record with retry
    await _retry(() => _client
        .from(_tableName)
        .delete()
        .eq('id', id));
  }
} 