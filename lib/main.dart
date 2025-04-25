import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:meditation_app/app/core/config/supabase_config.dart';
import 'package:meditation_app/app/shared/theme/app_theme.dart';

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
      await SupabaseConfig.initialize();
      
      // Print configuration in development mode
      if (dotenv.env['APP_ENV'] == 'development') {
        SupabaseConfig.printConfig();
      }
    } catch (e) {
      debugPrint('Supabase initialization error: $e');
      rethrow; // Re-throw to be caught by the outer try-catch
    }
    
    // Run the app wrapped with ProviderScope for Riverpod
    runApp(
      const ProviderScope(
        child: MainApp(),
      ),
    );
  } catch (e, stackTrace) {
    debugPrint('Fatal error during app initialization: $e');
    debugPrint('Stack trace: $stackTrace');
    // Show error UI instead of crashing
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

class MainApp extends StatelessWidget {
  const MainApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: dotenv.env['APP_NAME'] ?? 'PAUSE',
      theme: AppTheme.lightTheme,
      darkTheme: AppTheme.darkTheme,
      themeMode: ThemeMode.system, // Follows system theme
      home: const Scaffold(
        body: Center(
          child: Text('Hello World'),
        ),
      ),
    );
  }
}
