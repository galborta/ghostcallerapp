import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:just_audio/just_audio.dart';
import 'package:meditation_app/data/models/track_model.dart';
import 'package:meditation_app/data/services/audio_service.dart';
import 'dart:async';
import 'dart:developer' as developer;

/// Enum representing the different states of a meditation session
enum MeditationState {
  initial,    // Before meditation starts
  preparing,  // Loading audio and getting ready
  inProgress, // Meditation is ongoing
  paused,     // Meditation is paused
  completed,  // Meditation has finished
  error       // An error occurred
}

/// Class to manage the state of a meditation session
class MeditationSession {
  final Track track;
  final Duration duration;
  final DateTime startTime;
  final MeditationState state;
  final Duration currentPosition;
  final DateTime? endTime;
  final String? errorMessage;
  final Duration elapsedMeditationTime;

  MeditationSession({
    required this.track,
    required this.duration,
    required this.state,
    required this.startTime,
    this.currentPosition = Duration.zero,
    this.endTime,
    this.errorMessage,
    this.elapsedMeditationTime = Duration.zero,
  });

  Duration get remaining {
    if (state == MeditationState.completed) return Duration.zero;
    final timeLeft = duration - elapsedMeditationTime;
    return timeLeft.isNegative ? Duration.zero : timeLeft;
  }

  bool get isCompleted => state == MeditationState.completed;
  bool get isInProgress => state == MeditationState.inProgress;
  bool get isPaused => state == MeditationState.paused;
  bool get hasError => state == MeditationState.error;

  MeditationSession copyWith({
    Track? track,
    Duration? duration,
    MeditationState? state,
    DateTime? startTime,
    Duration? currentPosition,
    DateTime? endTime,
    String? errorMessage,
    Duration? elapsedMeditationTime,
  }) {
    return MeditationSession(
      track: track ?? this.track,
      duration: duration ?? this.duration,
      state: state ?? this.state,
      startTime: startTime ?? this.startTime,
      currentPosition: currentPosition ?? this.currentPosition,
      endTime: endTime ?? this.endTime,
      errorMessage: errorMessage ?? this.errorMessage,
      elapsedMeditationTime: elapsedMeditationTime ?? this.elapsedMeditationTime,
    );
  }
}

/// Service class to manage meditation sessions
class MeditationService extends StateNotifier<MeditationSession?> {
  final MeditationAudioService _audioService;
  StreamSubscription? _positionSubscription;
  Timer? _meditationTimer;

  MeditationService(this._audioService) : super(null);

  Future<void> startSession({
    required Track track,
    required Duration duration,
    double volume = 0.8,
  }) async {
    developer.log('Starting meditation session');
    developer.log('Track: ${track.title}, Duration: $duration, Volume: $volume');

    try {
      await cancelSession();
      
      final now = DateTime.now();
      state = MeditationSession(
        track: track,
        duration: duration,
        state: MeditationState.preparing,
        startTime: now,
      );
      
      await _audioService.loadTrack(
        trackUrl: track.audioUrl,
        isGuidedMeditation: track.isGuidedMeditation,
        volume: volume,
      );
      
      // Start the session with initial elapsed time
      state = state!.copyWith(
        state: MeditationState.inProgress,
        startTime: DateTime.now(),
        elapsedMeditationTime: Duration.zero,
      );
      
      // Start meditation timer before audio to ensure timer starts immediately
      _startMeditationTimer();
      
      // Start listening to position updates
      _positionSubscription?.cancel();
      _positionSubscription = _audioService.positionStream.listen((position) {
        if (state?.isInProgress == true) {
          state = state!.copyWith(currentPosition: position);
        }
      });
      
      await _audioService.play();
      developer.log('Session started successfully');
    } catch (e) {
      state = state?.copyWith(
        state: MeditationState.error,
        errorMessage: e.toString(),
      );
      developer.log('Error starting session: $e', error: e);
      throw Exception('Failed to start meditation session: $e');
    }
  }

  void _startMeditationTimer() {
    _meditationTimer?.cancel();
    
    // Emit first update immediately
    if (state?.isInProgress == true) {
      state = state!.copyWith(
        elapsedMeditationTime: state!.elapsedMeditationTime + const Duration(seconds: 1)
      );
    }
    
    _meditationTimer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (state?.isInProgress == true) {
        state = state!.copyWith(
          elapsedMeditationTime: state!.elapsedMeditationTime + const Duration(seconds: 1)
        );
        
        if (state!.elapsedMeditationTime >= state!.duration) {
          completeSession();
        }
      }
    });
  }

  Future<void> pauseSession() async {
    developer.log('Pausing session');
    if (state == null || state!.state != MeditationState.inProgress) {
      developer.log('Cannot pause: Invalid state ${state?.state}');
      return;
    }

    try {
      await _audioService.pause();
      state = state!.copyWith(state: MeditationState.paused);
      developer.log('Session paused successfully');
    } catch (e) {
      developer.log('Error pausing session: $e', error: e);
      throw Exception('Failed to pause meditation session: $e');
    }
  }

  Future<void> resumeSession() async {
    developer.log('Resuming session');
    if (state == null || state!.state != MeditationState.paused) {
      developer.log('Cannot resume: Invalid state ${state?.state}');
      return;
    }

    try {
      state = state!.copyWith(state: MeditationState.inProgress);
      await _audioService.play();
      developer.log('Session resumed successfully');
    } catch (e) {
      developer.log('Error resuming session: $e', error: e);
      throw Exception('Failed to resume meditation session: $e');
    }
  }

  Future<void> completeSession() async {
    developer.log('Completing session');
    if (state == null) {
      developer.log('Cannot complete: No active session');
      return;
    }

    try {
      await _audioService.stop();
      _positionSubscription?.cancel();
      _meditationTimer?.cancel();
      
      state = state!.copyWith(
        state: MeditationState.completed,
        endTime: DateTime.now(),
      );
      developer.log('Session completed successfully');
    } catch (e) {
      developer.log('Error completing session: $e', error: e);
      throw Exception('Failed to complete meditation session: $e');
    }
  }

  Future<void> cancelSession() async {
    developer.log('Cancelling session');
    if (state == null) {
      developer.log('No active session to cancel');
      return;
    }

    try {
      await _audioService.stop();
      _positionSubscription?.cancel();
      _meditationTimer?.cancel();
      state = null;
      developer.log('Session cancelled successfully');
    } catch (e) {
      developer.log('Error cancelling session: $e', error: e);
      throw Exception('Failed to cancel meditation session: $e');
    }
  }

  @override
  void dispose() {
    _positionSubscription?.cancel();
    _meditationTimer?.cancel();
    super.dispose();
  }
}

/// Provider for the audio service
final audioServiceProvider = Provider.autoDispose<MeditationAudioService>((ref) {
  final audioService = MeditationAudioService();
  ref.onDispose(() {
    audioService.dispose();
  });
  return audioService;
});

/// Provider for the meditation service
final meditationServiceProvider = StateNotifierProvider.autoDispose<MeditationService, MeditationSession?>((ref) {
  final audioService = ref.watch(audioServiceProvider);
  final service = MeditationService(audioService);
  ref.onDispose(() {
    service.dispose();
  });
  return service;
});

/// Provider for the current track
final currentTrackProvider = Provider.autoDispose<Track?>((ref) {
  return ref.watch(meditationServiceProvider)?.track;
});

/// Provider for guided meditation state
final isGuidedProvider = Provider.autoDispose<bool>((ref) {
  return ref.watch(meditationServiceProvider)?.track.isGuidedMeditation ?? false;
});

/// Provider for meditation state
final meditationStateProvider = Provider.autoDispose<MeditationState>((ref) {
  return ref.watch(meditationServiceProvider)?.state ?? MeditationState.initial;
});

/// Provider for timer updates
final timerProvider = StreamProvider.autoDispose<Duration>((ref) {
  final controller = StreamController<Duration>();
  
  void emitUpdate() {
    final session = ref.read(meditationServiceProvider);
    if (!controller.isClosed) {
      controller.add(session?.remaining ?? Duration.zero);
    }
  }

  // Set up timer for updates
  Timer? timer;
  ref.listen<MeditationSession?>(meditationServiceProvider, (previous, next) {
    timer?.cancel();
    if (next?.state == MeditationState.inProgress) {
      timer = Timer.periodic(const Duration(milliseconds: 500), (_) {
        emitUpdate();
      });
    }
    emitUpdate();
  });

  ref.onDispose(() {
    timer?.cancel();
    controller.close();
  });

  return controller.stream;
});

/// Provider for remaining time
final remainingTimeProvider = Provider.autoDispose<Duration>((ref) {
  final session = ref.watch(meditationServiceProvider);
  return session?.remaining ?? Duration.zero;
});

/// Provider for player state
final playerStateProvider = StreamProvider.autoDispose<PlayerState>((ref) {
  final audioService = ref.watch(audioServiceProvider);
  return audioService.playerStateStream;
});

/// Provider for playback position
final positionStreamProvider = StreamProvider.autoDispose<Duration>((ref) {
  final audioService = ref.watch(audioServiceProvider);
  return audioService.positionStream;
});

/// Provider for track duration
final durationStreamProvider = StreamProvider.autoDispose<Duration?>((ref) {
  final audioService = ref.watch(audioServiceProvider);
  return audioService.durationStream;
});