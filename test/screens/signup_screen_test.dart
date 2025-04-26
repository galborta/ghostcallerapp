import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:meditation_app/data/models/user_model.dart';
import 'package:meditation_app/data/repositories/auth_repository.dart';
import 'package:meditation_app/presentation/screens/auth/signup_screen.dart';
import 'package:meditation_app/presentation/state/auth_provider.dart';
import 'package:mocktail/mocktail.dart';

class MockAuthRepository extends Mock implements AuthRepository {}

void main() {
  late MockAuthRepository mockAuthRepository;

  setUp(() {
    mockAuthRepository = MockAuthRepository();
  });

  Widget createSignupScreen() {
    return ProviderScope(
      overrides: [
        authRepositoryProvider.overrideWithValue(mockAuthRepository),
      ],
      child: MaterialApp(
        home: SignupScreen(),
      ),
    );
  }

  group('SignupScreen UI Elements', () {
    testWidgets('renders all UI elements correctly', (tester) async {
      await tester.pumpWidget(createSignupScreen());

      // Verify headings
      expect(find.text('Create Account'), findsOneWidget);
      expect(
        find.text('Begin your mindfulness journey today'),
        findsOneWidget,
      );

      // Verify input fields
      expect(find.widgetWithText(TextFormField, 'Email'), findsOneWidget);
      expect(find.widgetWithText(TextFormField, 'Password'), findsOneWidget);
      expect(
        find.widgetWithText(TextFormField, 'Referral Code (Optional)'),
        findsOneWidget,
      );

      // Verify buttons and links
      expect(find.widgetWithText(ElevatedButton, 'Create Account'), findsOneWidget);
      expect(find.text('Already have an account?'), findsOneWidget);
      expect(find.text('Sign In'), findsOneWidget);
    });

    testWidgets('password field shows helper text', (tester) async {
      await tester.pumpWidget(createSignupScreen());

      expect(
        find.text('Must be at least 8 characters with 1 uppercase letter and 1 number'),
        findsOneWidget,
      );
    });

    testWidgets('referral code field shows helper text', (tester) async {
      await tester.pumpWidget(createSignupScreen());

      expect(
        find.text('Enter a referral code if you have one'),
        findsOneWidget,
      );
    });
  });

  group('Form Validation', () {
    testWidgets('shows errors for empty email and password', (tester) async {
      await tester.pumpWidget(createSignupScreen());

      // Try to submit without filling fields
      await tester.tap(find.text('Create Account'));
      await tester.pump();

      // Verify error messages
      expect(find.text('Email is required'), findsOneWidget);
      expect(find.text('Password is required'), findsOneWidget);
    });

    testWidgets('shows error for invalid email format', (tester) async {
      await tester.pumpWidget(createSignupScreen());

      // Enter invalid email
      await tester.enterText(
        find.widgetWithText(TextFormField, 'Email'),
        'invalid-email',
      );
      await tester.enterText(
        find.widgetWithText(TextFormField, 'Password'),
        'ValidPass1',
      );

      // Try to submit
      await tester.tap(find.text('Create Account'));
      await tester.pump();

      // Verify error message
      expect(find.text('Please enter a valid email'), findsOneWidget);
    });

    testWidgets('validates password requirements', (tester) async {
      await tester.pumpWidget(createSignupScreen());

      final passwordField = find.widgetWithText(TextFormField, 'Password');

      // Test too short password
      await tester.enterText(passwordField, 'short');
      await tester.tap(find.text('Create Account'));
      await tester.pump();
      expect(
        find.text('Password must be at least 8 characters'),
        findsOneWidget,
      );

      // Test missing uppercase
      await tester.enterText(passwordField, 'password123');
      await tester.tap(find.text('Create Account'));
      await tester.pump();
      expect(
        find.text('Password must contain at least one uppercase letter'),
        findsOneWidget,
      );

      // Test missing number
      await tester.enterText(passwordField, 'PasswordNoNumber');
      await tester.tap(find.text('Create Account'));
      await tester.pump();
      expect(
        find.text('Password must contain at least one number'),
        findsOneWidget,
      );
    });
  });

  group('Signup Functionality', () {
    const email = 'test@example.com';
    const password = 'ValidPass123';
    const referralCode = 'REF123';

    testWidgets('calls sign up when form is valid', (tester) async {
      // Setup success response
      when(() => mockAuthRepository.signUp(
            email: email,
            password: password,
          )).thenAnswer((_) async => User(
            id: 'test-id',
            email: email,
            metadata: {},
            createdAt: DateTime.now().toIso8601String(),
          ));

      when(() => mockAuthRepository.updateUserMetadata(any()))
          .thenAnswer((_) async => User(
                id: 'test-id',
                email: email,
                metadata: {'referral_code': referralCode},
                createdAt: DateTime.now().toIso8601String(),
              ));

      await tester.pumpWidget(createSignupScreen());

      // Fill in form
      await tester.enterText(
        find.widgetWithText(TextFormField, 'Email'),
        email,
      );
      await tester.enterText(
        find.widgetWithText(TextFormField, 'Password'),
        password,
      );
      await tester.enterText(
        find.widgetWithText(TextFormField, 'Referral Code (Optional)'),
        referralCode,
      );

      // Submit form
      await tester.tap(find.text('Create Account'));
      await tester.pump();

      // Verify sign up was called
      verify(() => mockAuthRepository.signUp(
            email: email,
            password: password,
          )).called(1);

      // Verify referral code was processed
      verify(() => mockAuthRepository.updateUserMetadata({
            'referral_code': referralCode,
          })).called(1);
    });

    testWidgets('shows error message on failed signup', (tester) async {
      // Setup error response
      when(() => mockAuthRepository.signUp(
            email: any(named: 'email'),
            password: any(named: 'password'),
          )).thenThrow(Exception('Failed to create account'));

      await tester.pumpWidget(createSignupScreen());

      // Fill in form
      await tester.enterText(
        find.widgetWithText(TextFormField, 'Email'),
        email,
      );
      await tester.enterText(
        find.widgetWithText(TextFormField, 'Password'),
        password,
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

    testWidgets('shows loading indicator during signup', (tester) async {
      // Setup delayed response
      when(() => mockAuthRepository.signUp(
            email: any(named: 'email'),
            password: any(named: 'password'),
          )).thenAnswer((_) => Future.delayed(
            const Duration(milliseconds: 100),
            () => User(
              id: 'test-id',
              email: email,
              metadata: {},
              createdAt: DateTime.now().toIso8601String(),
            ),
          ));

      await tester.pumpWidget(createSignupScreen());

      // Fill in form
      await tester.enterText(
        find.widgetWithText(TextFormField, 'Email'),
        email,
      );
      await tester.enterText(
        find.widgetWithText(TextFormField, 'Password'),
        password,
      );

      // Submit form
      await tester.tap(find.text('Create Account'));
      await tester.pump();

      // Verify loading indicator
      expect(find.byType(CircularProgressIndicator), findsOneWidget);

      // Wait for signup to complete
      await tester.pumpAndSettle();
    });
  });

  group('Referral Code Handling', () {
    testWidgets('skips referral code update if empty', (tester) async {
      const email = 'test@example.com';
      const password = 'ValidPass123';

      // Setup success response
      when(() => mockAuthRepository.signUp(
            email: email,
            password: password,
          )).thenAnswer((_) async => User(
            id: 'test-id',
            email: email,
            metadata: {},
            createdAt: DateTime.now().toIso8601String(),
          ));

      await tester.pumpWidget(createSignupScreen());

      // Fill in form without referral code
      await tester.enterText(
        find.widgetWithText(TextFormField, 'Email'),
        email,
      );
      await tester.enterText(
        find.widgetWithText(TextFormField, 'Password'),
        password,
      );

      // Submit form
      await tester.tap(find.text('Create Account'));
      await tester.pump();

      // Verify updateUserMetadata was not called
      verifyNever(() => mockAuthRepository.updateUserMetadata(any()));
    });
  });
} 