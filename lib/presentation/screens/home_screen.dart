import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../state/artist_provider.dart';
import '../widgets/artist_card.dart';
import '../theme/spacing.dart';

class HomeScreen extends ConsumerWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final searchTerm = ref.watch(searchTermProvider);
    final featuredArtistsAsync = ref.watch(featuredArtistsProvider);
    final filteredArtistsAsync = ref.watch(filteredArtistsProvider);

    return Scaffold(
      body: CustomScrollView(
        slivers: [
          SliverAppBar(
            floating: true,
            title: const Text('Meditation'),
            bottom: PreferredSize(
              preferredSize: const Size.fromHeight(60),
              child: Padding(
                padding: const EdgeInsets.all(Spacing.medium),
                child: SearchBar(
                  hintText: 'Search artists...',
                  onChanged: (value) => ref.read(searchTermProvider.notifier).state = value,
                ),
              ),
            ),
          ),
          SliverPadding(
            padding: const EdgeInsets.all(Spacing.medium),
            sliver: featuredArtistsAsync.when(
              loading: () => const SliverToBoxAdapter(
                child: Center(child: CircularProgressIndicator()),
              ),
              error: (error, stack) => SliverToBoxAdapter(
                child: Center(child: Text('Error: $error')),
              ),
              data: (featuredArtists) => featuredArtists.isEmpty
                  ? const SliverToBoxAdapter(
                      child: Center(child: Text('No featured artists')),
                    )
                  : SliverToBoxAdapter(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Featured Artists',
                            style: Theme.of(context).textTheme.headlineSmall,
                          ),
                          const SizedBox(height: Spacing.medium),
                          SizedBox(
                            height: 280,
                            child: ListView.separated(
                              scrollDirection: Axis.horizontal,
                              itemCount: featuredArtists.length,
                              separatorBuilder: (context, index) =>
                                  const SizedBox(width: Spacing.medium),
                              itemBuilder: (context, index) {
                                final artist = featuredArtists[index];
                                return SizedBox(
                                  width: 280,
                                  child: ArtistCard(
                                    artist: artist,
                                    onTap: () => context.push('/artist/${artist.id}'),
                                  ),
                                );
                              },
                            ),
                          ),
                        ],
                      ),
                    ),
            ),
          ),
          SliverPadding(
            padding: const EdgeInsets.all(Spacing.medium),
            sliver: filteredArtistsAsync.when(
              loading: () => const SliverToBoxAdapter(
                child: Center(child: CircularProgressIndicator()),
              ),
              error: (error, stack) => SliverToBoxAdapter(
                child: Center(child: Text('Error: $error')),
              ),
              data: (artists) => artists.isEmpty
                  ? SliverToBoxAdapter(
                      child: Center(
                        child: Text(
                          searchTerm.isEmpty
                              ? 'No artists available'
                              : 'No artists found for "$searchTerm"',
                        ),
                      ),
                    )
                  : SliverGrid(
                      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                        crossAxisCount: 2,
                        mainAxisSpacing: Spacing.medium,
                        crossAxisSpacing: Spacing.medium,
                        childAspectRatio: 0.8,
                      ),
                      delegate: SliverChildBuilderDelegate(
                        (context, index) {
                          final artist = artists[index];
                          return ArtistCard(
                            artist: artist,
                            onTap: () => context.push('/artist/${artist.id}'),
                          );
                        },
                        childCount: artists.length,
                      ),
                    ),
            ),
          ),
        ],
      ),
    );
  }
} 