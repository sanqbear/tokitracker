import 'package:flutter/material.dart';
import 'package:tokitracker/features/manga/domain/entities/episode.dart';

class EpisodeListItem extends StatelessWidget {
  final Episode episode;
  final VoidCallback? onTap;
  final bool isBookmarked;

  const EpisodeListItem({
    super.key,
    required this.episode,
    this.onTap,
    this.isBookmarked = false,
  });

  @override
  Widget build(BuildContext context) {
    return ListTile(
      title: Text(
        episode.name,
        style: TextStyle(
          fontWeight: isBookmarked ? FontWeight.bold : FontWeight.normal,
        ),
      ),
      subtitle: episode.date != null
          ? Text(
              episode.date!,
              style: Theme.of(context).textTheme.bodySmall,
            )
          : null,
      trailing: isBookmarked
          ? const Icon(Icons.bookmark, color: Colors.blue)
          : const Icon(Icons.chevron_right),
      onTap: onTap,
      tileColor: isBookmarked
          ? Theme.of(context).primaryColor.withValues(alpha: 0.1)
          : null,
    );
  }
}
