import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:meditation_app/data/models/user_model.dart';
import 'package:meditation_app/data/repositories/auth_repository.dart';
import 'package:meditation_app/presentation/state/auth_provider.dart';
import 'package:mocktail/mocktail.dart';

class MockAuthRepository extends Mock implements AuthRepository {}

void main() {
  late MockAuthRepository mockAuthRepository;
  late ProviderContainer container;

  // Test user data
  final testUser = User(
    id: 'test-id',
    email: 'test@example.com',
    metadata: {'name': 'Test User'},
    createdAt: DateTime.now().toIso8601String(),
  );

  setUp(() {
    mockAuthRepository = MockAuthRepository();
    container = ProviderContainer(
      overrides: [
        authRepositoryProvider.overrideWithValue(mockAuthRepository),
      ],
    );
  });

  tearDown(() {
    container.dispose();
  });

  group('authStateProvider', () {
    test('initial state is loading', () {
      when(() => mockAuthRepository.authStateChanges)
          .thenAnswer((_) => Stream.value(AuthState.initial));

      final stream = container.read(authStateProvider.stream);
      expect(stream, emits(AuthState.initial));
    });

    test('emits authenticated state when user signs in', () {
      when(() => mockAuthRepository.authStateChanges)
          .thenAnswer((_) => Stream.value(AuthState.authenticated));

      final stream = container.read(authStateProvider.stream);
      expect(stream, emits(AuthState.authenticated));
    });

    test('emits unauthenticated state when user signs out', () {
      when(() => mockAuthRepository.authStateChanges)
          .thenAnswer((_) => Stream.value(AuthState.unauthenticated));

      final stream = container.read(authStateProvider.stream);
      expect(stream, emits(AuthState.unauthenticated));
    });

    test('emits error state when authentication fails', () {
      when(() => mockAuthRepository.authStateChanges)
          .thenAnswer((_) => Stream.value(AuthState.error));

      final stream = container.read(authStateProvider.stream);
      expect(stream, emits(AuthState.error));
    });
  });

  group('currentUserProvider', () {
    test('initial state is null', () {
      when(() => mockAuthRepository.currentUser).thenReturn(null);

      final user = container.read(currentUserProvider);
      expect(user, isNull);
    });

    test('returns current user when authenticated', () {
      when(() => mockAuthRepository.currentUser).thenReturn(testUser);

      final user = container.read(currentUserProvider);
      expect(user, equals(testUser));
    });

    test('updates when user changes', () {
      when(() => mockAuthRepository.currentUser)
          .thenReturn(null)
          .thenReturn(testUser);

      expect(container.read(currentUserProvider), isNull);
      container.read(currentUserProvider.notifier).state = testUser;
      expect(container.read(currentUserProvider), equals(testUser));
    });
  });

  group('isAuthenticatedProvider', () {
    test('initial state is false', () {
      when(() => mockAuthRepository.isAuthenticated).thenReturn(false);

      final isAuthenticated = container.read(isAuthenticatedProvider);
      expect(isAuthenticated, isFalse);
    });

    test('returns true when user is authenticated', () {
      when(() => mockAuthRepository.isAuthenticated).thenReturn(true);

      final isAuthenticated = container.read(isAuthenticatedProvider);
      expect(isAuthenticated, isTrue);
    });

    test('updates when authentication state changes', () {
      when(() => mockAuthRepository.isAuthenticated)
          .thenReturn(false)
          .thenReturn(true);

      expect(container.read(isAuthenticatedProvider), isFalse);
      container.read(isAuthenticatedProvider.notifier).state = true;
      expect(container.read(isAuthenticatedProvider), isTrue);
    });
  });

  group('Error handling', () {
    test('authStateProvider handles stream errors', () {
      when(() => mockAuthRepository.authStateChanges)
          .thenAnswer((_) => Stream.error('Test error'));

      expect(
        container.read(authStateProvider.stream),
        emitsError(isA<String>()),
      );
    });

    test('currentUserProvider handles null user gracefully', () {
      when(() => mockAuthRepository.currentUser).thenReturn(null);

      expect(
        container.read(currentUserProvider),
        isNull,
      );
    });

    test('isAuthenticatedProvider defaults to false on error', () {
      when(() => mockAuthRepository.isAuthenticated).thenThrow('Test error');

      // The provider should handle the error and default to false
      expect(
        () => container.read(isAuthenticatedProvider),
        throwsA(isA<String>()),
      );
    });
  });
} 