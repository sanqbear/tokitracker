import 'package:json_annotation/json_annotation.dart';
import 'package:tokitracker/features/home/domain/entities/base_mode.dart';
import 'package:tokitracker/features/manga/domain/entities/episode.dart';

part 'episode_model.g.dart';

@JsonSerializable()
class EpisodeModel extends Episode {
  const EpisodeModel({
    required super.id,
    required super.name,
    super.date,
    required super.baseMode,
    super.offlinePath,
  });

  factory EpisodeModel.fromJson(Map<String, dynamic> json) =>
      _$EpisodeModelFromJson(json);

  Map<String, dynamic> toJson() => _$EpisodeModelToJson(this);

  factory EpisodeModel.fromEntity(Episode entity) {
    return EpisodeModel(
      id: entity.id,
      name: entity.name,
      date: entity.date,
      baseMode: entity.baseMode,
      offlinePath: entity.offlinePath,
    );
  }
}
