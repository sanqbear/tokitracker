import 'package:equatable/equatable.dart';
import 'package:tokitracker/features/home/domain/entities/base_mode.dart';
import 'package:tokitracker/features/manga/domain/entities/episode.dart';

class TitleDetail extends Equatable {
  final int id;
  final String name;
  final String? thumbnailUrl;
  final String? author;
  final List<String> tags;
  final String? release;
  final BaseMode baseMode;
  final List<Episode> episodes;
  final int recommendCount;
  final bool isBookmarked;
  final String? bookmarkLink;

  const TitleDetail({
    required this.id,
    required this.name,
    this.thumbnailUrl,
    this.author,
    this.tags = const [],
    this.release,
    required this.baseMode,
    this.episodes = const [],
    this.recommendCount = 0,
    this.isBookmarked = false,
    this.bookmarkLink,
  });

  String getUrl() => '/${baseMode.toUrlPath()}/$id';

  @override
  List<Object?> get props => [
        id,
        name,
        thumbnailUrl,
        author,
        tags,
        release,
        baseMode,
        episodes,
        recommendCount,
        isBookmarked,
        bookmarkLink,
      ];
}
