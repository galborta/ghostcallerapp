import 'package:flutter_dotenv/flutter_dotenv.dart';

class EnvConfig {
  static Future<void> initialize() async {
    try {
      await dotenv.load(fileName: '.env');
      print('Environment variables loaded successfully');
    } catch (e) {
      print('Error loading environment variables: $e');
      print('Attempting to load .env.example instead...');
      await dotenv.load(fileName: '.env.example');
    }
  }

  static String get supabaseUrl => dotenv.env['SUPABASE_URL'] ?? '';
  static String get supabaseAnonKey => dotenv.env['SUPABASE_ANON_KEY'] ?? '';
  static String get appName => dotenv.env['APP_NAME'] ?? 'PAUSE';
  static String get appEnv => dotenv.env['APP_ENV'] ?? 'development';

  static bool get isDevelopment => appEnv == 'development';
  static bool get isProduction => appEnv == 'production';
  
  // Debug method to verify environment variables
  static void printConfig() {
    print('App Configuration:');
    print('App Name: $appName');
    print('Environment: $appEnv');
    print('Supabase URL: $supabaseUrl');
    print('Supabase Anon Key: ${supabaseAnonKey.substring(0, 8)}...');
  }
} 