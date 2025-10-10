import '../../domain/entities/ranked_item.dart';

/// Note: Generic classes with json_serializable require explicit converters
/// This model is primarily used for data transfer, not JSON serialization
class RankedItemModel<T> extends RankedItem<T> {
  const RankedItemModel({
    required super.item,
    required super.ranking,
  });

  factory RankedItemModel.fromEntity(RankedItem<T> entity) {
    return RankedItemModel(
      item: entity.item,
      ranking: entity.ranking,
    );
  }
}
