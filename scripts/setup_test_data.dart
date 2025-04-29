import 'package:supabase_flutter/supabase_flutter.dart';
import 'dart:io';
import 'package:path/path.dart' as path;

import 'package:pause/data/models/track_model.dart';
import 'package:pause/data/repositories/supabase_track_repository.dart';
import 'package:supabase/supabase.dart';

// Replace these with your Supabase project URL and anon key
const supabaseUrl = 'https://aqeqlbxavmdhjtmeungj.supabase.co';
const supabaseAnonKey = 'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6ImFxZXFsYnhhdm1kaGp0bWV1bmdqIiwicm9sZSI6ImFub24iLCJpYXQiOjE3NDU1NDE2NDgsImV4cCI6MjA2MTExNzY0OH0.UP8VaDM_YfVyNaVFd8IrissQvOGLf70YTaVbPAHFprM';

void main() async {
  final client = SupabaseClient(
    supabaseUrl,
    supabaseAnonKey,
  );

  final repository = SupabaseTrackRepository(client);

  // Create test users
  final testUsers = [
    {'id': 'user1', 'email': 'user1@test.com', 'password': 'password123'},
    {'id': 'user2', 'email': 'user2@test.com', 'password': 'password123'},
  ];

  for (final user in testUsers) {
    try {
      await client.auth.admin.createUser(
        AdminUserAttributes(
          email: user['email'] as String,
          password: user['password'] as String,
          userMetadata: {'id': user['id']},
        ),
      );
      print('Created user ${user['email']}');
    } catch (e) {
      print('Error creating user ${user['email']}: $e');
    }
  }

  // Upload test audio files
  final testTracks = [
    {
      'artistId': 'user1',
      'title': 'Meditation 1',
      'audioFile': File('assets/test/meditation1.mp3'),
      'coverImage': File('assets/test/cover1.jpg'),
    },
    {
      'artistId': 'user2',
      'title': 'Meditation 2',
      'audioFile': File('assets/test/meditation2.mp3'),
      'coverImage': File('assets/test/cover2.jpg'),
    },
  ];

  for (final track in testTracks) {
    try {
      final audioFile = track['audioFile'] as File;
      final coverImage = track['coverImage'] as File;
      final artistId = track['artistId'] as String;
      
      // Upload audio file
      final audioFileName = audioFile.path.split('/').last;
      final audioStoragePath = 'tracks/$artistId/${DateTime.now().millisecondsSinceEpoch}_$audioFileName';
      await client.storage.from('audio').upload(audioStoragePath, audioFile);
      final audioUrl = client.storage.from('audio').getPublicUrl(audioStoragePath);
      
      // Upload cover image
      final coverStoragePath = 'artists/$artistId/${DateTime.now().millisecondsSinceEpoch}_${coverImage.path.split('/').last}';
      await client.storage.from('images').upload(coverStoragePath, coverImage);
      final coverUrl = client.storage.from('images').getPublicUrl(coverStoragePath);
      
      // Create track record
      final newTrack = Track(
        id: DateTime.now().millisecondsSinceEpoch.toString(),
        title: track['title'] as String,
        artistId: artistId,
        audioUrl: audioUrl,
        audioStoragePath: audioStoragePath,
        coverImageUrl: coverUrl,
        coverImageStoragePath: coverStoragePath,
        duration: 600, // Default 10 minutes duration
        isGuided: false,
        category: 'meditation',
        isPremium: false,
      );
      
      await repository.createTrack(newTrack);
      print('Created track ${track['title']}');
    } catch (e) {
      print('Error creating track ${track['title']}: $e');
    }
  }

  print('Test data setup complete');
  exit(0);
} 