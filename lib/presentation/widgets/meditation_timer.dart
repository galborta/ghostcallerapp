import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:meditation_app/presentation/state/meditation_time_provider.dart';
import 'package:meditation_app/presentation/theme/text_styles.dart';

class MeditationTimer extends ConsumerStatefulWidget {
  const MeditationTimer({super.key});

  @override
  ConsumerState<MeditationTimer> createState() => _MeditationTimerState();
}

class _MeditationTimerState extends ConsumerState<MeditationTimer> {
  int _seconds = 0;
  bool _isRunning = false;
  Timer? _timer;

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  void _toggleTimer() {
    setState(() {
      _isRunning = !_isRunning;
      if (_isRunning) {
        _startTimer();
      } else {
        _stopTimer();
      }
    });
  }

  void _startTimer() {
    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      setState(() {
        _seconds++;
      });
    });
  }

  void _stopTimer() {
    _timer?.cancel();
    _logMeditationTime();
  }

  Future<void> _logMeditationTime() async {
    try {
      await ref.read(persistedTotalMeditationTimeProvider.notifier).logMeditationTime(_seconds);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Meditation time logged successfully'),
            backgroundColor: Colors.green,
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Failed to log meditation time: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
    setState(() {
      _seconds = 0;
    });
  }

  String get _formattedTime {
    final minutes = (_seconds / 60).floor();
    final remainingSeconds = _seconds % 60;
    return '${minutes.toString().padLeft(2, '0')}:${remainingSeconds.toString().padLeft(2, '0')}';
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Text(
          _formattedTime,
          style: AppTextStyles.displayLarge,
        ),
        const SizedBox(height: 16),
        FloatingActionButton(
          onPressed: _toggleTimer,
          child: Icon(_isRunning ? Icons.pause : Icons.play_arrow),
        ),
      ],
    );
  }
} 