// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'manga_title_model.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

MangaTitleModel _$MangaTitleModelFromJson(Map<String, dynamic> json) =>
    MangaTitleModel(
      id: (json['id'] as num).toInt(),
      name: json['name'] as String,
      thumbnailUrl: json['thumbnailUrl'] as String?,
      author: json['author'] as String?,
      tags:
          (json['tags'] as List<dynamic>?)?.map((e) => e as String).toList() ??
              const [],
      release: json['release'] as String?,
      baseMode: $enumDecode(_$BaseModeEnumMap, json['baseMode']),
    );

Map<String, dynamic> _$MangaTitleModelToJson(MangaTitleModel instance) =>
    <String, dynamic>{
      'id': instance.id,
      'name': instance.name,
      'thumbnailUrl': instance.thumbnailUrl,
      'author': instance.author,
      'tags': instance.tags,
      'release': instance.release,
      'baseMode': _$BaseModeEnumMap[instance.baseMode]!,
    };

const _$BaseModeEnumMap = {
  BaseMode.auto: 'auto',
  BaseMode.comic: 'comic',
  BaseMode.webtoon: 'webtoon',
};
