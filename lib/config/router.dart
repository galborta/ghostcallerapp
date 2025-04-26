import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:meditation_app/presentation/widgets/scaffold_with_bottom_nav.dart';
import 'package:meditation_app/app/features/meditation/presentation/screens/session_setup_screen.dart';
import 'package:meditation_app/app/features/settings/presentation/screens/admin_screen.dart';

// Route path constants
class RoutePath {
  static const String splash = '/';
  static const String login = '/login';
  static const String register = '/register';
  static const String forgotPassword = '/forgot-password';
  static const String home = '/home';
  static const String artistDetail = '/artist/:id';
  static const String sessionSetup = '/session-setup/:artistId';
  static const String sessionSetupWithTrack = '/session-setup/:artistId/:trackId';
  static const String meditationPlayer = '/meditation/:id';
  static const String calendar = '/calendar';
  static const String settings = '/settings';
  static const String adminUpload = '/admin/upload';
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
  // TODO: Replace with actual auth state provider
  final authState = ref.watch(authStateProvider);

  return GoRouter(
    initialLocation: RoutePath.splash,
    debugLogDiagnostics: true,
    redirect: (context, state) {
      // Get the current path
      final currentPath = state.uri.path;
      
      // Check if the path is one of the auth routes
      final isAuthRoute = currentPath == RoutePath.login ||
          currentPath == RoutePath.register ||
          currentPath == RoutePath.forgotPassword;

      // If user is not authenticated and trying to access protected route,
      // redirect to login
      if (!authState.isAuthenticated && !isAuthRoute && currentPath != RoutePath.splash) {
        return RoutePath.login;
      }

      // If user is authenticated and trying to access auth route,
      // redirect to home
      if (authState.isAuthenticated && isAuthRoute) {
        return RoutePath.home;
      }

      // No redirect needed
      return null;
    },
    routes: [
      // Splash screen
      GoRoute(
        path: RoutePath.splash,
        name: RouteName.splash,
        builder: (context, state) => const SplashScreen(),
      ),
      
      // Auth routes
      GoRoute(
        path: RoutePath.login,
        name: RouteName.login,
        builder: (context, state) => const LoginScreen(),
      ),
      GoRoute(
        path: RoutePath.register,
        name: RouteName.register,
        builder: (context, state) => const RegisterScreen(),
      ),
      GoRoute(
        path: RoutePath.forgotPassword,
        name: RouteName.forgotPassword,
        builder: (context, state) => const ForgotPasswordScreen(),
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
              GoRoute(
                path: 'meditation/:id',
                name: RouteName.meditationPlayer,
                builder: (context, state) => MeditationPlayerScreen(
                  meditationId: state.pathParameters['id']!,
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
                path: 'upload',
                name: RouteName.adminUpload,
                builder: (context, state) => const AdminScreen(),
              ),
            ],
          ),
        ],
      ),
    ],
  );
});

// Temporary auth state provider for compilation
// TODO: Replace with actual auth state provider implementation
final authStateProvider = Provider<AuthState>((ref) => AuthState());

class AuthState {
  bool get isAuthenticated => false;
}

// Temporary screen widgets for compilation
// TODO: Replace with actual screen implementations
class SplashScreen extends StatelessWidget {
  const SplashScreen({super.key});
  @override
  Widget build(BuildContext context) => const Placeholder();
}

class LoginScreen extends StatelessWidget {
  const LoginScreen({super.key});
  @override
  Widget build(BuildContext context) => const Placeholder();
}

class RegisterScreen extends StatelessWidget {
  const RegisterScreen({super.key});
  @override
  Widget build(BuildContext context) => const Placeholder();
}

class ForgotPasswordScreen extends StatelessWidget {
  const ForgotPasswordScreen({super.key});
  @override
  Widget build(BuildContext context) => const Placeholder();
}

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});
  @override
  Widget build(BuildContext context) => const Placeholder();
}

class ArtistDetailScreen extends StatelessWidget {
  const ArtistDetailScreen({super.key, required this.artistId});
  final String artistId;
  @override
  Widget build(BuildContext context) => const Placeholder();
}

class SessionSetupScreen extends StatelessWidget {
  const SessionSetupScreen({super.key, required this.artistId, this.trackId});
  final String artistId;
  final String? trackId;
  @override
  Widget build(BuildContext context) => const Placeholder();
}

class MeditationPlayerScreen extends StatelessWidget {
  const MeditationPlayerScreen({super.key, required this.meditationId});
  final String meditationId;
  @override
  Widget build(BuildContext context) => const Placeholder();
}

class CalendarScreen extends StatelessWidget {
  const CalendarScreen({super.key});
  @override
  Widget build(BuildContext context) => const Placeholder();
}

class SettingsScreen extends StatelessWidget {
  const SettingsScreen({super.key});
  @override
  Widget build(BuildContext context) => const Placeholder();
} 