// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'episode_model.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

EpisodeModel _$EpisodeModelFromJson(Map<String, dynamic> json) => EpisodeModel(
      id: (json['id'] as num).toInt(),
      name: json['name'] as String,
      date: json['date'] as String?,
      baseMode: $enumDecode(_$BaseModeEnumMap, json['baseMode']),
      offlinePath: json['offlinePath'] as String?,
    );

Map<String, dynamic> _$EpisodeModelToJson(EpisodeModel instance) =>
    <String, dynamic>{
      'id': instance.id,
      'name': instance.name,
      'date': instance.date,
      'baseMode': _$BaseModeEnumMap[instance.baseMode]!,
      'offlinePath': instance.offlinePath,
    };

const _$BaseModeEnumMap = {
  BaseMode.auto: 'auto',
  BaseMode.comic: 'comic',
  BaseMode.webtoon: 'webtoon',
};
