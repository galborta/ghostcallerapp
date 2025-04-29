import 'package:flutter/material.dart';
import '../../data/models/track_model.dart';
import '../theme/spacing.dart';

class TrackListItem extends StatelessWidget {
  final Track track;
  final VoidCallback? onTap;

  const TrackListItem({
    super.key,
    required this.track,
    this.onTap,
  });

  String _formatDuration(int seconds) {
    final minutes = (seconds / 60).floor();
    return '$minutes min';
  }

  @override
  Widget build(BuildContext context) {
    return ListTile(
      onTap: onTap,
      contentPadding: const EdgeInsets.symmetric(
        horizontal: Spacing.medium,
        vertical: Spacing.small,
      ),
      leading: Container(
        width: 48,
        height: 48,
        decoration: BoxDecoration(
          color: Theme.of(context).colorScheme.primaryContainer,
          borderRadius: BorderRadius.circular(12),
        ),
        child: Icon(
          track.isGuided ? Icons.record_voice_over : Icons.music_note,
          color: Theme.of(context).colorScheme.onPrimaryContainer,
        ),
      ),
      title: Text(
        track.title,
        style: Theme.of(context).textTheme.titleMedium?.copyWith(
              color: Theme.of(context).colorScheme.onSurface,
            ),
      ),
      subtitle: Row(
        children: [
          Icon(
            track.isGuided ? Icons.headset : Icons.music_note,
            size: 16,
            color: Theme.of(context).colorScheme.onSurfaceVariant,
          ),
          const SizedBox(width: Spacing.small),
          Text(
            track.isGuided ? 'Guided' : 'Music Only',
            style: Theme.of(context).textTheme.bodySmall?.copyWith(
                  color: Theme.of(context).colorScheme.onSurfaceVariant,
                ),
          ),
          const SizedBox(width: Spacing.medium),
          Icon(
            Icons.schedule,
            size: 16,
            color: Theme.of(context).colorScheme.onSurfaceVariant,
          ),
          const SizedBox(width: Spacing.small),
          Text(
            _formatDuration(track.duration),
            style: Theme.of(context).textTheme.bodySmall?.copyWith(
                  color: Theme.of(context).colorScheme.onSurfaceVariant,
                ),
          ),
        ],
      ),
      trailing: Icon(
        Icons.play_circle_outline,
        color: Theme.of(context).colorScheme.primary,
        size: 32,
      ),
    );
  }
} 