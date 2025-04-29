import 'package:just_audio/just_audio.dart';
import 'dart:async';

/// Service class for handling meditation audio playback
/// Simplified for handling two track variants: music-only and guided meditation
class MeditationAudioService {
  final AudioPlayer _player;
  bool _isInitialized = false;

  /// Stream controllers for custom events
  final _playerStateController = StreamController<PlayerState>.broadcast();
  final _positionController = StreamController<Duration>.broadcast();
  final _durationController = StreamController<Duration?>.broadcast();

  /// Constructor
  MeditationAudioService() : _player = AudioPlayer() {
    _initializePlayer();
  }

  /// Initialize the player and set up stream listeners
  void _initializePlayer() {
    if (_isInitialized) return;

    // Set up position updates
    _player.positionStream.listen((position) {
      _positionController.add(position);
    });

    // Set up duration updates
    _player.durationStream.listen((duration) {
      _durationController.add(duration);
    });

    // Set up player state updates
    _player.playerStateStream.listen((state) {
      _playerStateController.add(state);
    });

    // Set up error handling
    _player.processingStateStream.listen((state) {
      if (state == ProcessingState.completed) {
        _playerStateController.add(_player.playerState);
      }
    });

    _isInitialized = true;
  }

  /// Load either the music-only or guided meditation track
  Future<void> loadTrack({
    required String trackUrl,
    required bool isGuidedMeditation,
    double volume = 0.8,
  }) async {
    try {
      // Stop any currently playing audio
      await stop();
      
      // Ensure URL is properly encoded
      final encodedUrl = Uri.encodeFull(trackUrl);
      
      // Set up the audio source with proper error handling
      final duration = await _player.setAudioSource(
        AudioSource.uri(Uri.parse(encodedUrl)),
        preload: true,
      );

      if (duration == null) {
        throw AudioLoadException('Failed to load audio track: Duration is null');
      }

      // Wait for the audio to be ready
      await _player.processingStateStream
          .firstWhere((state) => state == ProcessingState.ready || state == ProcessingState.completed)
          .timeout(
            const Duration(seconds: 30),
            onTimeout: () => throw AudioLoadException('Timeout waiting for audio to be ready'),
          );

      // Set volume
      await setVolume(volume);
      
      // Add initial duration
      _durationController.add(duration);
      
    } catch (e) {
      throw AudioLoadException(
        'Failed to load ${isGuidedMeditation ? "guided meditation" : "music-only"} track: ${e.toString()}'
      );
    }
  }

  /// Start or resume playback
  Future<void> play() async {
    try {
      if (_player.processingState == ProcessingState.completed) {
        await _player.seek(Duration.zero);
      }
      await _player.play();
    } catch (e) {
      throw AudioPlaybackException('Failed to play audio: ${e.toString()}');
    }
  }

  /// Pause playback
  Future<void> pause() async {
    try {
      await _player.pause();
    } catch (e) {
      throw AudioPlaybackException('Failed to pause audio: ${e.toString()}');
    }
  }

  /// Stop playback and reset position
  Future<void> stop() async {
    try {
      await _player.stop();
      await _player.seek(Duration.zero);
    } catch (e) {
      throw AudioPlaybackException('Failed to stop audio: ${e.toString()}');
    }
  }

  /// Adjust volume
  Future<void> setVolume(double volume) async {
    try {
      await _player.setVolume(volume.clamp(0.0, 1.0));
    } catch (e) {
      throw AudioPlaybackException('Failed to set volume: ${e.toString()}');
    }
  }

  /// Get the current playback position
  Duration get position => _player.position;

  /// Get the total duration of the current audio
  Duration? get duration => _player.duration;

  /// Get the current playback state
  PlayerState get playerState => _player.playerState;

  /// Get current volume
  double get volume => _player.volume;

  /// Seek to a specific position in the audio track
  Future<void> seek(Duration position) async {
    try {
      await _player.seek(position);
    } catch (e) {
      throw AudioPlaybackException('Failed to seek to position: ${e.toString()}');
    }
  }

  /// Stream of player states
  Stream<PlayerState> get playerStateStream => _playerStateController.stream;

  /// Stream of playback positions
  Stream<Duration> get positionStream => _positionController.stream;

  /// Stream of audio durations
  Stream<Duration?> get durationStream => _durationController.stream;

  /// Check if audio is currently playing
  bool get isPlaying => _player.playing;

  /// Check if audio is currently paused
  bool get isPaused => !_player.playing && _player.processingState != ProcessingState.completed;

  /// Check if audio has completed
  bool get isCompleted => _player.processingState == ProcessingState.completed;

  /// Dispose of resources
  Future<void> dispose() async {
    await _player.dispose();
    await _playerStateController.close();
    await _positionController.close();
    await _durationController.close();
  }
}

/// Custom exception for audio loading errors
class AudioLoadException implements Exception {
  final String message;
  AudioLoadException(this.message);
  @override
  String toString() => message;
}

/// Custom exception for audio playback errors
class AudioPlaybackException implements Exception {
  final String message;
  AudioPlaybackException(this.message);
  @override
  String toString() => message;
} 