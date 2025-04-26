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
  bool enableReminders = true;
  bool enableBackgroundNoise = false;
  double volume = 0.8;

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
          'Duration: ${widget.track.duration} minutes',
          style: AppTypography.body1,
        ),
        const SizedBox(height: Spacing.xxLarge),

        // Settings section
        Text(
          'Session Settings',
          style: AppTypography.headline3,
        ),
        const SizedBox(height: Spacing.medium),
        
        // Volume control
        ListTile(
          contentPadding: EdgeInsets.zero,
          title: const Text('Volume'),
          subtitle: Slider(
            value: volume,
            onChanged: (value) => setState(() => volume = value),
            divisions: 10,
            label: '${(volume * 100).round()}%',
          ),
        ),
        
        // Reminders toggle
        SwitchListTile(
          contentPadding: EdgeInsets.zero,
          title: const Text('Enable Reminders'),
          subtitle: const Text('Get notified to stay focused'),
          value: enableReminders,
          onChanged: (value) => setState(() => enableReminders = value),
        ),
        
        // Background noise toggle
        SwitchListTile(
          contentPadding: EdgeInsets.zero,
          title: const Text('Background Noise'),
          subtitle: const Text('Add ambient sounds'),
          value: enableBackgroundNoise,
          onChanged: (value) => setState(() => enableBackgroundNoise = value),
        ),

        const SizedBox(height: Spacing.xxLarge),

        // Start button
        FilledButton.icon(
          onPressed: () {
            // TODO: Start meditation session
            context.push('/meditation/${widget.track.id}', extra: {
              'volume': volume,
              'enableReminders': enableReminders,
              'enableBackgroundNoise': enableBackgroundNoise,
            });
          },
          icon: const Icon(Icons.play_arrow),
          label: const Text('Start Meditation'),
        ),
      ],
    );
  }
} 