import 'dart:async';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:mocktail/mocktail.dart';
import 'package:meditation_app/data/repositories/artist_repository.dart';
import 'package:meditation_app/data/models/artist_model.dart';
import 'package:meditation_app/presentation/state/artist_provider.dart';

// Mock repository
class MockArtistRepository extends Mock implements ArtistRepository {}

void main() {
  late MockArtistRepository mockRepository;
  late ProviderContainer container;

  // Sample artist data
  final testArtist = Artist(
    id: '1',
    name: 'Test Artist',
    bio: 'Test Bio',
    shortBio: 'Test Short Bio',
    imageUrl: 'test-image-url',
    featured: true,
    revenueSharePercentage: 50,
    referralCode: 'TEST123',
    createdAt: DateTime.now(),
    updatedAt: DateTime.now(),
  );

  final testArtist2 = Artist(
    id: '2',
    name: 'Another Artist',
    bio: 'Another Bio',
    shortBio: 'Another Short Bio',
    imageUrl: 'another-image-url',
    featured: false,
    revenueSharePercentage: 50,
    referralCode: 'TEST456',
    createdAt: DateTime.now(),
    updatedAt: DateTime.now(),
  );

  setUp(() {
    mockRepository = MockArtistRepository();
    container = ProviderContainer(
      overrides: [
        artistRepositoryProvider.overrideWithValue(mockRepository),
      ],
    );
  });

  tearDown(() {
    container.dispose();
  });

  group('artistsProvider', () {
    test('returns list of artists', () async {
      when(() => mockRepository.getArtists())
          .thenAnswer((_) async => [testArtist, testArtist2]);

      final result = await container.read(artistsProvider.future);
      expect(result.length, 2);
      expect(result.first.id, '1');
      expect(result.last.id, '2');
    });

    test('returns empty list when no artists', () async {
      when(() => mockRepository.getArtists())
          .thenAnswer((_) async => []);

      final result = await container.read(artistsProvider.future);
      expect(result, isEmpty);
    });

    test('handles errors properly', () async {
      when(() => mockRepository.getArtists())
          .thenThrow(Exception('Failed to fetch artists'));

      // Wait for the provider to update
      await expectLater(
        container.read(artistsProvider.future),
        throwsException,
      );
    });

    test('shows loading state', () {
      when(() => mockRepository.getArtists())
          .thenAnswer((_) => Future.delayed(const Duration(seconds: 1)));

      expect(container.read(artistsProvider), isA<AsyncLoading>());
    });
  });

  group('featuredArtistsProvider', () {
    test('returns only featured artists', () async {
      when(() => mockRepository.getArtists(featured: true))
          .thenAnswer((_) async => [testArtist]);

      final result = await container.read(featuredArtistsProvider.future);
      expect(result.length, 1);
      expect(result.first.featured, isTrue);
    });

    test('handles errors properly', () async {
      when(() => mockRepository.getArtists(featured: true))
          .thenThrow(Exception('Failed to fetch featured artists'));

      // Wait for the provider to update
      await expectLater(
        container.read(featuredArtistsProvider.future),
        throwsException,
      );
    });

    test('shows loading state', () {
      when(() => mockRepository.getArtists(featured: true))
          .thenAnswer((_) => Future.delayed(const Duration(seconds: 1)));

      expect(container.read(featuredArtistsProvider), isA<AsyncLoading>());
    });
  });

  group('artistByIdProvider', () {
    test('returns artist by id', () async {
      when(() => mockRepository.getArtistById('1'))
          .thenAnswer((_) async => testArtist);

      final result = await container.read(artistByIdProvider('1').future);
      expect(result?.id, '1');
      expect(result?.name, 'Test Artist');
    });

    test('returns null for non-existent artist', () async {
      when(() => mockRepository.getArtistById('999'))
          .thenAnswer((_) async => null);

      final result = await container.read(artistByIdProvider('999').future);
      expect(result, isNull);
    });

    test('handles errors properly', () async {
      when(() => mockRepository.getArtistById('1'))
          .thenThrow(Exception('Failed to fetch artist'));

      // Wait for the provider to update
      await expectLater(
        container.read(artistByIdProvider('1').future),
        throwsException,
      );
    });

    test('shows loading state', () {
      when(() => mockRepository.getArtistById('1'))
          .thenAnswer((_) => Future.delayed(const Duration(seconds: 1)));

      expect(container.read(artistByIdProvider('1')), isA<AsyncLoading>());
    });
  });

  group('artistSearchProvider', () {
    test('returns all artists when search term is empty', () async {
      when(() => mockRepository.getArtists())
          .thenAnswer((_) async => [testArtist, testArtist2]);

      container.read(searchTermProvider.notifier).state = '';
      final result = await container.read(artistSearchProvider.future);
      expect(result.length, 2);
    });

    test('returns filtered artists when search term is provided', () async {
      when(() => mockRepository.searchArtists('test'))
          .thenAnswer((_) async => [testArtist]);

      container.read(searchTermProvider.notifier).state = 'test';
      final result = await container.read(artistSearchProvider.future);
      expect(result.length, 1);
      expect(result.first.name, 'Test Artist');
    });

    test('handles errors properly', () async {
      when(() => mockRepository.searchArtists('test'))
          .thenThrow(Exception('Failed to search artists'));

      container.read(searchTermProvider.notifier).state = 'test';
      
      // Wait for the provider to update
      await expectLater(
        container.read(artistSearchProvider.future),
        throwsException,
      );
    });

    test('shows loading state', () {
      when(() => mockRepository.searchArtists('test'))
          .thenAnswer((_) => Future.delayed(const Duration(seconds: 1)));

      container.read(searchTermProvider.notifier).state = 'test';
      expect(container.read(artistSearchProvider), isA<AsyncLoading>());
    });

    test('handles rapid search term updates', () async {
      final searchTerms = ['t', 'te', 'tes', 'test'];
      final completer = Completer<List<Artist>>();

      when(() => mockRepository.searchArtists(any()))
          .thenAnswer((_) => completer.future);

      // Rapidly update search terms
      for (final term in searchTerms) {
        container.read(searchTermProvider.notifier).state = term;
      }

      // The last search term should be 'test'
      expect(container.read(searchTermProvider), equals('test'));
      
      // Complete the search
      completer.complete([testArtist]);
      
      // Wait for the search to complete
      await container.read(artistSearchProvider.future);
      
      // Verify that only the last search was performed
      verify(() => mockRepository.searchArtists('test')).called(1);
    });
  });

  group('filteredArtistsProvider', () {
    test('returns all artists when search term is empty', () async {
      when(() => mockRepository.getArtists())
          .thenAnswer((_) async => [testArtist, testArtist2]);

      container.read(searchTermProvider.notifier).state = '';
      
      final artists = await container.read(artistsProvider.future);
      final filtered = container.read(filteredArtistsProvider);
      
      expect(filtered.value?.length, artists.length);
    });

    test('filters artists by name', () async {
      when(() => mockRepository.getArtists())
          .thenAnswer((_) async => [testArtist, testArtist2]);

      // Wait for the artists to load
      await container.read(artistsProvider.future);
      
      container.read(searchTermProvider.notifier).state = 'test';
      final filtered = container.read(filteredArtistsProvider);
      
      expect(filtered.value?.length, 1);
      expect(filtered.value?.first.name, 'Test Artist');
    });

    test('filters artists by bio', () async {
      when(() => mockRepository.getArtists())
          .thenAnswer((_) async => [testArtist, testArtist2]);

      // Wait for the artists to load
      await container.read(artistsProvider.future);
      
      container.read(searchTermProvider.notifier).state = 'another bio';
      final filtered = container.read(filteredArtistsProvider);
      
      expect(filtered.value?.length, 1);
      expect(filtered.value?.first.name, 'Another Artist');
    });

    test('returns empty list when no matches', () async {
      when(() => mockRepository.getArtists())
          .thenAnswer((_) async => [testArtist, testArtist2]);

      // Wait for the artists to load
      await container.read(artistsProvider.future);
      
      container.read(searchTermProvider.notifier).state = 'no matches';
      final filtered = container.read(filteredArtistsProvider);
      
      expect(filtered.value?.length, 0);
    });

    test('handles errors from artistsProvider', () async {
      when(() => mockRepository.getArtists())
          .thenThrow(Exception('Failed to fetch artists'));

      // Wait for the provider to update
      await expectLater(
        container.read(artistsProvider.future),
        throwsException,
      );

      expect(
        container.read(filteredArtistsProvider),
        isA<AsyncError>(),
      );
    });

    test('shows loading state when artists are loading', () {
      when(() => mockRepository.getArtists())
          .thenAnswer((_) => Future.delayed(const Duration(seconds: 1)));

      expect(container.read(filteredArtistsProvider), isA<AsyncLoading>());
    });

    test('handles rapid filter term updates', () async {
      when(() => mockRepository.getArtists())
          .thenAnswer((_) async => [testArtist, testArtist2]);

      // Wait for initial artists to load
      await container.read(artistsProvider.future);

      // Rapidly update filter terms
      container.read(searchTermProvider.notifier).state = 't';
      container.read(searchTermProvider.notifier).state = 'te';
      container.read(searchTermProvider.notifier).state = 'tes';
      container.read(searchTermProvider.notifier).state = 'test';

      // The filtered results should reflect the last filter term
      final filtered = container.read(filteredArtistsProvider);
      expect(filtered.value?.length, 1);
      expect(filtered.value?.first.name, 'Test Artist');
    });
  });
} 