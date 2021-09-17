// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'player_reource.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

PlayerReource _$PlayerReourceFromJson(Map<String, dynamic> json) {
  return PlayerReource(
    json['key'] as String,
    json['name'] as String,
    json['url'] as String,
    json['new'] as String,
    json['view'] as String,
    json['search'] as String,
    json['type'] as int,
    (json['tags'] as List<dynamic>)
        .map((e) => Tags.fromJson(e as Map<String, dynamic>))
        .toList(),
  );
}

Map<String, dynamic> _$PlayerReourceToJson(PlayerReource instance) =>
    <String, dynamic>{
      'key': instance.key,
      'name': instance.name,
      'url': instance.url,
      'new': instance.newData,
      'view': instance.view,
      'search': instance.search,
      'type': instance.type,
      'tags': instance.tags,
    };

Tags _$TagsFromJson(Map<String, dynamic> json) {
  return Tags(
    json['title'] as String,
    json['id'] as int,
    json['children'] as List<dynamic>,
  );
}

Map<String, dynamic> _$TagsToJson(Tags instance) => <String, dynamic>{
      'title': instance.title,
      'id': instance.id,
      'children': instance.children,
    };
