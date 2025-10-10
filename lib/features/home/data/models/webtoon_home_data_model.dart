import '../../domain/entities/webtoon_home_data.dart';
import 'manga_title_model.dart';
import 'ranked_item_model.dart';
import 'ranking_section_model.dart';

/// Data model for webtoon home page
class WebtoonHomeDataModel extends WebtoonHomeData {
  const WebtoonHomeDataModel({
    required super.sections,
  });

  factory WebtoonHomeDataModel.fromEntity(WebtoonHomeData entity) {
    return WebtoonHomeDataModel(
      sections: entity.sections
          .map((section) => RankingSectionModel(
                name: section.name,
                items: section.items
                    .map((item) => RankedItemModel(
                          item: MangaTitleModel.fromEntity(item.item),
                          ranking: item.ranking,
                        ))
                    .toList(),
              ))
          .toList(),
    );
  }
}
