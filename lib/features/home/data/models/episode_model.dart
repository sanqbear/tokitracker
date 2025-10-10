import 'package:json_annotation/json_annotation.dart';
import '../../domain/entities/base_mode.dart';
import '../../domain/entities/episode.dart';

part 'episode_model.g.dart';

@JsonSerializable()
class EpisodeModel extends Episode {
  const EpisodeModel({
    required super.id,
    required super.name,
    super.date,
    super.thumbnailUrl,
    required super.baseMode,
  });

  factory EpisodeModel.fromJson(Map<String, dynamic> json) =>
      _$EpisodeModelFromJson(json);

  Map<String, dynamic> toJson() => _$EpisodeModelToJson(this);

  factory EpisodeModel.fromEntity(Episode entity) {
    return EpisodeModel(
      id: entity.id,
      name: entity.name,
      date: entity.date,
      thumbnailUrl: entity.thumbnailUrl,
      baseMode: entity.baseMode,
    );
  }
}
