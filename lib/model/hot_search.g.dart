// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'hot_search.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

HotSearch _$HotSearchFromJson(Map<String, dynamic> json) {
  return HotSearch(
    json['id'] as int,
    json['reptileName'] as String,
    json['hash'] as String,
    json['url'] as String,
    json['title'] as String,
    json['tag'] as String,
    json['bigType'] as String,
    json['createDate'] as String,
  );
}

Map<String, dynamic> _$HotSearchToJson(HotSearch instance) => <String, dynamic>{
      'id': instance.id,
      'reptileName': instance.reptileName,
      'hash': instance.hash,
      'url': instance.url,
      'title': instance.title,
      'tag': instance.tag,
      'bigType': instance.bigType,
      'createDate': instance.createDate,
    };
