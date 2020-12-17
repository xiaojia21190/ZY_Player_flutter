// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'player_hot.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

PlayerHot _$PlayerHotFromJson(Map<String, dynamic> json) {
  return PlayerHot(
    (json['swiper'] as List)
        ?.map((e) =>
            e == null ? null : Swiper.fromJson(e as Map<String, dynamic>))
        ?.toList(),
    (json['types'] as List)
        ?.map(
            (e) => e == null ? null : Types.fromJson(e as Map<String, dynamic>))
        ?.toList(),
  );
}

Map<String, dynamic> _$PlayerHotToJson(PlayerHot instance) => <String, dynamic>{
      'swiper': instance.swiper,
      'types': instance.types,
    };

Swiper _$SwiperFromJson(Map<String, dynamic> json) {
  return Swiper(
    json['url'] as String,
    json['cover'] as String,
    json['title'] as String,
  );
}

Map<String, dynamic> _$SwiperToJson(Swiper instance) => <String, dynamic>{
      'url': instance.url,
      'cover': instance.cover,
      'title': instance.title,
    };

Types _$TypesFromJson(Map<String, dynamic> json) {
  return Types(
    json['type'] as String,
    (json['playlist'] as List)
        ?.map((e) =>
            e == null ? null : Playlist.fromJson(e as Map<String, dynamic>))
        ?.toList(),
  );
}

Map<String, dynamic> _$TypesToJson(Types instance) => <String, dynamic>{
      'type': instance.type,
      'playlist': instance.playlist,
    };

Playlist _$PlaylistFromJson(Map<String, dynamic> json) {
  return Playlist(
    json['cover'] as String,
    json['url'] as String,
    json['bofang'] as String,
    json['qingxi'] as String,
    json['title'] as String,
    json['pingfen'] as String,
  );
}

Map<String, dynamic> _$PlaylistToJson(Playlist instance) => <String, dynamic>{
      'cover': instance.cover,
      'url': instance.url,
      'bofang': instance.bofang,
      'qingxi': instance.qingxi,
      'title': instance.title,
      'pingfen': instance.pingfen,
    };
