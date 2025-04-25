import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

/// Supabase configuration class
class SupabaseConfig {
  SupabaseConfig._();

  static late final String url;
  static late final String anonKey;

  /// Initialize Supabase client
  static Future<void> initialize() async {
    url = dotenv.env['SUPABASE_URL'] ?? '';
    anonKey = dotenv.env['SUPABASE_ANON_KEY'] ?? '';

    if (url.isEmpty || anonKey.isEmpty) {
      throw Exception('Supabase configuration missing. Please check your .env file.');
    }

    await Supabase.initialize(
      url: url,
      anonKey: anonKey,
      debug: dotenv.env['APP_ENV'] == 'development',
    );
  }

  /// Get Supabase client instance
  static SupabaseClient get client => Supabase.instance.client;

  /// Print Supabase configuration (only in development)
  static void printConfig() {
    if (dotenv.env['APP_ENV'] == 'development') {
      print('Supabase Configuration:');
      print('URL: $url');
      print('Anon Key: ${anonKey.substring(0, 8)}...'); // Only show first 8 chars
    }
  }
} 