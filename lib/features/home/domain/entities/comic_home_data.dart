import 'package:equatable/equatable.dart';
import 'episode.dart';
import 'manga_title.dart';
import 'ranked_item.dart';

/// Data structure for comic/manga home page
/// Corresponds to MainPage class in legacy Android app
class ComicHomeData extends Equatable {
  /// Recently added manga episodes
  final List<Episode> recentManga;

  /// Best ranking titles (일본만화 베스트)
  final List<RankedItem<MangaTitle>> rankingTitles;

  /// Weekly best manga episodes (주간 베스트)
  final List<RankedItem<Episode>> weeklyRanking;

  const ComicHomeData({
    required this.recentManga,
    required this.rankingTitles,
    required this.weeklyRanking,
  });

  @override
  List<Object?> get props => [recentManga, rankingTitles, weeklyRanking];
}
