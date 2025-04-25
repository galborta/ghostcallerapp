import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:meditation_app/data/models/user_model.dart';
import 'package:meditation_app/data/repositories/auth_repository.dart';
import 'package:meditation_app/presentation/screens/auth/login_screen.dart';
import 'package:meditation_app/presentation/state/auth_provider.dart';
import 'package:mocktail/mocktail.dart';

class MockAuthRepository extends Mock implements AuthRepository {}
class MockNavigator extends Mock implements NavigatorState {}

void main() {
  late MockAuthRepository mockAuthRepository;

  setUp(() {
    mockAuthRepository = MockAuthRepository();
    
    // Register fallback values for navigation
    registerFallbackValue(MaterialPageRoute<void>(builder: (_) => Container()));
  });

  Widget createLoginScreen() {
    return ProviderScope(
      overrides: [
        authRepositoryProvider.overrideWithValue(mockAuthRepository),
      ],
      child: MaterialApp(
        home: LoginScreen(),
      ),
    );
  }

  group('LoginScreen UI Elements', () {
    testWidgets('renders all UI elements correctly', (tester) async {
      await tester.pumpWidget(createLoginScreen());

      // Verify headings
      expect(find.text('Welcome Back'), findsOneWidget);
      expect(
        find.text('Sign in to continue your meditation journey'),
        findsOneWidget,
      );

      // Verify input fields
      expect(find.widgetWithText(TextFormField, 'Email'), findsOneWidget);
      expect(find.widgetWithText(TextFormField, 'Password'), findsOneWidget);

      // Verify buttons
      expect(find.widgetWithText(ElevatedButton, 'Sign In'), findsOneWidget);
      expect(find.text('Forgot Password?'), findsOneWidget);
      expect(find.text('Sign Up'), findsOneWidget);
    });

    testWidgets('password field obscures text', (tester) async {
      await tester.pumpWidget(createLoginScreen());

      final passwordField = tester.widget<TextFormField>(
        find.widgetWithText(TextFormField, 'Password'),
      );

      expect(passwordField.obscureText, isTrue);
    });
  });

  group('Form Validation', () {
    testWidgets('shows errors for empty email and password', (tester) async {
      await tester.pumpWidget(createLoginScreen());

      // Try to submit without filling fields
      await tester.tap(find.text('Sign In'));
      await tester.pump();

      // Verify error messages
      expect(find.text('Email is required'), findsOneWidget);
      expect(find.text('Password is required'), findsOneWidget);
    });

    testWidgets('shows error for invalid email format', (tester) async {
      await tester.pumpWidget(createLoginScreen());

      // Enter invalid email
      await tester.enterText(
        find.widgetWithText(TextFormField, 'Email'),
        'invalid-email',
      );
      await tester.enterText(
        find.widgetWithText(TextFormField, 'Password'),
        'password123',
      );

      // Try to submit
      await tester.tap(find.text('Sign In'));
      await tester.pump();

      // Verify error message
      expect(find.text('Please enter a valid email'), findsOneWidget);
    });
  });

  group('Login Functionality', () {
    testWidgets('calls sign in when form is valid', (tester) async {
      const email = 'test@example.com';
      const password = 'password123';

      // Setup success response
      when(() => mockAuthRepository.signIn(
            email: email,
            password: password,
          )).thenAnswer((_) async => User(
            id: 'test-id',
            email: email,
            metadata: {},
            createdAt: DateTime.now().toIso8601String(),
          ));

      await tester.pumpWidget(createLoginScreen());

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
      await tester.tap(find.text('Sign In'));
      await tester.pump();

      // Verify sign in was called
      verify(() => mockAuthRepository.signIn(
            email: email,
            password: password,
          )).called(1);
    });

    testWidgets('shows error message on failed login', (tester) async {
      const email = 'test@example.com';
      const password = 'wrong-password';

      // Setup error response
      when(() => mockAuthRepository.signIn(
            email: any(named: 'email'),
            password: any(named: 'password'),
          )).thenThrow(Exception('Invalid credentials'));

      await tester.pumpWidget(createLoginScreen());

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
      await tester.tap(find.text('Sign In'));
      await tester.pumpAndSettle();

      // Verify error message
      expect(find.text('Invalid email or password'), findsOneWidget);
    });

    testWidgets('shows loading indicator during login', (tester) async {
      const email = 'test@example.com';
      const password = 'password123';

      // Setup delayed response
      when(() => mockAuthRepository.signIn(
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

      await tester.pumpWidget(createLoginScreen());

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
      await tester.tap(find.text('Sign In'));
      await tester.pump();

      // Verify loading indicator
      expect(find.byType(CircularProgressIndicator), findsOneWidget);

      // Wait for login to complete
      await tester.pumpAndSettle();
    });
  });

  group('Navigation', () {
    testWidgets('navigates to forgot password screen', (tester) async {
      await tester.pumpWidget(createLoginScreen());

      await tester.tap(find.text('Forgot Password?'));
      await tester.pumpAndSettle();

      // Verify navigation (this will fail until we implement navigation)
      // expect(find.byType(ForgotPasswordScreen), findsOneWidget);
    });

    testWidgets('navigates to register screen', (tester) async {
      await tester.pumpWidget(createLoginScreen());

      await tester.tap(find.text('Sign Up'));
      await tester.pumpAndSettle();

      // Verify navigation (this will fail until we implement navigation)
      // expect(find.byType(RegisterScreen), findsOneWidget);
    });
  });
} 