import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:meditation_app/data/models/artist_model.dart';
import 'package:meditation_app/data/repositories/supabase_artist_repository.dart';
import 'package:postgrest/postgrest.dart';
import 'dart:async';

// Mock classes
class MockSupabaseClient extends Mock implements SupabaseClient {}

class MockSupabaseQueryBuilder extends Mock 
    implements SupabaseQueryBuilder {
  final MockPostgrestFilterBuilder _filterBuilder;

  MockSupabaseQueryBuilder([MockPostgrestFilterBuilder? filterBuilder]) 
      : _filterBuilder = filterBuilder ?? MockPostgrestFilterBuilder();

  @override
  PostgrestFilterBuilder<List<Map<String, dynamic>>> select([String columns = '*']) {
    return _filterBuilder;
  }
}

class MockPostgrestFilterBuilder extends Mock implements PostgrestFilterBuilder<List<Map<String, dynamic>>> {
  static final _defaultResponse = {
    'id': '1',
    'name': 'Test Artist',
    'bio': 'Test Bio',
    'short_bio': 'Test Short Bio',
    'image_url': 'test-image-url',
    'featured': true,
    'revenue_share_percentage': 50,
    'referral_code': 'TEST123',
    'created_at': DateTime.now().toIso8601String(),
    'updated_at': DateTime.now().toIso8601String(),
  };

  final bool returnNullForSingle;

  MockPostgrestFilterBuilder({this.returnNullForSingle = false});

  @override
  PostgrestFilterBuilder<List<Map<String, dynamic>>> eq(String column, dynamic value) {
    return this;
  }

  @override
  PostgrestFilterBuilder<List<Map<String, dynamic>>> or(String filters, {String? referencedTable}) {
    return this;
  }

  @override
  PostgrestFilterBuilder<List<Map<String, dynamic>>> limit(int count, {String? referencedTable}) {
    return this;
  }

  @override
  Future<List<Map<String, dynamic>>> execute() async {
    return returnNullForSingle ? [] : [_defaultResponse];
  }

  @override
  PostgrestTransformBuilder<Map<String, dynamic>> single() {
    return MockPostgrestTransformBuilder(returnNullForSingle);
  }

  @override
  Future<T> then<T>(FutureOr<T> Function(List<Map<String, dynamic>>) onValue, {Function? onError}) {
    return Future.value(onValue(returnNullForSingle ? [] : [_defaultResponse]));
  }
}

class MockPostgrestTransformBuilder extends Mock 
    implements PostgrestTransformBuilder<Map<String, dynamic>> {
  final bool returnNull;

  MockPostgrestTransformBuilder(this.returnNull);

  @override
  Future<Map<String, dynamic>?> execute() async {
    return returnNull ? null : MockPostgrestFilterBuilder._defaultResponse;
  }

  @override
  Future<T> then<T>(FutureOr<T> Function(Map<String, dynamic>) onValue, {Function? onError}) {
    if (returnNull) {
      return Future.value(null as T);
    }
    return Future.value(onValue(MockPostgrestFilterBuilder._defaultResponse));
  }
}

class MockPostgrestSingleBuilder extends Mock 
    implements PostgrestTransformBuilder<Map<String, dynamic>> {
  final bool returnNull;

  MockPostgrestSingleBuilder(this.returnNull);

  @override
  Future<Map<String, dynamic>?> execute() async {
    return returnNull ? null : MockPostgrestFilterBuilder._defaultResponse;
  }

  @override
  Future<T> then<T>(FutureOr<T> Function(Map<String, dynamic>) onValue, {Function? onError}) {
    if (returnNull) {
      return Future.value(null as T);
    }
    return Future.value(onValue(MockPostgrestFilterBuilder._defaultResponse));
  }
}

void main() {
  group('ArtistRepository Mock Tests', () {
    late MockSupabaseClient mockClient;
    late SupabaseArtistRepository repository;

    setUp(() {
      mockClient = MockSupabaseClient();
      repository = SupabaseArtistRepository(mockClient);

      // Setup common mocks
      when(() => mockClient.from(any())).thenAnswer((_) => MockSupabaseQueryBuilder());
    });

    test('getArtists returns list of artists', () async {
      final artists = await repository.getArtists();

      verify(() => mockClient.from('artists')).called(1);

      expect(artists.length, 1);
      expect(artists.first.id, '1');
      expect(artists.first.name, 'Test Artist');
    });

    test('getArtists with featured=true returns featured artists', () async {
      final artists = await repository.getArtists(featured: true);

      verify(() => mockClient.from('artists')).called(1);

      expect(artists.length, 1);
      expect(artists.first.featured, true);
    });

    test('getArtistById returns artist', () async {
      final artist = await repository.getArtistById('1');

      verify(() => mockClient.from('artists')).called(1);

      expect(artist?.id, '1');
      expect(artist?.name, 'Test Artist');
    });

    test('searchArtists returns matching artists', () async {
      final searchTerm = 'test';
      final artists = await repository.searchArtists(searchTerm);

      verify(() => mockClient.from('artists')).called(1);

      expect(artists.length, 1);
      expect(artists.first.name.toLowerCase(), contains(searchTerm.toLowerCase()));
    });

    test('getArtistByReferralCode returns artist', () async {
      final artist = await repository.getArtistByReferralCode('TEST123');

      verify(() => mockClient.from('artists')).called(1);

      expect(artist?.referralCode, 'TEST123');
    });

    test('getArtistById returns null for non-existent artist', () async {
      when(() => mockClient.from(any())).thenAnswer((_) => 
        MockSupabaseQueryBuilder(MockPostgrestFilterBuilder(returnNullForSingle: true))
      );
      
      final artist = await repository.getArtistById('999');
      expect(artist, isNull);
    });
  });

  // Skipping integration tests in CI environment
  group('Real Supabase Integration Tests', () {
    late SupabaseClient supabase;
    late SupabaseArtistRepository repository;

    setUpAll(() async {
      final url = const String.fromEnvironment('SUPABASE_URL');
      final anonKey = const String.fromEnvironment('SUPABASE_ANON_KEY');

      // Skip integration tests if credentials are not provided
      if (url.isEmpty || anonKey.isEmpty) {
        print('Skipping integration tests: Missing Supabase credentials');
        return;
      }

      try {
        await Supabase.initialize(url: url, anonKey: anonKey);
        supabase = Supabase.instance.client;
        repository = SupabaseArtistRepository(supabase);
      } catch (e) {
        print('Failed to initialize Supabase: $e');
        rethrow;
      }
    });

    test('fetch all artists', () async {
      final artists = await repository.getArtists();
      expect(artists, isNotEmpty);
      expect(artists.first.name, isNotEmpty);
    }, skip: true); // Skip by default, enable manually for integration testing

    test('fetch featured artists', () async {
      final artists = await repository.getArtists(featured: true);
      expect(artists.every((artist) => artist.featured), true);
    }, skip: true);

    test('search artists', () async {
      const searchTerm = 'meditation';
      final results = await repository.searchArtists(searchTerm);
      
      for (final artist in results) {
        expect(
          artist.name.toLowerCase().contains(searchTerm) ||
              artist.bio.toLowerCase().contains(searchTerm),
          true,
        );
      }
    }, skip: true);

    test('get artist by referral code', () async {
      const testReferralCode = 'TEST123';
      final artist = await repository.getArtistByReferralCode(testReferralCode);
      
      expect(artist, isNotNull);
      expect(artist?.referralCode, testReferralCode);
    }, skip: true);
  });
} 