import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:meditation_app/data/models/track_model.dart';
import 'package:meditation_app/presentation/state/meditation_provider.dart';
import 'package:meditation_app/presentation/state/track_provider.dart';
import 'package:meditation_app/core/constants/spacing.dart';
import 'package:meditation_app/core/theme/typography.dart';
import 'package:go_router/go_router.dart';
import 'dart:async';
import 'package:just_audio/just_audio.dart';
import 'dart:developer' as developer;

class MeditationPlayerScreen extends HookConsumerWidget {
  final String trackId;
  final bool isGuidedMeditation;
  final int durationMinutes;

  const MeditationPlayerScreen({
    super.key,
    required this.trackId,
    required this.isGuidedMeditation,
    required this.durationMinutes,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final trackAsync = ref.watch(trackByIdProvider(trackId));
    final meditationState = ref.watch(meditationStateProvider);
    final remainingTime = ref.watch(remainingTimeProvider);
    final volume = useState(0.8);
    final hasInitialized = useState(false);

    // Debug print for state changes
    useEffect(() {
      developer.log('Meditation state changed: $meditationState');
      developer.log('Remaining time: $remainingTime');
      return null;
    }, [meditationState, remainingTime]);

    // Handle playback control
    void handlePlaybackControl() async {
      final meditationService = ref.read(meditationServiceProvider.notifier);
      
      developer.log('Playback control pressed');
      developer.log('Current meditation state: $meditationState');
      
      try {
        if (meditationState == MeditationState.inProgress) {
          developer.log('Pausing session');
          await meditationService.pauseSession();
        } else if (meditationState == MeditationState.paused) {
          developer.log('Resuming session');
          await meditationService.resumeSession();
        }
      } catch (e) {
        developer.log('Error controlling playback: $e', error: e);
        if (context.mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Failed to control playback: ${e.toString()}'),
              backgroundColor: Theme.of(context).colorScheme.error,
            ),
          );
        }
      }
    }

    // Initialize meditation session when track is loaded
    useEffect(() {
      if (!hasInitialized.value && trackAsync.hasValue && trackAsync.value != null) {
        hasInitialized.value = true;
        developer.log('Initializing meditation session');
        Future.microtask(() async {
          try {
            final meditationService = ref.read(meditationServiceProvider.notifier);
            final track = trackAsync.value!;
            
            developer.log('Starting session with track: ${track.title}, audio URL: ${track.audioUrl}');
            await meditationService.startSession(
              track: track,
              duration: Duration(minutes: durationMinutes),
              volume: volume.value,
            );
          } catch (e) {
            developer.log('Error starting meditation: $e', error: e);
            if (context.mounted) {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text('Failed to start meditation: ${e.toString()}'),
                  backgroundColor: Theme.of(context).colorScheme.error,
                ),
              );
            }
          }
        });
      }
      return () {
        if (hasInitialized.value) {
          developer.log('Cleaning up meditation session');
          ref.read(meditationServiceProvider.notifier).cancelSession();
        }
      };
    }, [trackAsync.value]);

    // Listen to player state changes
    useEffect(() {
      developer.log('Setting up player state listener');
      final subscription = ref.read(audioServiceProvider).playerStateStream.listen((state) {
        developer.log('Player state changed: ${state.processingState}, playing: ${state.playing}');
        if (state.processingState == ProcessingState.completed) {
          developer.log('Meditation completed');
          ref.read(meditationServiceProvider.notifier).completeSession();
        }
      });
      return subscription.cancel;
    }, []);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Meditation'),
        leading: IconButton(
          icon: const Icon(Icons.close),
          onPressed: () async {
            if (await _showExitConfirmationDialog(context)) {
              final meditationService = ref.read(meditationServiceProvider.notifier);
              await meditationService.cancelSession();
              if (context.mounted) context.pop();
            }
          },
        ),
      ),
      body: trackAsync.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (error, stack) => Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                'Error loading meditation track',
                style: Theme.of(context).textTheme.titleLarge,
              ),
              const SizedBox(height: Spacing.medium),
              Text(
                error.toString(),
                style: Theme.of(context).textTheme.bodyMedium,
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: Spacing.large),
              FilledButton(
                onPressed: () => Navigator.of(context).pop(),
                child: const Text('Go Back'),
              ),
            ],
          ),
        ),
        data: (track) => track == null
          ? Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    'Track not found',
                    style: Theme.of(context).textTheme.titleLarge,
                  ),
                  const SizedBox(height: Spacing.large),
                  FilledButton(
                    onPressed: () => Navigator.of(context).pop(),
                    child: const Text('Go Back'),
                  ),
                ],
              ),
            )
          : SafeArea(
              child: Padding(
                padding: const EdgeInsets.all(Spacing.large),
                child: Column(
                  children: [
                    const Spacer(),
                    // Track info
                    Text(
                      track.title,
                      style: AppTypography.headline2,
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: Spacing.small),
                    Text(
                      isGuidedMeditation ? 'Guided Meditation' : 'Music Only',
                      style: AppTypography.body1,
                    ),
                    const Spacer(),

                    // Timer
                    const TimerDisplay(),
                    const Spacer(),

                    // Volume control
                    Card(
                      child: Padding(
                        padding: const EdgeInsets.all(Spacing.medium),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Volume',
                              style: AppTypography.headline3,
                            ),
                            const SizedBox(height: Spacing.medium),
                            Row(
                              children: [
                                const Icon(Icons.volume_down),
                                Expanded(
                                  child: Slider(
                                    value: volume.value,
                                    onChanged: (newVolume) {
                                      volume.value = newVolume;
                                      ref.read(audioServiceProvider).setVolume(newVolume);
                                    },
                                    divisions: 20,
                                  ),
                                ),
                                const Icon(Icons.volume_up),
                              ],
                            ),
                          ],
                        ),
                      ),
                    ),
                    const SizedBox(height: Spacing.xxLarge),

                    // Playback controls
                    FloatingActionButton.large(
                      onPressed: handlePlaybackControl,
                      child: Icon(
                        meditationState == MeditationState.inProgress 
                          ? Icons.pause
                          : Icons.play_arrow,
                        size: 48,
                      ),
                    ),
                    const SizedBox(height: Spacing.xxLarge),
                  ],
                ),
              ),
            ),
      ),
    );
  }

  String _formatDuration(Duration duration) {
    String twoDigits(int n) => n.toString().padLeft(2, '0');
    final minutes = twoDigits(duration.inMinutes.remainder(60));
    final seconds = twoDigits(duration.inSeconds.remainder(60));
    return '$minutes:$seconds';
  }

  Future<bool> _showExitConfirmationDialog(BuildContext context) async {
    return await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Exit Meditation?'),
        content: const Text('Are you sure you want to end your meditation session?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: const Text('Cancel'),
          ),
          FilledButton(
            onPressed: () => Navigator.of(context).pop(true),
            child: const Text('Exit'),
          ),
        ],
      ),
    ) ?? false;
  }
}

// Timer
class TimerDisplay extends ConsumerStatefulWidget {
  const TimerDisplay({super.key});

  @override
  ConsumerState<TimerDisplay> createState() => _TimerDisplayState();
}

class _TimerDisplayState extends ConsumerState<TimerDisplay> {
  @override
  Widget build(BuildContext context) {
    // Watch both remaining time and position stream
    final remainingTime = ref.watch(remainingTimeProvider);
    ref.watch(positionStreamProvider).whenData((_) {});
    
    return Text(
      _formatDuration(remainingTime),
      style: AppTypography.headline1.copyWith(
        fontSize: 72,
        fontWeight: FontWeight.w300,
      ),
    );
  }

  String _formatDuration(Duration duration) {
    String twoDigits(int n) => n.toString().padLeft(2, '0');
    final minutes = twoDigits(duration.inMinutes.remainder(60));
    final seconds = twoDigits(duration.inSeconds.remainder(60));
    return '$minutes:$seconds';
  }
}