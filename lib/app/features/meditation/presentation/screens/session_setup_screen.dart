import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:meditation_app/data/models/track_model.dart';
import 'package:meditation_app/presentation/state/track_provider.dart';
import 'package:meditation_app/core/constants/spacing.dart';
import 'package:meditation_app/core/theme/typography.dart';

class SessionSetupScreen extends ConsumerWidget {
  final String artistId;
  final String? trackId;

  const SessionSetupScreen({
    super.key,
    required this.artistId,
    this.trackId,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final trackAsync = trackId != null 
      ? ref.watch(trackByIdProvider(trackId!))
      : ref.watch(tracksByArtistProvider(artistId)).whenData((tracks) => tracks.firstOrNull);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Session Setup'),
        leading: IconButton(
          icon: const Icon(Icons.close),
          onPressed: () => context.pop(),
        ),
      ),
      body: trackAsync.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (error, stack) => Center(child: Text('Error: $error')),
        data: (track) => track == null 
          ? const Center(child: Text('No track available'))
          : _SessionSetupContent(track: track),
      ),
    );
  }
}

class _SessionSetupContent extends StatefulWidget {
  final Track track;

  const _SessionSetupContent({
    required this.track,
  });

  @override
  State<_SessionSetupContent> createState() => _SessionSetupContentState();
}

class _SessionSetupContentState extends State<_SessionSetupContent> {
  bool isGuidedMeditation = true;
  int selectedDuration = 10; // Default duration in minutes
  final List<int> availableDurations = [5, 10, 15, 20, 30];

  @override
  Widget build(BuildContext context) {
    return ListView(
      padding: const EdgeInsets.all(Spacing.large),
      children: [
        // Track info section
        Text(
          widget.track.title,
          style: AppTypography.headline2,
        ),
        const SizedBox(height: Spacing.small),
        Text(
          'Select your meditation preferences',
          style: AppTypography.body1,
        ),
        const SizedBox(height: Spacing.xxLarge),

        // Meditation type toggle
        Card(
          child: Padding(
            padding: const EdgeInsets.all(Spacing.medium),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Meditation Type',
                  style: AppTypography.headline3,
                ),
                const SizedBox(height: Spacing.medium),
                SwitchListTile(
                  contentPadding: EdgeInsets.zero,
                  title: const Text('Guided Meditation'),
                  subtitle: Text(isGuidedMeditation 
                    ? 'Meditation with voice guidance'
                    : 'Music only meditation'),
                  value: isGuidedMeditation,
                  onChanged: (value) => setState(() => isGuidedMeditation = value),
                ),
              ],
            ),
          ),
        ),
        
        const SizedBox(height: Spacing.large),

        // Duration selection
        Card(
          child: Padding(
            padding: const EdgeInsets.all(Spacing.medium),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Duration',
                  style: AppTypography.headline3,
                ),
                const SizedBox(height: Spacing.medium),
                Wrap(
                  spacing: Spacing.small,
                  children: availableDurations.map((duration) {
                    return ChoiceChip(
                      label: Text('$duration min'),
                      selected: selectedDuration == duration,
                      onSelected: (selected) {
                        if (selected) {
                          setState(() => selectedDuration = duration);
                        }
                      },
                    );
                  }).toList(),
                ),
              ],
            ),
          ),
        ),

        const SizedBox(height: Spacing.xxLarge),

        // Start button
        FilledButton.icon(
          onPressed: () {
            context.push('/meditation/${widget.track.id}', extra: {
              'isGuidedMeditation': isGuidedMeditation,
              'duration': selectedDuration,
            });
          },
          icon: const Icon(Icons.play_arrow),
          label: const Text('Start Meditation'),
        ),
      ],
    );
  }
} 