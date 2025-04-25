import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:meditation_app/services/auth_service.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class SupabaseAuthService extends AuthService {
  final SupabaseClient _supabase;

  SupabaseAuthService(this._supabase) : super() {
    // Initialize state based on current auth status
    state = _supabase.auth.currentSession != null;
    
    // Listen to auth state changes
    _supabase.auth.onAuthStateChange.listen((data) {
      final AuthChangeEvent event = data.event;
      switch (event) {
        case AuthChangeEvent.signedIn:
        case AuthChangeEvent.tokenRefreshed:
          state = true;
          break;
        case AuthChangeEvent.signedOut:
        case AuthChangeEvent.userDeleted:
          state = false;
          break;
        default:
          break;
      }
    });
  }

  @override
  Future<void> login() async {
    // This is a placeholder - actual login will be handled by Supabase UI
    throw UnimplementedError('Login is handled by Supabase Auth UI');
  }

  @override
  Future<void> logout() async {
    await _supabase.auth.signOut();
  }
}

final supabaseAuthServiceProvider = Provider<SupabaseAuthService>((ref) {
  final supabase = Supabase.instance.client;
  return SupabaseAuthService(supabase);
}); 