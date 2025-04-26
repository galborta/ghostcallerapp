import 'package:flutter/material.dart';
import 'package:meditation_app/data/repositories/auth_repository.dart';
import 'package:meditation_app/data/repositories/supabase_auth_repository.dart';
import 'package:meditation_app/data/services/supabase_service.dart';

class AuthTestScreen extends StatefulWidget {
  const AuthTestScreen({super.key});

  @override
  State<AuthTestScreen> createState() => _AuthTestScreenState();
}

class _AuthTestScreenState extends State<AuthTestScreen> {
  final _authRepository = SupabaseAuthRepository(
    supabaseService: SupabaseService(),
  );
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  String _status = 'Not authenticated';

  @override
  void initState() {
    super.initState();
    _authRepository.authStateChanges.listen((state) {
      setState(() {
        _status = state.toString();
      });
    });
  }

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  Future<void> _signUp() async {
    try {
      await _authRepository.signUp(
        email: _emailController.text,
        password: _passwordController.text,
      );
      _showMessage('Sign up successful!');
    } catch (e) {
      _showMessage('Sign up failed: $e');
    }
  }

  Future<void> _signIn() async {
    try {
      await _authRepository.signIn(
        email: _emailController.text,
        password: _passwordController.text,
      );
      _showMessage('Sign in successful!');
    } catch (e) {
      _showMessage('Sign in failed: $e');
    }
  }

  Future<void> _signOut() async {
    try {
      await _authRepository.signOut();
      _showMessage('Sign out successful!');
    } catch (e) {
      _showMessage('Sign out failed: $e');
    }
  }

  Future<void> _resetPassword() async {
    try {
      await _authRepository.resetPassword(email: _emailController.text);
      _showMessage('Password reset email sent!');
    } catch (e) {
      _showMessage('Password reset failed: $e');
    }
  }

  Future<void> _resendConfirmation() async {
    try {
      await _authRepository.resendConfirmationEmail(email: _emailController.text);
      _showMessage('Confirmation email resent!');
    } catch (e) {
      _showMessage('Failed to resend confirmation: $e');
    }
  }

  void _showMessage(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message)),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Auth Test'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Text('Status: $_status'),
            const SizedBox(height: 16),
            TextField(
              controller: _emailController,
              decoration: const InputDecoration(
                labelText: 'Email',
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 8),
            TextField(
              controller: _passwordController,
              decoration: const InputDecoration(
                labelText: 'Password',
                border: OutlineInputBorder(),
              ),
              obscureText: true,
            ),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: _signUp,
              child: const Text('Sign Up'),
            ),
            const SizedBox(height: 8),
            ElevatedButton(
              onPressed: _signIn,
              child: const Text('Sign In'),
            ),
            const SizedBox(height: 8),
            ElevatedButton(
              onPressed: _signOut,
              child: const Text('Sign Out'),
            ),
            const SizedBox(height: 8),
            ElevatedButton(
              onPressed: _resetPassword,
              child: const Text('Reset Password'),
            ),
            const SizedBox(height: 8),
            ElevatedButton(
              onPressed: _resendConfirmation,
              child: const Text('Resend Confirmation Email'),
            ),
            const SizedBox(height: 16),
            if (_authRepository.currentUser != null) ...[
              Text('Current User: ${_authRepository.currentUser?.email}'),
              Text('User Metadata: ${_authRepository.userMetadata}'),
            ],
          ],
        ),
      ),
    );
  }
} 