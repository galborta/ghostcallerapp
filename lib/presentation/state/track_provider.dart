import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../../data/models/track_model.dart';
import '../../data/repositories/track_repository.dart';
import '../../data/repositories/supabase_track_repository.dart';

/// Provider for the track repository implementation
final trackRepositoryProvider = Provider<TrackRepository>((ref) {
  final supabase = Supabase.instance.client;
  return SupabaseTrackRepository(supabase);
});

/// Provider for tracks by artist ID
final tracksByArtistProvider = FutureProvider.family<List<Track>, String>((ref, artistId) async {
  final repository = ref.watch(trackRepositoryProvider);
  return repository.getTracksByArtist(artistId);
});

/// Provider for track by ID
final trackByIdProvider = FutureProvider.family<Track?, String>((ref, id) async {
  final repository = ref.watch(trackRepositoryProvider);
  return repository.getTrackById(id);
}); 