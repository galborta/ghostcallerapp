import 'package:flutter/foundation.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../models/artist_model.dart';
import 'artist_repository.dart';

class SupabaseArtistRepository implements ArtistRepository {
  final SupabaseClient _client;
  
  SupabaseArtistRepository(this._client);

  @override
  Future<List<Artist>> getArtists({bool? featured}) async {
    try {
      debugPrint('🔍 Starting to fetch artists...');
      debugPrint('Featured filter: $featured');
      
      var query = _client.from('artists').select();
      debugPrint('Base query created');
      
      if (featured != null) {
        query = query.eq('featured', featured);
        debugPrint('Added featured filter: $featured');
      }

      debugPrint('Executing query...');
      final response = await query;
      debugPrint('Raw response data: $response');
      
      if (response == null) {
        debugPrint('❌ Response is null');
        return [];
      }

      if (response is! List) {
        debugPrint('❌ Response is not a List: ${response.runtimeType}');
        return [];
      }

      debugPrint('📊 Response length: ${response.length}');
      
      final artists = response.map((json) {
        debugPrint('Processing artist data: $json');
        try {
          return Artist.fromJson(json as Map<String, dynamic>);
        } catch (e) {
          debugPrint('❌ Error parsing artist: $e');
          debugPrint('Problematic JSON: $json');
          rethrow;
        }
      }).toList();
      
      debugPrint('✅ Successfully parsed ${artists.length} artists');
      debugPrint('First artist (if any): ${artists.isNotEmpty ? artists.first.name : "none"}');
      
      return artists;
    } catch (e, stack) {
      debugPrint('❌ Error fetching artists: $e');
      debugPrint('Stack trace: $stack');
      debugPrint('Client status: ${_client.auth.currentSession != null ? "authenticated" : "not authenticated"}');
      rethrow;
    }
  }

  @override
  Future<Artist?> getArtistById(String id) async {
    try {
      debugPrint('🔍 Fetching artist with id: $id');
      final response = await _client
          .from('artists')
          .select()
          .eq('id', id)
          .limit(1)
          .single();
      
      debugPrint('Raw response: $response');
      
      if (response == null) {
        debugPrint('❌ No artist found with id: $id');
        return null;
      }

      final artist = Artist.fromJson(response as Map<String, dynamic>);
      debugPrint('✅ Found artist: ${artist.name}');
      return artist;
    } catch (e, stack) {
      debugPrint('❌ Error fetching artist by id: $e');
      debugPrint('Stack trace: $stack');
      rethrow;
    }
  }

  @override
  Future<Artist?> getArtistByReferralCode(String referralCode) async {
    try {
      debugPrint('🔍 Fetching artist with referral code: $referralCode');
      final response = await _client
          .from('artists')
          .select()
          .eq('referral_code', referralCode)
          .limit(1)
          .single();
      
      debugPrint('Raw response: $response');
      
      if (response == null) {
        debugPrint('❌ No artist found with referral code: $referralCode');
        return null;
      }

      final artist = Artist.fromJson(response as Map<String, dynamic>);
      debugPrint('✅ Found artist: ${artist.name}');
      return artist;
    } catch (e, stack) {
      debugPrint('❌ Error fetching artist by referral code: $e');
      debugPrint('Stack trace: $stack');
      rethrow;
    }
  }

  @override
  Future<List<Artist>> searchArtists(String query) async {
    try {
      debugPrint('🔍 Searching artists with query: $query');
      final lowercaseQuery = query.toLowerCase();
      
      final response = await _client
          .from('artists')
          .select()
          .or('name.ilike.%$lowercaseQuery%,bio.ilike.%$lowercaseQuery%');
      
      debugPrint('Raw search response: $response');
      
      if (response == null) {
        debugPrint('❌ Search response is null');
        return [];
      }

      if (response is! List) {
        debugPrint('❌ Search response is not a List: ${response.runtimeType}');
        return [];
      }

      final artists = response.map((json) {
        debugPrint('Processing search result: $json');
        try {
          return Artist.fromJson(json as Map<String, dynamic>);
        } catch (e) {
          debugPrint('❌ Error parsing search result: $e');
          debugPrint('Problematic JSON: $json');
          rethrow;
        }
      }).toList();
      
      debugPrint('✅ Found ${artists.length} artists matching query');
      return artists;
    } catch (e, stack) {
      debugPrint('❌ Error searching artists: $e');
      debugPrint('Stack trace: $stack');
      rethrow;
    }
  }
} 