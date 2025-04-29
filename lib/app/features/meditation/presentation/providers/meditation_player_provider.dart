import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:just_audio/just_audio.dart';

enum PlaybackState {
  loading,
  playing,
  paused,
  completed,
  error,
}

class MeditationPlayerState {
  final PlaybackState playbackState;
  final Duration duration;
  final Duration position;
  final String? error;

  MeditationPlayerState({
    this.playbackState = PlaybackState.loading,
    this.duration = Duration.zero,
    this.position = Duration.zero,
    this.error,
  });

  MeditationPlayerState copyWith({
    PlaybackState? playbackState,
    Duration? duration,
    Duration? position,
    String? error,
  }) {
    return MeditationPlayerState(
      playbackState: playbackState ?? this.playbackState,
      duration: duration ?? this.duration,
      position: position ?? this.position,
      error: error ?? this.error,
    );
  }
}

class MeditationPlayerNotifier extends StateNotifier<MeditationPlayerState> {
  final AudioPlayer _player;
  final String meditationId;

  MeditationPlayerNotifier(this.meditationId)
      : _player = AudioPlayer(),
        super(MeditationPlayerState()) {
    _init();
  }

  Future<void> _init() async {
    try {
      // TODO: Replace with actual meditation audio URL from your backend
      final url = 'https://example.com/meditations/$meditationId.mp3';
      
      // Listen to player state changes
      _player.playerStateStream.listen((playerState) {
        if (playerState.processingState == ProcessingState.completed) {
          state = state.copyWith(playbackState: PlaybackState.completed);
        }
      });

      // Listen to duration changes
      _player.durationStream.listen((duration) {
        if (duration != null) {
          state = state.copyWith(duration: duration);
        }
      });

      // Listen to position changes
      _player.positionStream.listen((position) {
        state = state.copyWith(position: position);
      });

      // Set audio source
      await _player.setUrl(url);
      state = state.copyWith(playbackState: PlaybackState.paused);
    } catch (e) {
      state = state.copyWith(
        playbackState: PlaybackState.error,
        error: e.toString(),
      );
    }
  }

  Future<void> play() async {
    try {
      await _player.play();
      state = state.copyWith(playbackState: PlaybackState.playing);
    } catch (e) {
      state = state.copyWith(
        playbackState: PlaybackState.error,
        error: e.toString(),
      );
    }
  }

  Future<void> pause() async {
    try {
      await _player.pause();
      state = state.copyWith(playbackState: PlaybackState.paused);
    } catch (e) {
      state = state.copyWith(
        playbackState: PlaybackState.error,
        error: e.toString(),
      );
    }
  }

  Future<void> seek(Duration position) async {
    try {
      await _player.seek(position);
    } catch (e) {
      state = state.copyWith(
        playbackState: PlaybackState.error,
        error: e.toString(),
      );
    }
  }

  @override
  void dispose() {
    _player.dispose();
    super.dispose();
  }
}

final meditationPlayerProvider = StateNotifierProvider.family<MeditationPlayerNotifier,
    MeditationPlayerState, String>((ref, meditationId) {
  return MeditationPlayerNotifier(meditationId);
}); 