import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:meditation_app/services/auth_service.dart';

class AuthScreen extends ConsumerWidget {
  const AuthScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Scaffold(
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              Theme.of(context).colorScheme.primaryContainer,
              Theme.of(context).colorScheme.secondaryContainer,
            ],
          ),
        ),
        child: SafeArea(
          child: Center(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(24.0),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  // Logo or App Name
                  Icon(
                    Icons.self_improvement,
                    size: 80,
                    color: Theme.of(context).colorScheme.primary,
                  ),
                  const SizedBox(height: 24),
                  Text(
                    'Meditation App',
                    style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                          color: Theme.of(context).colorScheme.primary,
                          fontWeight: FontWeight.bold,
                        ),
                  ),
                  const SizedBox(height: 48),
                  // Supabase Auth UI
                  SupabaseAuthUI(
                    onSuccess: (response) {
                      // Auth state is handled by SupabaseAuthService listener
                      debugPrint('Auth success: ${response.session?.user.email}');
                    },
                    onError: (error) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: Text(error.message),
                          backgroundColor: Theme.of(context).colorScheme.error,
                        ),
                      );
                    },
                    // Customize the appearance
                    appearance: SupabaseAuthUIAppearance(
                      theme: SupabaseAuthUITheme(
                        buttonTheme: SupabaseButtonTheme(
                          backgroundColor: Theme.of(context).colorScheme.primary,
                          borderRadius: BorderRadius.circular(8),
                        ),
                        inputTheme: SupabaseInputTheme(
                          borderRadius: BorderRadius.circular(8),
                        ),
                        socialButtonTheme: SupabaseSocialTheme(
                          borderRadius: BorderRadius.circular(8),
                          spacing: 8,
                        ),
                      ),
                    ),
                    // Configure providers and view
                    providers: const [
                      EmailAuthProvider(),
                      GoogleAuthProvider(),
                      AppleAuthProvider(),
                    ],
                    view: SupabaseAuthUIView.signIn,
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
} 