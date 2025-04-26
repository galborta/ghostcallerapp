import 'package:flutter_test/flutter_test.dart';
import 'package:meditation_app/data/models/track_model.dart';

void main() {
  group('Track Model Tests', () {
    final sampleTrack = Track(
      id: '123e4567-e89b-12d3-a456-426614174000',
      title: 'Peaceful Meditation',
      artistId: '123e4567-e89b-12d3-a456-426614174001',
      audioUrl: 'https://storage.example.com/tracks/peaceful_meditation.mp3',
      audioStoragePath: '/tracks/peaceful_meditation.mp3',
      duration: 900, // 15 minutes in seconds
      isGuided: true,
      createdAt: DateTime.parse('2024-03-15T10:00:00Z'),
      updatedAt: DateTime.parse('2024-03-15T10:00:00Z'),
    );

    final sampleJson = {
      'id': '123e4567-e89b-12d3-a456-426614174000',
      'title': 'Peaceful Meditation',
      'artistId': '123e4567-e89b-12d3-a456-426614174001',
      'audioUrl': 'https://storage.example.com/tracks/peaceful_meditation.mp3',
      'audioStoragePath': '/tracks/peaceful_meditation.mp3',
      'duration': 900,
      'isGuided': true,
      'createdAt': '2024-03-15T10:00:00.000Z',
      'updatedAt': '2024-03-15T10:00:00.000Z',
    };

    test('should create Track instance with correct values', () {
      expect(sampleTrack.id, '123e4567-e89b-12d3-a456-426614174000');
      expect(sampleTrack.title, 'Peaceful Meditation');
      expect(sampleTrack.artistId, '123e4567-e89b-12d3-a456-426614174001');
      expect(sampleTrack.audioUrl, 'https://storage.example.com/tracks/peaceful_meditation.mp3');
      expect(sampleTrack.audioStoragePath, '/tracks/peaceful_meditation.mp3');
      expect(sampleTrack.duration, 900);
      expect(sampleTrack.isGuided, true);
      expect(sampleTrack.createdAt, DateTime.parse('2024-03-15T10:00:00Z'));
      expect(sampleTrack.updatedAt, DateTime.parse('2024-03-15T10:00:00Z'));
    });

    test('should serialize Track to JSON', () {
      final json = sampleTrack.toJson();
      expect(json, sampleJson);
    });

    test('should deserialize JSON to Track', () {
      final track = Track.fromJson(sampleJson);
      expect(track, sampleTrack);
    });

    test('should create Track with default isGuided value', () {
      final trackWithoutGuided = Track(
        id: '123e4567-e89b-12d3-a456-426614174000',
        title: 'Peaceful Meditation',
        artistId: '123e4567-e89b-12d3-a456-426614174001',
        audioUrl: 'https://storage.example.com/tracks/peaceful_meditation.mp3',
        audioStoragePath: '/tracks/peaceful_meditation.mp3',
        duration: 900,
        createdAt: DateTime.parse('2024-03-15T10:00:00Z'),
        updatedAt: DateTime.parse('2024-03-15T10:00:00Z'),
      );
      expect(trackWithoutGuided.isGuided, false);
    });
  });
} 