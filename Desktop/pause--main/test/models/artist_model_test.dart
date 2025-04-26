import 'package:flutter_test/flutter_test.dart';
import 'package:meditation_app/data/models/artist_model.dart';

void main() {
  group('Artist Model Tests', () {
    final testArtist = Artist(
      id: '123e4567-e89b-12d3-a456-426614174000',
      name: 'Zen Master',
      bio: 'A renowned meditation expert with over 20 years of experience.',
      shortBio: 'Experienced meditation guide',
      imageUrl: 'https://example.com/artists/zenmaster.jpg',
      featured: true,
      revenueSharePercentage: 70,
      referralCode: 'ZENMASTER2024',
      createdAt: DateTime.parse('2024-04-03T12:00:00Z'),
      updatedAt: DateTime.parse('2024-04-03T12:00:00Z'),
    );

    final testJson = {
      'id': '123e4567-e89b-12d3-a456-426614174000',
      'name': 'Zen Master',
      'bio': 'A renowned meditation expert with over 20 years of experience.',
      'short_bio': 'Experienced meditation guide',
      'image_url': 'https://example.com/artists/zenmaster.jpg',
      'featured': true,
      'revenue_share_percentage': 70,
      'referral_code': 'ZENMASTER2024',
      'created_at': '2024-04-03T12:00:00.000Z',
      'updated_at': '2024-04-03T12:00:00.000Z',
    };

    test('fromJson() should correctly deserialize Artist from JSON', () {
      final artist = Artist.fromJson(testJson);
      expect(artist, equals(testArtist));
    });

    test('toJson() should correctly serialize Artist to JSON', () {
      final json = testArtist.toJson();
      expect(json, equals(testJson));
    });

    test('equality test - identical artists should be equal', () {
      final artist1 = Artist.fromJson(testJson);
      final artist2 = Artist.fromJson(testJson);
      expect(artist1, equals(artist2));
    });

    test('equality test - different artists should not be equal', () {
      final artist1 = Artist.fromJson(testJson);
      final artist2 = Artist.fromJson({
        ...testJson,
        'name': 'Different Artist',
      });
      expect(artist1, isNot(equals(artist2)));
    });

    test('should handle all required fields from Supabase schema', () {
      final artist = Artist.fromJson(testJson);
      expect(artist.id, isNotNull);
      expect(artist.name, isNotNull);
      expect(artist.bio, isNotNull);
      expect(artist.shortBio, isNotNull);
      expect(artist.imageUrl, isNotNull);
      expect(artist.featured, isNotNull);
      expect(artist.revenueSharePercentage, isNotNull);
      expect(artist.referralCode, isNotNull);
      expect(artist.createdAt, isNotNull);
      expect(artist.updatedAt, isNotNull);
    });

    test('should work with DJ NOBU sample data', () {
      final djNobuJson = {
        'id': 'dj-nobu-001',
        'name': 'DJ NOBU',
        'bio': 'DJ NOBU is a renowned Japanese techno DJ and meditation music producer, known for blending deep, atmospheric soundscapes with traditional meditation elements. With over 15 years of experience in both electronic music and mindfulness practices, NOBU creates unique sonic journeys that bridge the gap between modern electronic music and spiritual wellness.',
        'short_bio': 'Japanese techno DJ and meditation music pioneer',
        'image_url': 'https://meditation-app.storage.supabase.co/artists/dj-nobu/profile.jpg',
        'featured': true,
        'revenue_share_percentage': 75,
        'referral_code': 'NOBU2024',
        'created_at': '2024-04-01T09:00:00.000Z',
        'updated_at': '2024-04-01T09:00:00.000Z',
      };

      final djNobu = Artist.fromJson(djNobuJson);

      expect(djNobu.name, equals('DJ NOBU'));
      expect(djNobu.shortBio, equals('Japanese techno DJ and meditation music pioneer'));
      expect(djNobu.featured, isTrue);
      expect(djNobu.revenueSharePercentage, equals(75));
      
      // Verify serialization round-trip
      final serializedJson = djNobu.toJson();
      final deserializedArtist = Artist.fromJson(serializedJson);
      expect(deserializedArtist, equals(djNobu));
    });

    final sampleJson = {
      'id': '123e4567-e89b-12d3-a456-426614174000',
      'name': 'Jane Doe',
      'bio': 'A meditation music artist.',
      'short_bio': 'Meditation artist',
      'image_url': 'https://example.com/image.jpg',
      'featured': true,
      'revenue_share_percentage': 60,
      'referral_code': 'JANE123',
      'created_at': '2024-05-01T12:00:00.000Z',
      'updated_at': '2024-05-10T12:00:00.000Z',
    };

    final sampleArtist = Artist(
      id: '123e4567-e89b-12d3-a456-426614174000',
      name: 'Jane Doe',
      bio: 'A meditation music artist.',
      shortBio: 'Meditation artist',
      imageUrl: 'https://example.com/image.jpg',
      featured: true,
      revenueSharePercentage: 60,
      referralCode: 'JANE123',
      createdAt: DateTime.parse('2024-05-01T12:00:00.000Z'),
      updatedAt: DateTime.parse('2024-05-10T12:00:00.000Z'),
    );

    test('fromJson creates correct Artist object', () {
      final artist = Artist.fromJson(sampleJson);
      expect(artist, sampleArtist);
    });

    test('toJson outputs correct map', () {
      final json = sampleArtist.toJson();
      expect(json, sampleJson);
    });

    test('round-trip serialization', () {
      final artist = Artist.fromJson(sampleJson);
      final json = artist.toJson();
      expect(json, sampleJson);
    });
  });
} 