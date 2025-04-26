import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

abstract class AuthService extends StateNotifier<bool> {
  AuthService() : super(false);
  
  bool get isAuthenticated => state;
  User? get currentUser;
  Future<void> login();
  Future<void> logout();
}

final authServiceProvider = StateNotifierProvider<AuthService, bool>((ref) {
  throw UnimplementedError('No AuthService implementation provided');
}); 