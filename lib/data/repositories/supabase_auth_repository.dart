import 'dart:async';

import 'package:meditation_app/data/models/user_model.dart';
import 'package:meditation_app/data/repositories/auth_repository.dart';
import 'package:meditation_app/data/services/supabase_service.dart';
import 'package:supabase_flutter/supabase_flutter.dart' as supabase;

/// Implementation of [AuthRepository] using Supabase
class SupabaseAuthRepository implements AuthRepository {
  /// Constructor
  SupabaseAuthRepository({
    required SupabaseService supabaseService,
  }) : _supabaseService = supabaseService;

  final SupabaseService _supabaseService;

  @override
  User? get currentUser {
    final supabaseUser = _supabaseService.currentUser;
    if (supabaseUser == null) return null;
    return _mapSupabaseUser(supabaseUser);
  }

  @override
  bool get isAuthenticated => _supabaseService.isAuthenticated;

  @override
  Map<String, dynamic>? get userMetadata => _supabaseService.userMetadata;

  @override
  AuthState get authState => _mapSupabaseAuthState(_supabaseService.currentSession != null 
    ? AuthState.authenticated 
    : AuthState.unauthenticated);

  @override
  Stream<AuthState> get authStateChanges => _supabaseService.authStateChanges
      .map((event) => _mapSupabaseAuthState(event.session != null 
        ? AuthState.authenticated 
        : AuthState.unauthenticated));

  @override
  Stream<AuthState> get sessionStateChanges => _supabaseService.sessionStateChanges
      .map((event) => _mapSupabaseAuthState(event.session != null 
        ? AuthState.authenticated 
        : AuthState.unauthenticated));

  @override
  Future<User> signUp({
    required String email,
    required String password,
    Map<String, dynamic>? metadata,
  }) async {
    try {
      final response = await _supabaseService.signUp(
        email: email,
        password: password,
      );
      if (response.user == null) {
        throw Exception('Failed to create user');
      }
      if (metadata != null) {
        await _supabaseService.updateUserMetadata(metadata);
      }
      return _mapSupabaseUser(response.user!);
    } catch (e) {
      throw _handleError(e);
    }
  }

  @override
  Future<User> signIn({
    required String email,
    required String password,
  }) async {
    try {
      final response = await _supabaseService.signIn(
        email: email,
        password: password,
      );
      if (response.user == null) {
        throw Exception('Failed to sign in');
      }
      return _mapSupabaseUser(response.user!);
    } catch (e) {
      throw _handleError(e);
    }
  }

  @override
  Future<void> signOut() async {
    try {
      await _supabaseService.signOut();
    } catch (e) {
      throw _handleError(e);
    }
  }

  @override
  Future<void> resetPassword({required String email}) async {
    try {
      await _supabaseService.resetPassword(email: email);
    } catch (e) {
      throw _handleError(e);
    }
  }

  @override
  Future<void> updatePassword({required String newPassword}) async {
    try {
      await _supabaseService.updatePassword(newPassword: newPassword);
    } catch (e) {
      throw _handleError(e);
    }
  }

  @override
  Future<User> updateUserMetadata(Map<String, dynamic> metadata) async {
    try {
      final response = await _supabaseService.updateUserMetadata(metadata);
      if (response.user == null) {
        throw Exception('Failed to update user metadata');
      }
      return _mapSupabaseUser(response.user!);
    } catch (e) {
      throw _handleError(e);
    }
  }

  @override
  Future<void> resendConfirmationEmail({required String email}) async {
    try {
      await _supabaseService.resendConfirmationEmail(email: email);
    } catch (e) {
      throw _handleError(e);
    }
  }

  AuthState _mapSupabaseAuthState(AuthState state) {
    switch (state) {
      case AuthState.initial:
        return AuthState.initial;
      case AuthState.authenticated:
        return AuthState.authenticated;
      case AuthState.unauthenticated:
        return AuthState.unauthenticated;
      case AuthState.error:
        return AuthState.error;
      default:
        return AuthState.error;
    }
  }

  User _mapSupabaseUser(supabase.User supabaseUser) {
    final metadata = supabaseUser.userMetadata ?? {};
    return User(
      id: supabaseUser.id,
      email: supabaseUser.email ?? '',
      metadata: metadata,
      isAdmin: metadata['is_admin'] == true,
    );
  }

  Exception _handleError(dynamic error) {
    if (error is supabase.AuthException) {
      return Exception(error.message);
    }
    return Exception('An unexpected error occurred');
  }
} 