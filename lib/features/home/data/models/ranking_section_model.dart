import '../../domain/entities/ranking_section.dart';
import 'ranked_item_model.dart';

/// Note: Generic classes with json_serializable require explicit converters
/// This model is primarily used for data transfer, not JSON serialization
class RankingSectionModel<T> extends RankingSection<T> {
  const RankingSectionModel({
    required super.name,
    required super.items,
  });

  factory RankingSectionModel.fromEntity(RankingSection<T> entity) {
    return RankingSectionModel(
      name: entity.name,
      items: entity.items
          .map((item) => RankedItemModel<T>(
                item: item.item,
                ranking: item.ranking,
              ))
          .toList(),
    );
  }
}
