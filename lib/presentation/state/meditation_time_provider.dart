import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:meditation_app/data/repositories/meditation_time_repository.dart';
import 'dart:developer' as developer;

final meditationTimeRepositoryProvider = Provider<MeditationTimeRepository>((ref) {
  return MeditationTimeRepository(Supabase.instance.client);
});

/// Provider for persisted total meditation time from Supabase
final persistedTotalMeditationTimeProvider = StateNotifierProvider<PersistedTotalMeditationTimeNotifier, AsyncValue<int>>((ref) {
  return PersistedTotalMeditationTimeNotifier(ref.watch(meditationTimeRepositoryProvider));
});

class PersistedTotalMeditationTimeNotifier extends StateNotifier<AsyncValue<int>> {
  final MeditationTimeRepository _repository;

  PersistedTotalMeditationTimeNotifier(this._repository) : super(const AsyncValue.loading()) {
    _loadTotalTime();
  }

  Future<void> _loadTotalTime() async {
    try {
      developer.log('Loading total meditation time from Supabase');
      state = const AsyncValue.loading();
      final totalTime = await _repository.getTotalMeditationTime();
      developer.log('Loaded total meditation time: $totalTime seconds');
      state = AsyncValue.data(totalTime);
    } catch (e, st) {
      developer.log('Error loading total meditation time', error: e, stackTrace: st);
      state = AsyncValue.error(e, st);
    }
  }

  Future<void> logMeditationTime(int durationSeconds) async {
    try {
      developer.log('Logging meditation time: $durationSeconds seconds');
      await _repository.logMeditationTime(durationSeconds);
      developer.log('Successfully logged meditation time');
      
      // Debug: Get recent logs
      final recentLogs = await _repository.getRecentLogs();
      developer.log('Recent meditation logs: $recentLogs');
      
      // Reload total time
      await _loadTotalTime();
    } catch (e, st) {
      developer.log('Error logging meditation time', error: e, stackTrace: st);
      // Don't update state here - keep showing previous total
      // Just log the error for debugging
    }
  }
} 