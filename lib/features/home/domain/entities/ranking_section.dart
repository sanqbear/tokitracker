import 'package:equatable/equatable.dart';
import 'ranked_item.dart';

/// Represents a section of ranked items with a name
/// Corresponds to Ranking<T> class in legacy Android app
class RankingSection<T> extends Equatable {
  /// Section name (e.g., "일반연재 최신", "주간 베스트")
  final String name;

  /// List of ranked items in this section
  final List<RankedItem<T>> items;

  const RankingSection({
    required this.name,
    required this.items,
  });

  @override
  List<Object?> get props => [name, items];
}
