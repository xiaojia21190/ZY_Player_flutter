// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'player_hot.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

PlayerHot _$PlayerHotFromJson(Map<String, dynamic> json) => PlayerHot(
      (json['swiper'] as List<dynamic>)
          .map((e) => SwiperList.fromJson(e as Map<String, dynamic>))
          .toList(),
      (json['types'] as List<dynamic>)
          .map((e) => Types.fromJson(e as Map<String, dynamic>))
          .toList(),
    );

Map<String, dynamic> _$PlayerHotToJson(PlayerHot instance) => <String, dynamic>{
      'swiper': instance.swipera,
      'types': instance.types,
    };

SwiperList _$SwiperListFromJson(Map<String, dynamic> json) => SwiperList(
      json['url'] as String,
      json['cover'] as String,
      json['title'] as String,
    );

Map<String, dynamic> _$SwiperListToJson(SwiperList instance) =>
    <String, dynamic>{
      'url': instance.url,
      'cover': instance.cover,
      'title': instance.title,
    };

Types _$TypesFromJson(Map<String, dynamic> json) => Types(
      json['type'] as String,
      (json['playlist'] as List<dynamic>)
          .map((e) => Playlist.fromJson(e as Map<String, dynamic>))
          .toList(),
    );

Map<String, dynamic> _$TypesToJson(Types instance) => <String, dynamic>{
      'type': instance.type,
      'playlist': instance.playlist,
    };

Playlist _$PlaylistFromJson(Map<String, dynamic> json) => Playlist(
      json['cover'] as String,
      json['url'] as String,
      json['bofang'] as String,
      json['qingxi'] as String,
      json['title'] as String,
      json['pingfen'] as String,
    );

Map<String, dynamic> _$PlaylistToJson(Playlist instance) => <String, dynamic>{
      'cover': instance.cover,
      'url': instance.url,
      'bofang': instance.bofang,
      'qingxi': instance.qingxi,
      'title': instance.title,
      'pingfen': instance.pingfen,
    };
