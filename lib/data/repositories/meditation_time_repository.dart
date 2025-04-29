import 'package:supabase_flutter/supabase_flutter.dart';

class MeditationTimeRepository {
  final SupabaseClient _client;

  MeditationTimeRepository(this._client);

  /// Log meditation time for current user
  Future<void> logMeditationTime(int durationSeconds) async {
    try {
      final userId = _client.auth.currentUser?.id;
      if (userId == null) {
        throw Exception('User not authenticated');
      }

      // Format date as YYYY-MM-DD for PostgreSQL
      final now = DateTime.now();
      final formattedDate = "${now.year.toString().padLeft(4, '0')}-${now.month.toString().padLeft(2, '0')}-${now.day.toString().padLeft(2, '0')}";
      
      await _client.from('meditation_time_logs').insert({
        'user_id': userId,
        'duration_seconds': durationSeconds,
        'meditation_date': formattedDate,
      });
    } catch (e) {
      throw Exception('Failed to log meditation time: $e');
    }
  }

  /// Get total meditation time for current user
  Future<int> getTotalMeditationTime() async {
    try {
      final userId = _client.auth.currentUser?.id;
      if (userId == null) {
        throw Exception('User not authenticated');
      }

      final response = await _client
          .rpc('get_total_meditation_time', params: {
            'user_id': userId,
          });
      
      // Handle null response from database
      return (response ?? 0) as int;
    } catch (e) {
      throw Exception('Failed to get total meditation time: $e');
    }
  }

  /// Get meditation time by date range
  Future<List<Map<String, dynamic>>> getMeditationTimeByDateRange(
    DateTime startDate,
    DateTime endDate,
  ) async {
    try {
      final userId = _client.auth.currentUser?.id;
      if (userId == null) {
        throw Exception('User not authenticated');
      }

      // Format dates as YYYY-MM-DD for PostgreSQL
      final formattedStartDate = "${startDate.year.toString().padLeft(4, '0')}-${startDate.month.toString().padLeft(2, '0')}-${startDate.day.toString().padLeft(2, '0')}";
      final formattedEndDate = "${endDate.year.toString().padLeft(4, '0')}-${endDate.month.toString().padLeft(2, '0')}-${endDate.day.toString().padLeft(2, '0')}";

      final response = await _client
          .rpc('get_meditation_time_by_date_range', params: {
            'user_id': userId,
            'start_date': formattedStartDate,
            'end_date': formattedEndDate,
          });
      
      return List<Map<String, dynamic>>.from(response as List? ?? []);
    } catch (e) {
      throw Exception('Failed to get meditation time by date range: $e');
    }
  }

  /// Debug: Get raw meditation logs for current user
  Future<List<Map<String, dynamic>>> getRecentLogs() async {
    try {
      final userId = _client.auth.currentUser?.id;
      if (userId == null) {
        throw Exception('User not authenticated');
      }

      final response = await _client
          .from('meditation_time_logs')
          .select()
          .eq('user_id', userId)
          .order('created_at', ascending: false)
          .limit(10);
      
      return List<Map<String, dynamic>>.from(response as List? ?? []);
    } catch (e) {
      throw Exception('Failed to get recent logs: $e');
    }
  }
} 