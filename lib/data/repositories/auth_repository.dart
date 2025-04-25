import 'package:meditation_app/data/models/user_model.dart';

/// Abstract class defining the contract for authentication operations
abstract class AuthRepository {
  /// Get the current authenticated user
  User? get currentUser;

  /// Check if user is authenticated
  bool get isAuthenticated;

  /// Sign up a new user with email and password
  Future<User> signUp({
    required String email,
    required String password,
  });

  /// Sign in with email and password
  Future<User> signIn({
    required String email,
    required String password,
  });

  /// Sign out the current user
  Future<void> signOut();

  /// Reset password for a user
  Future<void> resetPassword({required String email});

  /// Update password for the current user
  Future<void> updatePassword({required String newPassword});

  /// Get user metadata
  Map<String, dynamic>? get userMetadata;

  /// Update user metadata
  Future<User> updateUserMetadata(Map<String, dynamic> metadata);

  /// Get auth state changes stream
  Stream<AuthState> get authStateChanges;

  /// Get session state changes stream
  Stream<AuthState> get sessionStateChanges;

  /// Resend confirmation email
  Future<void> resendConfirmationEmail({required String email});
}

/// Enum representing different authentication states
enum AuthState {
  initial,
  authenticated,
  unauthenticated,
  error,
} 