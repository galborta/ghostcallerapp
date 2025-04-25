import 'package:flutter_test/flutter_test.dart';
import 'package:meditation_app/data/models/user_model.dart';

void main() {
  group('User Model Tests', () {
    final testUser = User(
      id: '123e4567-e89b-12d3-a456-426614174000',
      email: 'test@example.com',
      fullName: 'Test User',
      avatarUrl: 'https://example.com/avatar.jpg',
      isArtist: true,
      createdAt: DateTime.parse('2024-04-03T12:00:00Z'),
      updatedAt: DateTime.parse('2024-04-03T12:00:00Z'),
    );

    final testJson = {
      'id': '123e4567-e89b-12d3-a456-426614174000',
      'email': 'test@example.com',
      'full_name': 'Test User',
      'avatar_url': 'https://example.com/avatar.jpg',
      'is_artist': true,
      'created_at': '2024-04-03T12:00:00.000Z',
      'updated_at': '2024-04-03T12:00:00.000Z',
    };

    test('fromJson() should correctly deserialize User from JSON', () {
      final user = User.fromJson(testJson);
      expect(user, equals(testUser));
    });

    test('toJson() should correctly serialize User to JSON', () {
      final json = testUser.toJson();
      expect(json, equals(testJson));
    });

    test('equality test - identical users should be equal', () {
      final user1 = User.fromJson(testJson);
      final user2 = User.fromJson(testJson);
      expect(user1, equals(user2));
    });

    test('equality test - different users should not be equal', () {
      final user1 = User.fromJson(testJson);
      final user2 = User.fromJson({
        ...testJson,
        'email': 'different@example.com',
      });
      expect(user1, isNot(equals(user2)));
    });
  });
} 