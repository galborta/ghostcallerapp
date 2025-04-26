import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../data/repositories/artist_repository.dart';
import '../../data/repositories/supabase_artist_repository.dart';
import '../../data/models/artist_model.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

// Repository provider
final artistRepositoryProvider = Provider<ArtistRepository>((ref) {
  final supabase = Supabase.instance.client;
  return SupabaseArtistRepository(supabase);
});

// All artists provider
final artistsProvider = FutureProvider<List<Artist>>((ref) async {
  final repository = ref.watch(artistRepositoryProvider);
  return repository.getArtists();
});

// Featured artists provider
final featuredArtistsProvider = FutureProvider<List<Artist>>((ref) async {
  final repository = ref.watch(artistRepositoryProvider);
  return repository.getArtists(featured: true);
});

// Artist by ID provider
final artistByIdProvider = FutureProvider.family<Artist?, String>((ref, id) async {
  final repository = ref.watch(artistRepositoryProvider);
  return repository.getArtistById(id);
});

// Search term state provider
final searchTermProvider = StateProvider<String>((ref) => '');

// Artist search provider
final artistSearchProvider = FutureProvider<List<Artist>>((ref) async {
  final repository = ref.watch(artistRepositoryProvider);
  final searchTerm = ref.watch(searchTermProvider);
  
  if (searchTerm.isEmpty) {
    return repository.getArtists();
  }
  
  return repository.searchArtists(searchTerm);
});

// Filtered artists provider
final filteredArtistsProvider = Provider<AsyncValue<List<Artist>>>((ref) {
  final searchTerm = ref.watch(searchTermProvider).toLowerCase();
  final artists = ref.watch(artistsProvider);
  
  return artists.when(
    data: (data) {
      if (searchTerm.isEmpty) {
        return AsyncValue.data(data);
      }
      
      final filtered = data.where((artist) {
        return artist.name.toLowerCase().contains(searchTerm) ||
               artist.bio.toLowerCase().contains(searchTerm) ||
               artist.shortBio.toLowerCase().contains(searchTerm);
      }).toList();
      
      return AsyncValue.data(filtered);
    },
    loading: () => const AsyncValue.loading(),
    error: (error, stackTrace) => AsyncValue.error(error, stackTrace),
  );
}); 