import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:integration_test/integration_test.dart';
import 'package:meditation_app/data/models/user_model.dart';
import 'package:meditation_app/data/repositories/auth_repository.dart';
import 'package:meditation_app/main.dart' as app;
import 'package:meditation_app/presentation/state/auth_provider.dart';
import 'package:mocktail/mocktail.dart';

class MockAuthRepository extends Mock implements AuthRepository {}

void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();

  late MockAuthRepository mockAuthRepository;

  const testUser = User(
    id: 'test-id',
    email: 'test@example.com',
    metadata: {},
    createdAt: '2024-01-01T00:00:00.000Z',
  );

  setUp(() {
    mockAuthRepository = MockAuthRepository();
  });

  Future<void> pumpApp(WidgetTester tester) async {
    await app.main(
      overrides: [
        authRepositoryProvider.overrideWithValue(mockAuthRepository),
      ],
    );
    await tester.pumpAndSettle();
  }

  group('Signup Flow', () {
    testWidgets('completes signup successfully', (tester) async {
      // Setup success responses
      when(() => mockAuthRepository.signUp(
            email: any(named: 'email'),
            password: any(named: 'password'),
          )).thenAnswer((_) async => testUser);

      when(() => mockAuthRepository.updateUserMetadata(any()))
          .thenAnswer((_) async => testUser);

      when(() => mockAuthRepository.currentUser).thenReturn(testUser);
      when(() => mockAuthRepository.isAuthenticated).thenReturn(true);

      await pumpApp(tester);

      // Navigate to signup
      await tester.tap(find.text('Create Account'));
      await tester.pumpAndSettle();

      // Fill signup form
      await tester.enterText(
        find.widgetWithText(TextFormField, 'Email'),
        'test@example.com',
      );
      await tester.enterText(
        find.widgetWithText(TextFormField, 'Password'),
        'ValidPass123',
      );
      await tester.enterText(
        find.widgetWithText(TextFormField, 'Referral Code (Optional)'),
        'REF123',
      );

      // Submit form
      await tester.tap(find.text('Create Account'));
      await tester.pumpAndSettle();

      // Verify navigation to home screen
      expect(find.text('Welcome to Meditation App'), findsOneWidget);
      expect(find.text('test@example.com'), findsOneWidget);
    });

    testWidgets('handles existing email error', (tester) async {
      // Setup error response
      when(() => mockAuthRepository.signUp(
            email: any(named: 'email'),
            password: any(named: 'password'),
          )).thenThrow(Exception('Email already exists'));

      await pumpApp(tester);

      // Navigate to signup
      await tester.tap(find.text('Create Account'));
      await tester.pumpAndSettle();

      // Fill signup form
      await tester.enterText(
        find.widgetWithText(TextFormField, 'Email'),
        'existing@example.com',
      );
      await tester.enterText(
        find.widgetWithText(TextFormField, 'Password'),
        'ValidPass123',
      );

      // Submit form
      await tester.tap(find.text('Create Account'));
      await tester.pumpAndSettle();

      // Verify error message
      expect(
        find.text('Failed to create account. Please try again.'),
        findsOneWidget,
      );
    });
  });

  group('Login Flow', () {
    testWidgets('completes login successfully', (tester) async {
      // Setup success responses
      when(() => mockAuthRepository.signIn(
            email: any(named: 'email'),
            password: any(named: 'password'),
          )).thenAnswer((_) async => testUser);

      when(() => mockAuthRepository.currentUser).thenReturn(testUser);
      when(() => mockAuthRepository.isAuthenticated).thenReturn(true);

      await pumpApp(tester);

      // Navigate to login (if not already there)
      if (find.text('Sign In').evaluate().isEmpty) {
        await tester.tap(find.text('Already have an account?'));
        await tester.pumpAndSettle();
      }

      // Fill login form
      await tester.enterText(
        find.widgetWithText(TextFormField, 'Email'),
        'test@example.com',
      );
      await tester.enterText(
        find.widgetWithText(TextFormField, 'Password'),
        'ValidPass123',
      );

      // Submit form
      await tester.tap(find.text('Sign In'));
      await tester.pumpAndSettle();

      // Verify navigation to home screen
      expect(find.text('Welcome to Meditation App'), findsOneWidget);
      expect(find.text('test@example.com'), findsOneWidget);
    });

    testWidgets('handles incorrect credentials', (tester) async {
      // Setup error response
      when(() => mockAuthRepository.signIn(
            email: any(named: 'email'),
            password: any(named: 'password'),
          )).thenThrow(Exception('Invalid credentials'));

      await pumpApp(tester);

      // Fill login form
      await tester.enterText(
        find.widgetWithText(TextFormField, 'Email'),
        'test@example.com',
      );
      await tester.enterText(
        find.widgetWithText(TextFormField, 'Password'),
        'WrongPass123',
      );

      // Submit form
      await tester.tap(find.text('Sign In'));
      await tester.pumpAndSettle();

      // Verify error message
      expect(find.text('Invalid email or password'), findsOneWidget);
    });
  });

  group('Auth Persistence', () {
    testWidgets('maintains auth state after app restart', (tester) async {
      // Setup initial login success
      when(() => mockAuthRepository.signIn(
            email: any(named: 'email'),
            password: any(named: 'password'),
          )).thenAnswer((_) async => testUser);

      when(() => mockAuthRepository.currentUser).thenReturn(testUser);
      when(() => mockAuthRepository.isAuthenticated).thenReturn(true);
      when(() => mockAuthRepository.authStateChanges)
          .thenAnswer((_) => Stream.value(AuthState.authenticated));

      // First app launch and login
      await pumpApp(tester);
      await tester.enterText(
        find.widgetWithText(TextFormField, 'Email'),
        'test@example.com',
      );
      await tester.enterText(
        find.widgetWithText(TextFormField, 'Password'),
        'ValidPass123',
      );
      await tester.tap(find.text('Sign In'));
      await tester.pumpAndSettle();

      // Verify logged in state
      expect(find.text('Welcome to Meditation App'), findsOneWidget);

      // Simulate app restart
      await pumpApp(tester);
      await tester.pumpAndSettle();

      // Verify still logged in
      expect(find.text('Welcome to Meditation App'), findsOneWidget);
      expect(find.text('test@example.com'), findsOneWidget);
    });

    testWidgets('handles expired session on restart', (tester) async {
      // Setup expired session
      when(() => mockAuthRepository.currentUser).thenReturn(null);
      when(() => mockAuthRepository.isAuthenticated).thenReturn(false);
      when(() => mockAuthRepository.authStateChanges)
          .thenAnswer((_) => Stream.value(AuthState.unauthenticated));

      // App restart
      await pumpApp(tester);
      await tester.pumpAndSettle();

      // Verify redirected to login
      expect(find.text('Welcome Back'), findsOneWidget);
      expect(find.text('Sign in to continue your meditation journey'), findsOneWidget);
    });
  });

  group('Error Handling', () {
    testWidgets('handles network errors gracefully', (tester) async {
      // Setup network error
      when(() => mockAuthRepository.signIn(
            email: any(named: 'email'),
            password: any(named: 'password'),
          )).thenThrow(Exception('Network error'));

      await pumpApp(tester);

      // Attempt login
      await tester.enterText(
        find.widgetWithText(TextFormField, 'Email'),
        'test@example.com',
      );
      await tester.enterText(
        find.widgetWithText(TextFormField, 'Password'),
        'ValidPass123',
      );
      await tester.tap(find.text('Sign In'));
      await tester.pumpAndSettle();

      // Verify error handling
      expect(find.text('Invalid email or password'), findsOneWidget);
      expect(find.byType(TextFormField), findsNWidgets(2)); // Fields still visible
    });

    testWidgets('handles server errors during signup', (tester) async {
      // Setup server error
      when(() => mockAuthRepository.signUp(
            email: any(named: 'email'),
            password: any(named: 'password'),
          )).thenThrow(Exception('Server error'));

      await pumpApp(tester);

      // Navigate to signup
      await tester.tap(find.text('Create Account'));
      await tester.pumpAndSettle();

      // Attempt signup
      await tester.enterText(
        find.widgetWithText(TextFormField, 'Email'),
        'test@example.com',
      );
      await tester.enterText(
        find.widgetWithText(TextFormField, 'Password'),
        'ValidPass123',
      );
      await tester.tap(find.text('Create Account'));
      await tester.pumpAndSettle();

      // Verify error handling
      expect(
        find.text('Failed to create account. Please try again.'),
        findsOneWidget,
      );
    });
  });
} 