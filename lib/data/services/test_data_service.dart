import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:flutter/foundation.dart';

class TestDataService {
  final SupabaseClient _client;

  TestDataService(this._client);

  Future<void> addTestArtist() async {
    try {
      debugPrint('Adding test artist...');
      
      final testArtist = {
        'id': '1',
        'name': 'Sarah Johnson',
        'bio': 'Experienced meditation guide with over 10 years of practice in mindfulness and stress reduction techniques.',
        'short_bio': 'Mindfulness expert & meditation guide',
        'image_url': 'https://images.unsplash.com/photo-1544367567-0f2fcb009e0b?q=80&w=1000',
        'featured': true,
        'revenue_share_percentage': 60,
        'referral_code': 'SARAH2024',
        'created_at': DateTime.now().toIso8601String(),
        'updated_at': DateTime.now().toIso8601String(),
      };

      await _client.from('artists').upsert(testArtist);
      debugPrint('Test artist added successfully');
    } catch (e, stack) {
      debugPrint('Error adding test artist: $e');
      debugPrint('Stack trace: $stack');
      rethrow;
    }
  }
} 