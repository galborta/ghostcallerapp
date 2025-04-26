import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:meditation_app/data/models/user_model.dart';
import 'package:meditation_app/data/repositories/auth_repository.dart';
import 'package:meditation_app/data/repositories/supabase_auth_repository.dart';
import 'package:meditation_app/data/services/supabase_service.dart';

/// Provider for the auth repository implementation
final authRepositoryProvider = Provider<AuthRepository>((ref) {
  final supabaseService = ref.watch(supabaseServiceProvider);
  return SupabaseAuthRepository(supabaseService);
});

/// Provider that streams authentication state changes
final authStateProvider = StreamProvider<AuthState>((ref) {
  final authRepository = ref.watch(authRepositoryProvider);
  return authRepository.authStateChanges;
});

/// Provider for the current user
final currentUserProvider = StateProvider<User?>((ref) {
  final authRepository = ref.watch(authRepositoryProvider);
  return authRepository.currentUser;
});

/// Provider for the authentication status
final isAuthenticatedProvider = StateProvider<bool>((ref) {
  final authRepository = ref.watch(authRepositoryProvider);
  return authRepository.isAuthenticated;
}); 