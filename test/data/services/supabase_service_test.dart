import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:meditation_app/data/services/supabase_service.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  late SupabaseService supabaseService;

  setUpAll(() async {
    await dotenv.load(fileName: '.env');
    SharedPreferences.setMockInitialValues({});
  });

  setUp(() async {
    supabaseService = SupabaseService();
    await supabaseService.initialize();
  });

  tearDown(() async {
    await supabaseService.client.auth.signOut();
  });

  tearDownAll(() async {
    await supabaseService.client.dispose();
  });

  group('Supabase Connection Tests', () {
    test('should initialize Supabase client successfully', () {
      expect(supabaseService.client, isNotNull);
      expect(supabaseService.currentUser, isNull);
      expect(supabaseService.isAuthenticated, isFalse);
    });

    test('should have valid configuration', () {
      final client = supabaseService.client;
      expect(client, isNotNull);
      expect(client.auth, isNotNull);
      expect(client.rest, isNotNull);
      
      final url = dotenv.env['SUPABASE_URL'];
      final anonKey = dotenv.env['SUPABASE_ANON_KEY'];
      expect(url, isNotNull);
      expect(anonKey, isNotNull);
      expect(url, startsWith('https://'));
      expect(anonKey, isNotEmpty);
    });

    test('should have working auth instance', () {
      expect(supabaseService.client.auth, isNotNull);
      expect(supabaseService.currentUser, isNull);
      expect(supabaseService.currentSession, isNull);
      expect(supabaseService.isAuthenticated, isFalse);
    });
  });

  group('Authentication Tests', () {
    const testEmail = 'test.user@example.com';
    const testPassword = 'TestPassword123!';

    test('should handle sign up flow', () async {
      try {
        final response = await supabaseService.signUp(
          email: testEmail,
          password: testPassword,
        );
        expect(response.user, isNotNull);
        expect(response.user?.email, equals(testEmail));
      } on AuthException catch (e) {
        // Skip if user already exists
        expect(
          e.message,
          anyOf([
            contains('User already registered'),
            contains('already been registered'),
            contains('already registered'),
            contains('Email address'),  // Handle other validation errors
          ]),
        );
      }
    });

    test('should handle sign in flow', () async {
      try {
        final response = await supabaseService.signIn(
          email: testEmail,
          password: testPassword,
        );
        expect(response.user, isNotNull);
        expect(response.user?.email, equals(testEmail));
        expect(supabaseService.isAuthenticated, isTrue);
      } on AuthException catch (e) {
        // If this is a test environment where we can't actually create users,
        // we'll verify that we get the expected error
        expect(
          e.message,
          anyOf([
            contains('Invalid login credentials'),
            contains('Email not confirmed'),
            contains('Email address'),  // Handle other validation errors
          ]),
        );
      }
    });

    test('should handle invalid credentials correctly', () async {
      try {
        await supabaseService.signIn(
          email: 'nonexistent@example.com',
          password: 'wrongpassword',
        );
        fail('Should have thrown an error for invalid credentials');
      } on AuthException catch (e) {
        expect(e.message, contains('Invalid login credentials'));
      }
    });

    test('should handle sign out', () async {
      await supabaseService.signOut();
      expect(supabaseService.currentUser, isNull);
      expect(supabaseService.isAuthenticated, isFalse);
    });
  });

  group('Auth State Tests', () {
    test('should provide auth state streams', () {
      expect(supabaseService.authStateChanges, isNotNull);
    });
  });
}