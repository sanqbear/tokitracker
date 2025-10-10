import 'package:equatable/equatable.dart';
import 'base_mode.dart';

/// Represents a manga/webtoon title (작품)
/// Corresponds to MTitle class in legacy Android app
class MangaTitle extends Equatable {
  /// Unique identifier
  final int id;

  /// Title name
  final String name;

  /// Thumbnail image URL
  final String? thumbnailUrl;

  /// Author name
  final String? author;

  /// Genre/category tags
  final List<String> tags;

  /// Release type (주간, 월간, 완결, etc.)
  final String? release;

  /// Content type (comic or webtoon)
  final BaseMode baseMode;

  const MangaTitle({
    required this.id,
    required this.name,
    this.thumbnailUrl,
    this.author,
    this.tags = const [],
    this.release,
    required this.baseMode,
  });

  /// Get URL path for this title
  /// Returns: /{comic|webtoon}/{id}
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
      ];
}
