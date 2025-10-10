import 'package:json_annotation/json_annotation.dart';
import 'package:tokitracker/features/home/domain/entities/base_mode.dart';
import 'package:tokitracker/features/manga/data/models/episode_model.dart';
import 'package:tokitracker/features/manga/domain/entities/title_detail.dart';

part 'title_detail_model.g.dart';

@JsonSerializable(explicitToJson: true)
class TitleDetailModel extends TitleDetail {
  @override
  final List<EpisodeModel> episodes;

  const TitleDetailModel({
    required super.id,
    required super.name,
    super.thumbnailUrl,
    super.author,
    super.tags,
    super.release,
    required super.baseMode,
    this.episodes = const [],
    super.recommendCount,
    super.isBookmarked,
    super.bookmarkLink,
  }) : super(episodes: episodes);

  factory TitleDetailModel.fromJson(Map<String, dynamic> json) =>
      _$TitleDetailModelFromJson(json);

  Map<String, dynamic> toJson() => _$TitleDetailModelToJson(this);

  factory TitleDetailModel.fromEntity(TitleDetail entity) {
    return TitleDetailModel(
      id: entity.id,
      name: entity.name,
      thumbnailUrl: entity.thumbnailUrl,
      author: entity.author,
      tags: entity.tags,
      release: entity.release,
      baseMode: entity.baseMode,
      episodes: entity.episodes
          .map((e) => EpisodeModel.fromEntity(e))
          .toList(),
      recommendCount: entity.recommendCount,
      isBookmarked: entity.isBookmarked,
      bookmarkLink: entity.bookmarkLink,
    );
  }
}
