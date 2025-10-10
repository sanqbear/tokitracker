import '../../domain/entities/comic_home_data.dart';
import 'episode_model.dart';
import 'manga_title_model.dart';
import 'ranked_item_model.dart';

/// Data model for comic/manga home page
class ComicHomeDataModel extends ComicHomeData {
  const ComicHomeDataModel({
    required super.recentManga,
    required super.rankingTitles,
    required super.weeklyRanking,
  });

  factory ComicHomeDataModel.fromEntity(ComicHomeData entity) {
    return ComicHomeDataModel(
      recentManga: entity.recentManga
          .map((e) => EpisodeModel.fromEntity(e))
          .toList(),
      rankingTitles: entity.rankingTitles
          .map((item) => RankedItemModel(
                item: MangaTitleModel.fromEntity(item.item),
                ranking: item.ranking,
              ))
          .toList(),
      weeklyRanking: entity.weeklyRanking
          .map((item) => RankedItemModel(
                item: EpisodeModel.fromEntity(item.item),
                ranking: item.ranking,
              ))
          .toList(),
    );
  }
}
