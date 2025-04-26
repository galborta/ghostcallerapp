import 'package:supabase_flutter/supabase_flutter.dart';
import '../models/artist_model.dart';
import 'artist_repository.dart';

class SupabaseArtistRepository implements ArtistRepository {
  final SupabaseClient _client;
  
  SupabaseArtistRepository(this._client);

  @override
  Future<List<Artist>> getArtists({bool? featured}) async {
    var query = _client.from('artists').select();
    
    if (featured != null) {
      query = query.eq('featured', featured);
    }

    final response = await query;
    return response.map((json) => Artist.fromJson(json)).toList();
  }

  @override
  Future<Artist?> getArtistById(String id) async {
    final response = await _client
        .from('artists')
        .select()
        .eq('id', id)
        .limit(1);
    
    final results = await response;
    if (results.isEmpty) return null;
    return Artist.fromJson(results.first);
  }

  @override
  Future<Artist?> getArtistByReferralCode(String referralCode) async {
    final response = await _client
        .from('artists')
        .select()
        .eq('referral_code', referralCode)
        .limit(1);
    
    final results = await response;
    if (results.isEmpty) return null;
    return Artist.fromJson(results.first);
  }

  @override
  Future<List<Artist>> searchArtists(String query) async {
    final lowercaseQuery = query.toLowerCase();
    
    final response = await _client
        .from('artists')
        .select()
        .or('name.ilike.%$lowercaseQuery%,bio.ilike.%$lowercaseQuery%');
    
    return response.map((json) => Artist.fromJson(json)).toList();
  }
} 