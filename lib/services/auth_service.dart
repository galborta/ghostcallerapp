import 'package:flutter_riverpod/flutter_riverpod.dart';

abstract class AuthService extends StateNotifier<bool> {
  AuthService() : super(false);
  
  bool get isAuthenticated => state;
  Future<void> login();
  Future<void> logout();
}

final authServiceProvider = StateNotifierProvider<AuthService, bool>((ref) {
  throw UnimplementedError('No AuthService implementation provided');
}); 