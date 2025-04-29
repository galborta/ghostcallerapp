import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../data/models/artist_model.dart';
import '../../data/models/track_model.dart';
import '../state/artist_provider.dart';
import '../state/track_provider.dart';
import '../theme/spacing.dart';
import '../widgets/track_list_item.dart';
import 'package:cached_network_image/cached_network_image.dart';

class ArtistDetailScreen extends ConsumerWidget {
  final String artistId;

  const ArtistDetailScreen({
    super.key,
    required this.artistId,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final artistAsync = ref.watch(artistByIdProvider(artistId));
    final tracksAsync = ref.watch(tracksByArtistProvider(artistId));

    return Scaffold(
      body: artistAsync.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (error, stack) => Center(child: Text('Error: $error')),
        data: (artist) {
          if (artist == null) {
            return const Center(child: Text('Artist not found'));
          }
          return CustomScrollView(
            slivers: [
              _buildAppBar(context, artist),
              _buildContent(context, artist, tracksAsync),
            ],
          );
        },
      ),
    );
  }

  SliverAppBar _buildAppBar(BuildContext context, Artist artist) {
    return SliverAppBar(
      expandedHeight: 300,
      pinned: true,
      flexibleSpace: FlexibleSpaceBar(
        title: Text(artist.name),
        background: CachedNetworkImage(
          imageUrl: artist.imageUrl,
          fit: BoxFit.cover,
          placeholder: (context, url) => const Center(
            child: CircularProgressIndicator(),
          ),
          errorWidget: (context, url, error) => const Icon(Icons.error),
        ),
      ),
    );
  }

  Widget _buildContent(BuildContext context, Artist artist, AsyncValue<List<Track>> tracksAsync) {
    return SliverPadding(
      padding: const EdgeInsets.all(Spacing.medium),
      sliver: SliverList(
        delegate: SliverChildListDelegate([
          Text(
            artist.shortBio,
            style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                  color: Theme.of(context).colorScheme.onSurface,
                ),
          ),
          const SizedBox(height: Spacing.medium),
          Text(
            'Biography',
            style: Theme.of(context).textTheme.titleLarge?.copyWith(
                  color: Theme.of(context).colorScheme.primary,
                ),
          ),
          const SizedBox(height: Spacing.small),
          Text(
            artist.bio,
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  color: Theme.of(context).colorScheme.onSurfaceVariant,
                ),
          ),
          const SizedBox(height: Spacing.large),
          Text(
            'Meditation Tracks',
            style: Theme.of(context).textTheme.titleLarge?.copyWith(
                  color: Theme.of(context).colorScheme.primary,
                ),
          ),
          const SizedBox(height: Spacing.small),
          tracksAsync.when(
            loading: () => const Center(
              child: Padding(
                padding: EdgeInsets.all(Spacing.large),
                child: CircularProgressIndicator(),
              ),
            ),
            error: (error, stack) => Center(
              child: Padding(
                padding: const EdgeInsets.all(Spacing.large),
                child: Text('Error loading tracks: $error'),
              ),
            ),
            data: (tracks) => tracks.isEmpty
                ? const Center(
                    child: Padding(
                      padding: EdgeInsets.all(Spacing.large),
                      child: Text('No tracks available'),
                    ),
                  )
                : ListView.builder(
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    itemCount: tracks.length,
                    itemBuilder: (context, index) {
                      final track = tracks[index];
                      return TrackListItem(
                        track: track,
                        onTap: () => context.push('/session-setup/$artistId/${track.id}'),
                      );
                    },
                  ),
          ),
          // Add extra padding at bottom for FAB
          const SizedBox(height: 80),
        ]),
      ),
    );
  }
} 