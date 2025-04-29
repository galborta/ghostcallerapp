import 'package:flutter_test/flutter_test.dart';
import 'package:just_audio/just_audio.dart';
import 'package:meditation_app/data/services/audio_service.dart';

void main() {
  late MeditationAudioService audioService;
  const testAudioUrl = 'https://www.soundhelix.com/examples/mp3/SoundHelix-Song-1.mp3';

  setUp(() {
    audioService = MeditationAudioService();
  });

  tearDown(() async {
    await audioService.dispose();
  });

  group('MeditationAudioService - Basic Functionality', () {
    test('initialization creates valid instance', () {
      expect(audioService, isNotNull);
      expect(audioService.playerState, isA<PlayerState>());
      expect(audioService.position, isA<Duration>());
      expect(audioService.volume, equals(1.0)); // Default volume
    });

    test('load music-only track', () async {
      await audioService.loadTrack(
        trackUrl: testAudioUrl,
        isGuidedMeditation: false,
        volume: 0.7,
      );
      expect(audioService.duration, isNotNull);
      expect(audioService.volume, equals(0.7));
    });

    test('load guided meditation track', () async {
      await audioService.loadTrack(
        trackUrl: testAudioUrl,
        isGuidedMeditation: true,
        volume: 0.8,
      );
      expect(audioService.duration, isNotNull);
      expect(audioService.volume, equals(0.8));
    });

    test('play, pause, and stop functions', () async {
      await audioService.loadTrack(
        trackUrl: testAudioUrl,
        isGuidedMeditation: true,
      );
      
      // Test play
      await audioService.play();
      expect(audioService.playerState.playing, isTrue);

      // Test pause
      await audioService.pause();
      expect(audioService.playerState.playing, isFalse);

      // Test stop
      await audioService.stop();
      expect(audioService.playerState.playing, isFalse);
      expect(audioService.position, equals(Duration.zero));
    });

    test('volume control', () async {
      await audioService.loadTrack(
        trackUrl: testAudioUrl,
        isGuidedMeditation: true,
        volume: 0.5,
      );
      
      expect(audioService.volume, equals(0.5));
      
      await audioService.setVolume(0.8);
      expect(audioService.volume, equals(0.8));
      
      // Test volume clamping
      await audioService.setVolume(1.5); // Should clamp to 1.0
      expect(audioService.volume, equals(1.0));
      
      await audioService.setVolume(-0.5); // Should clamp to 0.0
      expect(audioService.volume, equals(0.0));
    });

    test('position and duration streams emit values', () async {
      // Listen to streams
      expectLater(audioService.positionStream, emits(isA<Duration>()));
      expectLater(audioService.durationStream, emits(isA<Duration>()));

      // Load and play audio to trigger stream events
      await audioService.loadTrack(
        trackUrl: testAudioUrl,
        isGuidedMeditation: true,
      );
      await audioService.play();
      await Future.delayed(const Duration(seconds: 1));
    });

    test('error handling - invalid URL', () async {
      expect(
        () => audioService.loadTrack(
          trackUrl: 'invalid_url',
          isGuidedMeditation: true,
        ),
        throwsA(isA<AudioLoadException>()),
      );
    });
  });

  group('Resource Management', () {
    test('dispose closes all streams', () async {
      await audioService.dispose();
      
      expect(
        () => audioService.playerStateStream.listen((_) {}),
        throwsStateError,
      );
      expect(
        () => audioService.positionStream.listen((_) {}),
        throwsStateError,
      );
      expect(
        () => audioService.durationStream.listen((_) {}),
        throwsStateError,
      );
    });
  });
} 