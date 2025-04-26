import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:meditation_app/data/repositories/artist_repository.dart';
import 'package:meditation_app/data/models/artist_model.dart';

final artistRepositoryProvider = Provider<ArtistRepository>((ref) {
  throw UnimplementedError('Repository must be overridden in tests');
});

final searchTermProvider = StateProvider<String>((ref) => '');

final artistsProvider = FutureProvider<List<Artist>>((ref) async {
  final repository = ref.watch(artistRepositoryProvider);
  return repository.getArtists();
});

final featuredArtistsProvider = FutureProvider<List<Artist>>((ref) async {
  final repository = ref.watch(artistRepositoryProvider);
  return repository.getArtists(featured: true);
});

final artistByIdProvider = FutureProvider.family<Artist?, String>((ref, id) async {
  final repository = ref.watch(artistRepositoryProvider);
  return repository.getArtistById(id);
});

final artistSearchProvider = FutureProvider<List<Artist>>((ref) async {
  final repository = ref.watch(artistRepositoryProvider);
  final searchTerm = ref.watch(searchTermProvider);

  if (searchTerm.isEmpty) {
    return repository.getArtists();
  }

  return repository.searchArtists(searchTerm);
});

final filteredArtistsProvider = Provider<AsyncValue<List<Artist>>>((ref) {
  final artists = ref.watch(artistsProvider);
  final searchTerm = ref.watch(searchTermProvider).toLowerCase();

  return artists.when(
    data: (artists) {
      if (searchTerm.isEmpty) {
        return AsyncValue.data(artists);
      }

      final filtered = artists.where((artist) {
        final name = artist.name.toLowerCase();
        final bio = artist.bio.toLowerCase();
        return name.contains(searchTerm) || bio.contains(searchTerm);
      }).toList();

      return AsyncValue.data(filtered);
    },
    loading: () => const AsyncValue.loading(),
    error: (error, stack) => AsyncValue.error(error, stack),
  );
}); 