import 'package:supabase_flutter/supabase_flutter.dart';
import 'dart:io';
import 'package:path/path.dart' as path;

// Replace these with your Supabase project URL and anon key
const supabaseUrl = 'https://aqeqlbxavmdhjtmeungj.supabase.co';
const supabaseAnonKey = 'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6ImFxZXFsYnhhdm1kaGp0bWV1bmdqIiwicm9sZSI6ImFub24iLCJpYXQiOjE3NDU1NDE2NDgsImV4cCI6MjA2MTExNzY0OH0.UP8VaDM_YfVyNaVFd8IrissQvOGLf70YTaVbPAHFprM';

void main() async {
  // Initialize Supabase
  await Supabase.initialize(
    url: supabaseUrl,
    anonKey: supabaseAnonKey,
  );
  final supabase = Supabase.instance.client;

  try {
    // 1. Create test user
    final authResponse = await supabase.auth.signUp(
      email: 'test.artist@example.com',
      password: 'testpassword123',
      data: {
        'is_admin': true,
      },
    );
    
    final userId = authResponse.user!.id;
    
    // Update user profile
    await supabase.from('users').update({
      'full_name': 'Test Artist',
      'is_artist': true,
      'is_admin': true,
    }).eq('id', userId);

    // 2. Create artist profile
    final artistResponse = await supabase.from('artists').insert({
      'user_id': userId,
      'bio': 'A test artist for meditation tracks',
      'website_url': 'https://example.com',
      'social_links': {
        'instagram': '@testartist',
        'twitter': '@testartist'
      },
      'verified': true,
    }).select();
    
    final artistId = artistResponse.first['id'];

    // 3. Upload sample audio files
    final audioFiles = [
      {
        'path': 'assets/test_audio/meditation1.mp3',
        'title': 'Morning Meditation',
        'description': 'Start your day with mindfulness',
        'duration': 600, // 10 minutes
        'category': 'morning',
      },
      {
        'path': 'assets/test_audio/meditation2.mp3',
        'title': 'Evening Relaxation',
        'description': 'Unwind and relax before bed',
        'duration': 900, // 15 minutes
        'category': 'evening',
      },
    ];

    for (final audio in audioFiles) {
      // Upload audio file
      final audioFile = File(audio['path'] as String);
      final audioFileName = path.basename(audioFile.path);
      final audioStoragePath = 'public/meditation_tracks/$audioFileName';
      
      await supabase.storage.from('audio').upload(
        audioStoragePath,
        audioFile,
        fileOptions: const FileOptions(
          cacheControl: '3600',
          upsert: false,
        ),
      );

      // Get the public URL
      final audioUrl = supabase.storage.from('audio').getPublicUrl(audioStoragePath);

      // Create track record
      await supabase.from('meditation_tracks').insert({
        'artist_id': artistId,
        'title': audio['title'],
        'description': audio['description'],
        'duration': audio['duration'],
        'audio_url': audioUrl,
        'category': audio['category'],
        'tags': ['test', audio['category']],
        'is_premium': false,
      });
    }

    print('Test data setup completed successfully!');
    print('Login with:');
    print('Email: test.artist@example.com');
    print('Password: testpassword123');

  } catch (e) {
    print('Error setting up test data: $e');
  }
} 