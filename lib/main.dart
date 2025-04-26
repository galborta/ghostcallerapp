import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:meditation_app/app/core/config/supabase_config.dart';
import 'package:meditation_app/app/shared/theme/app_theme.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:meditation_app/screens/auth_test_screen.dart';
import 'package:app_links/app_links.dart';
import 'package:meditation_app/data/services/supabase_service.dart';
import 'package:go_router/go_router.dart';
import 'package:meditation_app/screens/placeholder_screen.dart';
import 'package:meditation_app/services/auth_service.dart';
import 'package:meditation_app/services/supabase_auth_service.dart';
import 'package:meditation_app/app/features/settings/presentation/screens/settings_screen.dart';
import 'package:meditation_app/app/features/admin/presentation/screens/admin_screen.dart';

void main() async {
  try {
    // Ensure Flutter bindings are initialized
    WidgetsFlutterBinding.ensureInitialized();
    
    // Load environment variables
    await dotenv.load(fileName: '.env').onError((error, stackTrace) {
      debugPrint('Error loading .env file: $error');
      throw Exception('Failed to load environment variables. Please ensure .env file exists.');
    });
    
    // Initialize Supabase with error handling
    try {
      final supabaseUrl = dotenv.env['SUPABASE_URL'];
      final supabaseAnonKey = dotenv.env['SUPABASE_ANON_KEY'];
      
      debugPrint('Attempting to initialize Supabase with:');
      debugPrint('URL: $supabaseUrl');
      debugPrint('Key length: ${supabaseAnonKey?.length ?? 0}');
      
      if (supabaseUrl == null || supabaseAnonKey == null) {
        throw Exception('SUPABASE_URL and SUPABASE_ANON_KEY must be defined in .env file');
      }

      // Verify URL format
      if (!supabaseUrl.startsWith('https://')) {
        throw Exception('SUPABASE_URL must start with https://');
      }
      
      await Supabase.initialize(
        url: supabaseUrl,
        anonKey: supabaseAnonKey,
        debug: true,
      );
      
      debugPrint('Supabase initialized successfully');
      
      // Initialize deep linking
      final appLinks = AppLinks();
      
      // Handle initial link
      final initialUri = await appLinks.getInitialAppLink();
      if (initialUri != null) {
        debugPrint('Got initial URI: $initialUri');
        await _handleDeepLink(initialUri);
      }

      // Listen to incoming links
      appLinks.uriLinkStream.listen((uri) async {
        debugPrint('Got URI: $uri');
        await _handleDeepLink(uri);
      });
      
    } catch (e) {
      debugPrint('Supabase initialization error: $e');
      rethrow;
    }
    
    runApp(
      ProviderScope(
        overrides: [
          // Override the abstract AuthService with our Supabase implementation
          authServiceProvider.overrideWith((ref) => ref.watch(supabaseAuthServiceProvider)),
        ],
        child: const MyApp(),
      ),
    );
  } catch (e, stackTrace) {
    debugPrint('Fatal error during app initialization: $e');
    debugPrint('Stack trace: $stackTrace');
    runApp(
      MaterialApp(
        home: Scaffold(
          body: Center(
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(Icons.error_outline, size: 48, color: Colors.red),
                  const SizedBox(height: 16),
                  const Text(
                    'Failed to initialize app',
                    style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    e.toString(),
                    textAlign: TextAlign.center,
                    style: const TextStyle(color: Colors.red),
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

Future<void> _handleDeepLink(Uri uri) async {
  debugPrint('Handling deep link: $uri');
  try {
    if (uri.path.contains('signup-callback')) {
      final code = uri.queryParameters['code'];
      debugPrint('Deep link params - code: $code');
      
      if (code != null) {
        debugPrint('Exchanging code for session');
        final supabaseService = SupabaseService();
        await supabaseService.exchangeCode(code);
        debugPrint('Email verified successfully');
      }
    }
  } catch (e) {
    debugPrint('Error handling deep link verification: $e');
  }
}

final routerProvider = Provider<GoRouter>((ref) {
  final authState = ref.watch(authServiceProvider);
  
  return GoRouter(
    initialLocation: '/',
    redirect: (context, state) {
      final isLoggedIn = authState;
      final isLoginRoute = state.uri.path == '/login';

      debugPrint('Current auth state - isLoggedIn: $isLoggedIn, current path: ${state.uri.path}');

      if (!isLoggedIn && !isLoginRoute) {
        debugPrint('Not logged in, redirecting to login');
        return '/login';
      }
      if (isLoggedIn && isLoginRoute) {
        debugPrint('Already logged in, redirecting to home');
        return '/';
      }
      return null;
    },
    routes: [
      GoRoute(
        path: '/login',
        builder: (context, state) => const AuthTestScreen(),
      ),
      ShellRoute(
        builder: (context, state, child) {
          return Scaffold(
            body: child,
            bottomNavigationBar: NavigationBar(
              destinations: const [
                NavigationDestination(
                  icon: Icon(Icons.home),
                  label: 'Home',
                ),
                NavigationDestination(
                  icon: Icon(Icons.self_improvement),
                  label: 'Meditate',
                ),
                NavigationDestination(
                  icon: Icon(Icons.settings),
                  label: 'Settings',
                ),
              ],
              selectedIndex: _calculateSelectedIndex(state),
              onDestinationSelected: (index) {
                switch (index) {
                  case 0:
                    context.go('/');
                    break;
                  case 1:
                    context.go('/meditate');
                    break;
                  case 2:
                    context.go('/settings');
                    break;
                }
              },
            ),
          );
        },
        routes: [
          GoRoute(
            path: '/',
            builder: (context, state) => const PlaceholderScreen(routeName: 'Home'),
          ),
          GoRoute(
            path: '/meditate',
            builder: (context, state) => const PlaceholderScreen(routeName: 'Meditate'),
          ),
          GoRoute(
            path: '/settings',
            builder: (context, state) => const SettingsScreen(),
            routes: [
              GoRoute(
                path: 'admin/upload',
                builder: (context, state) => const AdminScreen(),
              ),
            ],
          ),
        ],
      ),
    ],
  );
});

class MyApp extends ConsumerWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final router = ref.watch(routerProvider);

    return MaterialApp.router(
      title: 'Meditation App',
      theme: ThemeData(
        useMaterial3: true,
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
      ),
      routerConfig: router,
    );
  }
}

int _calculateSelectedIndex(GoRouterState state) {
  final String location = state.uri.path;
  if (location == '/') return 0;
  if (location == '/meditate') return 1;
  if (location == '/settings') return 2;
  return 0;
}
