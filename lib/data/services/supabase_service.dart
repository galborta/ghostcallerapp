import 'package:flutter/foundation.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

/// Service class for handling Supabase operations
class SupabaseService {
  /// Private constructor
  SupabaseService._internal() {
    try {
      _client = Supabase.instance.client;
    } catch (e) {
      debugPrint('Error initializing SupabaseService: $e');
      rethrow;
    }
  }

  /// Singleton instance
  static final SupabaseService _instance = SupabaseService._internal();

  /// Factory constructor to return the singleton instance
  factory SupabaseService() => _instance;

  late final SupabaseClient _client;

  /// Get the Supabase client instance
  SupabaseClient get client => _client;

  /// Get the current authenticated user
  User? get currentUser => client.auth.currentUser;

  /// Get the current session
  Session? get currentSession => client.auth.currentSession;

  /// Check if user is authenticated
  bool get isAuthenticated => client.auth.currentUser != null;

  /// Sign up a new user with email and password
  Future<AuthResponse> signUp({
    required String email,
    required String password,
  }) async {
    try {
      debugPrint('Attempting to sign up user: $email');
      
      // Configure deep linking URL with exact format
      final redirectUrl = kDebugMode
          ? 'io.supabase.flutter://signup-callback/'
          : 'com.example.meditationApp://signup-callback/';
      
      debugPrint('Using redirect URL: $redirectUrl');
      
      final response = await client.auth.signUp(
        email: email,
        password: password,
        emailRedirectTo: redirectUrl,
      );
      
      if (response.user != null) {
        debugPrint('Sign up successful. User ID: ${response.user!.id}');
        debugPrint('Email confirmation status: ${response.user!.emailConfirmedAt != null}');
        debugPrint('Session status: ${response.session != null ? 'Active' : 'Pending email confirmation'}');
      } else {
        debugPrint('Sign up completed but user object is null. This might be due to email confirmation requirement.');
      }
      
      return response;
    } catch (e) {
      debugPrint('Sign up error details:');
      if (e is AuthException) {
        debugPrint('Auth error code: ${e.statusCode}');
        debugPrint('Auth error message: ${e.message}');
        rethrow;
      }
      debugPrint('Unexpected error during sign up: $e');
      throw AuthException('Failed to sign up: ${e.toString()}');
    }
  }

  /// Verify email with token
  Future<void> verifyEmail(String token) async {
    try {
      debugPrint('Attempting to verify email with token');
      await client.auth.verifyOTP(
        token: token,
        type: OtpType.signup,
      );
      debugPrint('Email verified successfully');
    } catch (e) {
      debugPrint('Error verifying email: $e');
      rethrow;
    }
  }

  /// Resend confirmation email
  Future<void> resendConfirmationEmail({required String email}) async {
    try {
      debugPrint('Attempting to resend confirmation email to: $email');
      
      // Configure deep linking URL with exact format
      final redirectUrl = kDebugMode
          ? 'io.supabase.flutter://signup-callback/'
          : 'com.example.meditationApp://signup-callback/';
          
      debugPrint('Using redirect URL: $redirectUrl');
      
      await client.auth.resend(
        type: OtpType.signup,
        email: email,
        emailRedirectTo: redirectUrl,
      );
      debugPrint('Confirmation email resent successfully');
    } catch (e) {
      debugPrint('Resend confirmation error: $e');
      if (e is AuthException) {
        rethrow;
      }
      throw AuthException('Failed to resend confirmation email: ${e.toString()}');
    }
  }

  /// Sign in with email and password
  Future<AuthResponse> signIn({
    required String email,
    required String password,
  }) async {
    try {
      debugPrint('Attempting to sign in user: $email');
      final response = await client.auth.signInWithPassword(
        email: email,
        password: password,
      );
      debugPrint('Sign in response: ${response.user != null ? 'Success' : 'Failed'}');
      return response;
    } catch (e) {
      debugPrint('Sign in error: $e');
      if (e is AuthException) {
        rethrow;
      }
      throw AuthException('Failed to sign in: ${e.toString()}');
    }
  }

  /// Sign out the current user
  Future<void> signOut() async {
    try {
      await client.auth.signOut();
    } catch (e) {
      debugPrint('Sign out error: $e');
      throw AuthException('Failed to sign out: ${e.toString()}');
    }
  }

  /// Reset password for a user
  Future<void> resetPassword({required String email}) async {
    try {
      await client.auth.resetPasswordForEmail(
        email,
        redirectTo: kDebugMode
            ? 'io.supabase.flutter://reset-callback/'
            : 'com.example.meditationApp://reset-callback/',
      );
    } catch (e) {
      debugPrint('Reset password error: $e');
      throw AuthException('Failed to reset password: ${e.toString()}');
    }
  }

  /// Update password for the current user
  Future<void> updatePassword({required String newPassword}) async {
    if (!isAuthenticated) {
      throw AuthException('User must be authenticated to update password');
    }
    try {
      await client.auth.updateUser(UserAttributes(password: newPassword));
    } catch (e) {
      debugPrint('Update password error: $e');
      throw AuthException('Failed to update password: ${e.toString()}');
    }
  }

  /// Get user metadata
  Map<String, dynamic>? get userMetadata => currentUser?.userMetadata;

  /// Update user metadata
  Future<UserResponse> updateUserMetadata(Map<String, dynamic> metadata) async {
    if (!isAuthenticated) {
      throw AuthException('User must be authenticated to update metadata');
    }
    try {
      return await client.auth.updateUser(UserAttributes(data: metadata));
    } catch (e) {
      debugPrint('Update metadata error: $e');
      throw AuthException('Failed to update metadata: ${e.toString()}');
    }
  }

  /// Get auth state changes stream
  Stream<AuthState> get authStateChanges => client.auth.onAuthStateChange;

  /// Get session state changes stream
  Stream<AuthState> get sessionStateChanges => client.auth.onAuthStateChange.where(
        (state) => state.event == AuthChangeEvent.tokenRefreshed ||
            state.event == AuthChangeEvent.signedIn ||
            state.event == AuthChangeEvent.signedOut,
      );

  /// Exchange OAuth code for session
  Future<void> exchangeCode(String code) async {
    try {
      debugPrint('Attempting to exchange code for session');
      await client.auth.exchangeCodeForSession(code);
      debugPrint('Code exchange successful');
      
      if (currentUser != null) {
        debugPrint('User is now authenticated: ${currentUser!.id}');
        debugPrint('Email confirmation status: ${currentUser!.emailConfirmedAt != null}');
      }
    } catch (e) {
      debugPrint('Error exchanging code: $e');
      rethrow;
    }
  }
}
