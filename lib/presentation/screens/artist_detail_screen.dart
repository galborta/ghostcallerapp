import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:meditation_app/data/models/artist_model.dart';
import 'package:meditation_app/presentation/theme/spacing.dart';
import 'package:cached_network_image/cached_network_image.dart';

class ArtistDetailScreen extends ConsumerWidget {
  final String artistId;

  const ArtistDetailScreen({
    super.key,
    required this.artistId,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // TODO: Replace with actual artist provider
    final artist = Artist(
      id: artistId,
      name: 'Artist Name',
      bio: 'Full biography',
      shortBio: 'Short bio',
      imageUrl: 'https://example.com/image.jpg',
      featured: true,
      revenueSharePercentage: 50,
      referralCode: 'CODE123',
      createdAt: DateTime.now(),
      updatedAt: DateTime.now(),
    );

    return Scaffold(
      body: CustomScrollView(
        slivers: [
          _buildAppBar(context, artist),
          _buildContent(context, artist),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => context.push('/session-setup/$artistId'),
        label: const Text('Start Meditation'),
        icon: const Icon(Icons.play_arrow),
      ),
    );
  }

  Widget _buildAppBar(BuildContext context, Artist artist) {
    return SliverAppBar(
      expandedHeight: 300,
      pinned: true,
      flexibleSpace: FlexibleSpaceBar(
        title: Text(
          artist.name,
          style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                color: Colors.white,
                shadows: [
                  const Shadow(
                    offset: Offset(0, 1),
                    blurRadius: 3.0,
                    color: Color.fromARGB(255, 0, 0, 0),
                  ),
                ],
              ),
        ),
        background: Stack(
          fit: StackFit.expand,
          children: [
            CachedNetworkImage(
              imageUrl: artist.imageUrl,
              fit: BoxFit.cover,
              placeholder: (context, url) => Container(
                color: Theme.of(context).colorScheme.surfaceVariant,
                child: const Center(
                  child: CircularProgressIndicator(),
                ),
              ),
              errorWidget: (context, url, error) => Container(
                color: Theme.of(context).colorScheme.surfaceVariant,
                child: Icon(
                  Icons.person,
                  size: 48,
                  color: Theme.of(context).colorScheme.onSurfaceVariant,
                ),
              ),
            ),
            // Gradient overlay for better text visibility
            DecoratedBox(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [
                    Colors.transparent,
                    Colors.black.withOpacity(0.7),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildContent(BuildContext context, Artist artist) {
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
          // TODO: Replace with actual tracks list
          const Center(
            child: Padding(
              padding: EdgeInsets.all(Spacing.large),
              child: Text('Coming soon...'),
            ),
          ),
          // Add extra padding at bottom for FAB
          const SizedBox(height: 80),
        ]),
      ),
    );
  }
} 