import 'package:json_annotation/json_annotation.dart';
import '../../domain/entities/base_mode.dart';
import '../../domain/entities/manga_title.dart';

part 'manga_title_model.g.dart';

@JsonSerializable()
class MangaTitleModel extends MangaTitle {
  const MangaTitleModel({
    required super.id,
    required super.name,
    super.thumbnailUrl,
    super.author,
    super.tags = const [],
    super.release,
    required super.baseMode,
  });

  factory MangaTitleModel.fromJson(Map<String, dynamic> json) =>
      _$MangaTitleModelFromJson(json);

  Map<String, dynamic> toJson() => _$MangaTitleModelToJson(this);

  factory MangaTitleModel.fromEntity(MangaTitle entity) {
    return MangaTitleModel(
      id: entity.id,
      name: entity.name,
      thumbnailUrl: entity.thumbnailUrl,
      author: entity.author,
      tags: entity.tags,
      release: entity.release,
      baseMode: entity.baseMode,
    );
  }
}
