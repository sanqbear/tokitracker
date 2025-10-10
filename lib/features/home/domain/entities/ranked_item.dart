import 'package:equatable/equatable.dart';

/// Generic wrapper for items with ranking position
/// Used for ranking lists (weekly best, best titles, etc.)
class RankedItem<T> extends Equatable {
  /// The actual item (MangaTitle, Episode, etc.)
  final T item;

  /// Ranking position (1-based)
  final int ranking;

  const RankedItem({
    required this.item,
    required this.ranking,
  });

  @override
  List<Object?> get props => [item, ranking];
}
