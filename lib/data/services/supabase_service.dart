import 'package:flutter/foundation.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';

/// Service class for handling Supabase operations
class SupabaseService {
  /// Private constructor
  SupabaseService._internal();

  /// Singleton instance
  static final SupabaseService _instance = SupabaseService._internal();

  /// Factory constructor to return the singleton instance
  factory SupabaseService() => _instance;

  bool _isInitialized = false;
  late SupabaseClient _client;

  /// Get the Supabase client instance
  SupabaseClient get client {
    if (!_isInitialized) {
      throw Exception('SupabaseService must be initialized before use.');
    }
    return _client;
  }

  /// Get the current authenticated user
  User? get currentUser => Supabase.instance.client.auth.currentUser;

  /// Get the current session
  Session? get currentSession => Supabase.instance.client.auth.currentSession;

  /// Check if user is authenticated
  bool get isAuthenticated => Supabase.instance.client.auth.currentUser != null;

  /// Initialize the Supabase service
  Future<void> initialize() async {
    if (_isInitialized) return;

    final url = dotenv.env['SUPABASE_URL'];
    final anonKey = dotenv.env['SUPABASE_ANON_KEY'];

    if (url == null || anonKey == null) {
      throw Exception('Missing Supabase configuration.');
    }

    await Supabase.initialize(
      url: url,
      anonKey: anonKey,
    );

    _client = Supabase.instance.client;
    _isInitialized = true;
  }

  /// Sign up a new user with email and password
  Future<AuthResponse> signUp({
    required String email,
    required String password,
  }) async {
    return await client.auth.signUp(
      email: email,
      password: password,
    );
  }

  /// Sign in with email and password
  Future<AuthResponse> signIn({
    required String email,
    required String password,
  }) async {
    return await client.auth.signInWithPassword(
      email: email,
      password: password,
    );
  }

  /// Sign out the current user
  Future<void> signOut() async {
    await client.auth.signOut();
  }

  /// Reset password for a user
  Future<void> resetPassword({required String email}) async {
    await client.auth.resetPasswordForEmail(email);
  }

  /// Update password for the current user
  Future<void> updatePassword({required String newPassword}) async {
    if (!isAuthenticated) {
      throw Exception('User must be authenticated to update password');
    }
    await client.auth.updateUser(UserAttributes(password: newPassword));
  }

  /// Get user metadata
  Map<String, dynamic>? get userMetadata => currentUser?.userMetadata;

  /// Update user metadata
  Future<UserResponse> updateUserMetadata(Map<String, dynamic> metadata) async {
    if (!isAuthenticated) {
      throw Exception('User must be authenticated to update metadata');
    }
    return await client.auth.updateUser(UserAttributes(data: metadata));
  }

  /// Get auth state changes stream
  Stream<AuthState> get authStateChanges => client.auth.onAuthStateChange;

  /// Get session state changes stream
  Stream<AuthState> get sessionStateChanges => client.auth.onAuthStateChange.where(
        (state) => state.event == AuthChangeEvent.tokenRefreshed ||
            state.event == AuthChangeEvent.signedIn ||
            state.event == AuthChangeEvent.signedOut,
      );
}
