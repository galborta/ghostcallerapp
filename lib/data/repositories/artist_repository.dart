import '../models/artist_model.dart';

abstract class ArtistRepository {
  /// Get all artists, optionally filtered by featured status
  Future<List<Artist>> getArtists({bool? featured});

  /// Get a specific artist by their ID
  Future<Artist?> getArtistById(String id);

  /// Get an artist by their referral code
  Future<Artist?> getArtistByReferralCode(String referralCode);

  /// Search artists by name or bio
  Future<List<Artist>> searchArtists(String query);
} 