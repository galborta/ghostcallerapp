import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:meditation_app/presentation/widgets/scaffold_with_bottom_nav.dart';
import 'package:meditation_app/app/features/meditation/presentation/screens/session_setup_screen.dart';
import 'package:meditation_app/app/features/settings/presentation/screens/admin_screen.dart';
import 'package:meditation_app/presentation/screens/home_screen.dart';
import 'package:meditation_app/presentation/screens/artist_detail_screen.dart';
import 'package:meditation_app/app/features/settings/presentation/screens/settings_screen.dart';
import 'package:meditation_app/app/features/meditation/presentation/screens/meditation_player_screen.dart';
import 'package:meditation_app/app/features/calendar/presentation/screens/calendar_screen.dart';
import 'package:meditation_app/presentation/screens/auth_screen.dart';
import 'package:meditation_app/presentation/state/auth_provider.dart';

// Route path constants
class RoutePath {
  static const String splash = '/splash';
  static const String login = '/login';
  static const String register = '/register';
  static const String forgotPassword = '/forgot-password';
  static const String home = '/';
  static const String artistDetail = '/artist/:id';
  static const String sessionSetup = '/session-setup/:artistId';
  static const String sessionSetupWithTrack = '/session-setup/:artistId/:trackId';
  static const String meditationPlayer = '/meditation/:id';
  static const String calendar = '/calendar';
  static const String settings = '/settings';
  static const String adminUpload = '/settings/admin/upload';
}

// Route name constants
class RouteName {
  static const String splash = 'splash';
  static const String login = 'login';
  static const String register = 'register';
  static const String forgotPassword = 'forgotPassword';
  static const String home = 'home';
  static const String artistDetail = 'artistDetail';
  static const String sessionSetup = 'sessionSetup';
  static const String sessionSetupWithTrack = 'sessionSetupWithTrack';
  static const String meditationPlayer = 'meditationPlayer';
  static const String calendar = 'calendar';
  static const String settings = 'settings';
  static const String adminUpload = 'adminUpload';
}

final routerProvider = Provider<GoRouter>((ref) {
  final isAuthenticated = ref.watch(isAuthenticatedProvider);

  return GoRouter(
    initialLocation: RoutePath.home,
    debugLogDiagnostics: true,
    redirect: (context, state) {
      final isLoggingIn = state.matchedLocation == RoutePath.login;
      
      if (!isAuthenticated && !isLoggingIn) {
        return RoutePath.login;
      }
      
      if (isAuthenticated && isLoggingIn) {
        return RoutePath.home;
      }
      
      return null;
    },
    routes: [
      // Auth routes
      GoRoute(
        path: RoutePath.login,
        name: RouteName.login,
        builder: (context, state) => const AuthScreen(),
      ),

      // Main app shell with bottom navigation
      ShellRoute(
        builder: (context, state, child) => ScaffoldWithBottomNav(child: child),
        routes: [
          // Home tab
          GoRoute(
            path: RoutePath.home,
            name: RouteName.home,
            builder: (context, state) => const HomeScreen(),
            routes: [
              // Nested routes under home
              GoRoute(
                path: 'artist/:id',
                name: RouteName.artistDetail,
                builder: (context, state) => ArtistDetailScreen(
                  artistId: state.pathParameters['id']!,
                ),
              ),
              GoRoute(
                path: 'session-setup/:artistId',
                name: RouteName.sessionSetup,
                builder: (context, state) => SessionSetupScreen(
                  artistId: state.pathParameters['artistId']!,
                ),
              ),
              GoRoute(
                path: 'session-setup/:artistId/:trackId',
                name: RouteName.sessionSetupWithTrack,
                builder: (context, state) => SessionSetupScreen(
                  artistId: state.pathParameters['artistId']!,
                  trackId: state.pathParameters['trackId'],
                ),
              ),
            ],
          ),
          
          // Calendar tab
          GoRoute(
            path: RoutePath.calendar,
            name: RouteName.calendar,
            builder: (context, state) => const CalendarScreen(),
          ),
          
          // Settings tab
          GoRoute(
            path: RoutePath.settings,
            name: RouteName.settings,
            builder: (context, state) => const SettingsScreen(),
            routes: [
              GoRoute(
                path: 'admin/upload',
                name: RouteName.adminUpload,
                builder: (context, state) => const AdminScreen(),
              ),
            ],
          ),
          
          // Meditation player route (at shell level)
          GoRoute(
            path: RoutePath.meditationPlayer,
            name: RouteName.meditationPlayer,
            builder: (context, state) => MeditationPlayerRoute(
              meditationId: state.pathParameters['id']!,
            ),
          ),
        ],
      ),
    ],
  );
});

class AuthState {
  bool get isAuthenticated => true;
}

// Temporary screen widgets for compilation
class LoginScreen extends StatelessWidget {
  const LoginScreen({super.key});
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Login')),
      body: Center(
        child: ElevatedButton(
          onPressed: () => context.go(RoutePath.home),
          child: const Text('Go to Home'),
        ),
      ),
    );
  }
}

class RegisterScreen extends StatelessWidget {
  const RegisterScreen({super.key});
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Register')),
      body: Center(
        child: ElevatedButton(
          onPressed: () => context.go(RoutePath.login),
          child: const Text('Go to Login'),
        ),
      ),
    );
  }
}

class ForgotPasswordScreen extends StatelessWidget {
  const ForgotPasswordScreen({super.key});
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Forgot Password')),
      body: Center(
        child: ElevatedButton(
          onPressed: () => context.go(RoutePath.login),
          child: const Text('Back to Login'),
        ),
      ),
    );
  }
}

class MeditationPlayerRoute extends StatelessWidget {
  const MeditationPlayerRoute({super.key, required this.meditationId});
  final String meditationId;
  
  @override
  Widget build(BuildContext context) {
    final extra = GoRouterState.of(context).extra as Map<String, dynamic>?;
    final isGuidedMeditation = extra?['isGuidedMeditation'] as bool? ?? true;
    final duration = extra?['duration'] as int? ?? 10;

    return MeditationPlayerScreen(
      trackId: meditationId,
      isGuidedMeditation: isGuidedMeditation,
      durationMinutes: duration,
    );
  }
} 