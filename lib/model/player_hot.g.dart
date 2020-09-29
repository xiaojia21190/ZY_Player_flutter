// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'player_hot.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

PlayerHot _$PlayerHotFromJson(Map<String, dynamic> json) {
  return PlayerHot(
    json['type'] as String,
    (json['playlist'] as List)?.map((e) => e == null ? null : Playlist.fromJson(e as Map<String, dynamic>))?.toList(),
  );
}

Map<String, dynamic> _$PlayerHotToJson(PlayerHot instance) => <String, dynamic>{
      'type': instance.type,
      'playlist': instance.playlist,
    };

Playlist _$PlaylistFromJson(Map<String, dynamic> json) {
  return Playlist(
    json['url'] as String,
    json['title'] as String,
    json['cover'] as String,
    json['gengxin'] as String,
  );
}

Map<String, dynamic> _$PlaylistToJson(Playlist instance) => <String, dynamic>{
      'url': instance.url,
      'title': instance.title,
      'cover': instance.cover,
      'gengxin': instance.gengxin,
    };
