import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';

/// List item widget for ranked items
class RankedListItem extends StatelessWidget {
  final int ranking;
  final String title;
  final String? subtitle;
  final String? thumbnailUrl;
  final VoidCallback? onTap;

  const RankedListItem({
    super.key,
    required this.ranking,
    required this.title,
    this.subtitle,
    this.thumbnailUrl,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return ListTile(
      leading: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Ranking number
          SizedBox(
            width: 30,
            child: Text(
              '$ranking',
              style: TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 16,
                color: ranking <= 3 ? Colors.orange : Colors.grey[600],
              ),
              textAlign: TextAlign.center,
            ),
          ),
          // Thumbnail if available
          if (thumbnailUrl != null)
            ClipRRect(
              borderRadius: BorderRadius.circular(4.0),
              child: CachedNetworkImage(
                imageUrl: thumbnailUrl!,
                width: 40,
                height: 40,
                fit: BoxFit.cover,
                placeholder: (context, url) => Container(
                  width: 40,
                  height: 40,
                  color: Colors.grey[300],
                ),
                errorWidget: (context, url, error) => Container(
                  width: 40,
                  height: 40,
                  color: Colors.grey[300],
                  child: const Icon(Icons.error, size: 20),
                ),
              ),
            ),
        ],
      ),
      title: Text(
        title,
        maxLines: 1,
        overflow: TextOverflow.ellipsis,
      ),
      subtitle: subtitle != null
          ? Text(
              subtitle!,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            )
          : null,
      trailing: const Icon(Icons.chevron_right),
      onTap: onTap,
    );
  }
}
