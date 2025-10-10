import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:tokitracker/features/manga/domain/entities/title_detail.dart';

class TitleDetailHeader extends StatelessWidget {
  final TitleDetail titleDetail;
  final VoidCallback? onBookmarkTap;
  final VoidCallback? onFirstEpisodeTap;
  final VoidCallback? onAuthorTap;
  final Function(String)? onTagTap;

  const TitleDetailHeader({
    super.key,
    required this.titleDetail,
    this.onBookmarkTap,
    this.onFirstEpisodeTap,
    this.onAuthorTap,
    this.onTagTap,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.all(16),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Thumbnail
                if (titleDetail.thumbnailUrl != null)
                  ClipRRect(
                    borderRadius: BorderRadius.circular(8),
                    child: CachedNetworkImage(
                      imageUrl: titleDetail.thumbnailUrl!,
                      width: 120,
                      height: 160,
                      fit: BoxFit.cover,
                      placeholder: (context, url) => Container(
                        width: 120,
                        height: 160,
                        color: Colors.grey[300],
                        child: const Center(
                          child: CircularProgressIndicator(),
                        ),
                      ),
                      errorWidget: (context, url, error) => Container(
                        width: 120,
                        height: 160,
                        color: Colors.grey[300],
                        child: const Icon(Icons.error),
                      ),
                    ),
                  ),
                const SizedBox(width: 16),
                // Info
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Title
                      Text(
                        titleDetail.name,
                        style: Theme.of(context).textTheme.titleLarge?.copyWith(
                              fontWeight: FontWeight.bold,
                            ),
                      ),
                      const SizedBox(height: 8),
                      // Author
                      if (titleDetail.author != null)
                        InkWell(
                          onTap: onAuthorTap,
                          child: Text(
                            titleDetail.author!,
                            style: TextStyle(
                              color: Theme.of(context).primaryColor,
                              decoration: TextDecoration.underline,
                            ),
                          ),
                        ),
                      const SizedBox(height: 4),
                      // Release
                      if (titleDetail.release != null)
                        Text(
                          titleDetail.release!,
                          style: Theme.of(context).textTheme.bodySmall,
                        ),
                      const SizedBox(height: 8),
                      // Stats
                      Row(
                        children: [
                          const Icon(Icons.recommend, size: 16),
                          const SizedBox(width: 4),
                          Text(
                            titleDetail.recommendCount.toString(),
                            style: Theme.of(context).textTheme.bodySmall,
                          ),
                          const SizedBox(width: 16),
                          const Icon(Icons.list, size: 16),
                          const SizedBox(width: 4),
                          Text(
                            '${titleDetail.episodes.length}화',
                            style: Theme.of(context).textTheme.bodySmall,
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            // Tags
            if (titleDetail.tags.isNotEmpty)
              Wrap(
                spacing: 8,
                runSpacing: 8,
                children: titleDetail.tags.map((tag) {
                  return ActionChip(
                    label: Text(tag),
                    onPressed: () => onTagTap?.call(tag),
                  );
                }).toList(),
              ),
            const SizedBox(height: 16),
            // Action buttons
            Row(
              children: [
                Expanded(
                  child: ElevatedButton.icon(
                    onPressed: onFirstEpisodeTap,
                    icon: const Icon(Icons.play_arrow),
                    label: const Text('첫화보기'),
                  ),
                ),
                const SizedBox(width: 8),
                if (titleDetail.bookmarkLink != null)
                  IconButton.filledTonal(
                    onPressed: onBookmarkTap,
                    icon: Icon(
                      titleDetail.isBookmarked
                          ? Icons.bookmark
                          : Icons.bookmark_border,
                    ),
                  ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
