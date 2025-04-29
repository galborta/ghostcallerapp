import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:meditation_app/app/core/config/supabase_config.dart';
import 'package:meditation_app/config/router.dart';
import 'package:meditation_app/app/shared/theme/app_theme.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:app_links/app_links.dart';
import 'package:meditation_app/data/services/supabase_service.dart';

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
      const ProviderScope(
        child: MyApp(),
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

class MyApp extends ConsumerWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final router = ref.watch(routerProvider);

    return MaterialApp.router(
      title: 'Meditation App',
      theme: AppTheme.lightTheme,
      darkTheme: AppTheme.darkTheme,
      routerConfig: router,
    );
  }
}
