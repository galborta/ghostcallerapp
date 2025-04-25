import 'package:flutter_test/flutter_test.dart';
import 'package:meditation_app/data/models/user_model.dart';

void main() {
  group('UserModel Tests', () {
    test('should create UserModel instance', () {
      final now = DateTime.now();
      final user = UserModel(
        id: '123',
        email: 'test@example.com',
        fullName: 'Test User',
        avatarUrl: 'https://example.com/avatar.jpg',
        isArtist: true,
        createdAt: now,
        updatedAt: now,
      );

      expect(user.id, equals('123'));
      expect(user.email, equals('test@example.com'));
      expect(user.fullName, equals('Test User'));
      expect(user.avatarUrl, equals('https://example.com/avatar.jpg'));
      expect(user.isArtist, isTrue);
      expect(user.createdAt, equals(now));
      expect(user.updatedAt, equals(now));
    });

    test('should create UserModel from json', () {
      final json = {
        'id': '123',
        'email': 'test@example.com',
        'fullName': 'Test User',
        'avatarUrl': 'https://example.com/avatar.jpg',
        'isArtist': true,
        'createdAt': '2024-04-25T00:00:00.000Z',
        'updatedAt': '2024-04-25T00:00:00.000Z',
      };

      final user = UserModel.fromJson(json);

      expect(user.id, equals('123'));
      expect(user.email, equals('test@example.com'));
      expect(user.fullName, equals('Test User'));
      expect(user.avatarUrl, equals('https://example.com/avatar.jpg'));
      expect(user.isArtist, isTrue);
      expect(user.createdAt.toIso8601String(), equals('2024-04-25T00:00:00.000Z'));
      expect(user.updatedAt.toIso8601String(), equals('2024-04-25T00:00:00.000Z'));
    });

    test('should convert UserModel to json', () {
      final now = DateTime.utc(2024, 4, 25);
      final user = UserModel(
        id: '123',
        email: 'test@example.com',
        fullName: 'Test User',
        avatarUrl: 'https://example.com/avatar.jpg',
        isArtist: true,
        createdAt: now,
        updatedAt: now,
      );

      final json = user.toJson();

      expect(json['id'], equals('123'));
      expect(json['email'], equals('test@example.com'));
      expect(json['fullName'], equals('Test User'));
      expect(json['avatarUrl'], equals('https://example.com/avatar.jpg'));
      expect(json['isArtist'], isTrue);
      expect(json['createdAt'], equals('2024-04-25T00:00:00.000Z'));
      expect(json['updatedAt'], equals('2024-04-25T00:00:00.000Z'));
    });
  });
} 