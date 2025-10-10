import 'package:equatable/equatable.dart';
import 'base_mode.dart';

/// Represents a manga/webtoon episode (화)
/// Corresponds to Manga class in legacy Android app (simplified version for listing)
class Episode extends Equatable {
  /// Unique identifier
  final int id;

  /// Episode name/title
  final String name;

  /// Publication date
  final String? date;

  /// Thumbnail image URL
  final String? thumbnailUrl;

  /// Content type (comic or webtoon)
  final BaseMode baseMode;

  const Episode({
    required this.id,
    required this.name,
    this.date,
    this.thumbnailUrl,
    required this.baseMode,
  });

  /// Get URL path for this episode
  /// Returns: /{comic|webtoon}/{id}
  String getUrl() => '/${baseMode.toUrlPath()}/$id';

  @override
  List<Object?> get props => [
        id,
        name,
        date,
        thumbnailUrl,
        baseMode,
      ];
}
