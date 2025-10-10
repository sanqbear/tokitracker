// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'title_detail_model.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

TitleDetailModel _$TitleDetailModelFromJson(Map<String, dynamic> json) =>
    TitleDetailModel(
      id: (json['id'] as num).toInt(),
      name: json['name'] as String,
      thumbnailUrl: json['thumbnailUrl'] as String?,
      author: json['author'] as String?,
      tags:
          (json['tags'] as List<dynamic>?)?.map((e) => e as String).toList() ??
              const [],
      release: json['release'] as String?,
      baseMode: $enumDecode(_$BaseModeEnumMap, json['baseMode']),
      episodes: (json['episodes'] as List<dynamic>?)
              ?.map((e) => EpisodeModel.fromJson(e as Map<String, dynamic>))
              .toList() ??
          const [],
      recommendCount: (json['recommendCount'] as num?)?.toInt() ?? 0,
      isBookmarked: json['isBookmarked'] as bool? ?? false,
      bookmarkLink: json['bookmarkLink'] as String?,
    );

Map<String, dynamic> _$TitleDetailModelToJson(TitleDetailModel instance) =>
    <String, dynamic>{
      'id': instance.id,
      'name': instance.name,
      'thumbnailUrl': instance.thumbnailUrl,
      'author': instance.author,
      'tags': instance.tags,
      'release': instance.release,
      'baseMode': _$BaseModeEnumMap[instance.baseMode]!,
      'recommendCount': instance.recommendCount,
      'isBookmarked': instance.isBookmarked,
      'bookmarkLink': instance.bookmarkLink,
      'episodes': instance.episodes.map((e) => e.toJson()).toList(),
    };

const _$BaseModeEnumMap = {
  BaseMode.auto: 'auto',
  BaseMode.comic: 'comic',
  BaseMode.webtoon: 'webtoon',
};
