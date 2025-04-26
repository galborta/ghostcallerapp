import 'dart:io';
import 'package:dotenv/dotenv.dart';
import 'package:supabase/supabase.dart';

void main() async {
  try {
    // Load environment variables
    final env = DotEnv()..load();
    final supabaseUrl = env['SUPABASE_URL'];
    final supabaseKey = env['SUPABASE_SERVICE_ROLE_KEY'];

    if (supabaseUrl == null || supabaseKey == null) {
      print('Error: SUPABASE_URL and SUPABASE_SERVICE_ROLE_KEY must be set in .env file');
      exit(1);
    }

    // Initialize Supabase client
    final client = SupabaseClient(supabaseUrl, supabaseKey);

    try {
      // Create audio bucket
      await client.storage.createBucket(
        'audio',
        const BucketOptions(
          public: true,
          fileSizeLimit: 500 * 1024 * 1024, // 500MB
          allowedMimeTypes: ['audio/mpeg', 'audio/wav'],
        ),
      );
      print('Created or verified audio bucket');

      // Create images bucket
      await client.storage.createBucket(
        'images',
        const BucketOptions(
          public: true,
          fileSizeLimit: 5 * 1024 * 1024, // 5MB
          allowedMimeTypes: ['image/jpeg', 'image/png', 'image/webp'],
        ),
      );
      print('Created or verified images bucket');

      print('\n✓ Storage setup completed successfully');
      exit(0);
    } catch (e) {
      print('Error setting up storage: $e');
      exit(1);
    } finally {
      client.dispose();
    }
  } catch (e) {
    print('Unexpected error: $e');
    exit(1);
  }
} 