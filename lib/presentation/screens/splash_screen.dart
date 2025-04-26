import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:meditation_app/config/router.dart';
import 'package:lottie/lottie.dart';

class SplashScreen extends ConsumerStatefulWidget {
  const SplashScreen({super.key});

  @override
  ConsumerState<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends ConsumerState<SplashScreen>
    with SingleTickerProviderStateMixin {
  late final AnimationController _animationController;
  late final Animation<double> _fadeInAnimation;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1500),
    );

    _fadeInAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _animationController,
      curve: Curves.easeInOut,
    ));

    // Start animation and handle navigation after delay
    _animationController.forward().then((_) => _handleNavigation());
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  Future<void> _handleNavigation() async {
    // Add a small delay after animation completes
    await Future.delayed(const Duration(milliseconds: 500));

    if (!mounted) return;

    // Check auth state and navigate accordingly
    final authState = ref.read(authStateProvider);
    final route = authState.isAuthenticated ? RoutePath.home : RoutePath.login;
    
    if (!mounted) return;
    context.go(route);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).colorScheme.background,
      body: Center(
        child: FadeTransition(
          opacity: _fadeInAnimation,
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              // App Logo using Mourier font
              SizedBox(
                width: 160,
                height: 160,
                child: Center(
                  child: Text(
                    'O',
                    key: const Key('splash_logo'),
                    style: TextStyle(
                      fontFamily: 'Mourier',
                      fontSize: 120,
                      color: Theme.of(context).colorScheme.primary,
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 24),
              // Loading animation
              SizedBox(
                width: 60,
                height: 60,
                child: Lottie.asset(
                  'assets/animations/loading.json',
                  key: const Key('splash_loading_animation'),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
} 