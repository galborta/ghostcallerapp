import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:meditation_app/presentation/state/meditation_time_provider.dart';
import 'package:meditation_app/presentation/theme/text_styles.dart';

class MeditationStats extends ConsumerWidget {
  const MeditationStats({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final totalTimeAsync = ref.watch(persistedTotalMeditationTimeProvider);

    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Text(
          'Total Meditation Time',
          style: AppTextStyles.titleMedium,
        ),
        const SizedBox(height: 8),
        totalTimeAsync.when(
          data: (totalSeconds) => Text(
            '${(totalSeconds / 60).floor()} minutes',
            style: AppTextStyles.displayLarge,
          ),
          loading: () => const CircularProgressIndicator(),
          error: (error, stackTrace) => Column(
            children: [
              const Icon(Icons.error_outline, color: Colors.red),
              const SizedBox(height: 8),
              Text(
                'Error loading meditation time',
                style: AppTextStyles.bodyMedium.copyWith(color: Colors.red),
              ),
            ],
          ),
        ),
      ],
    );
  }
} 