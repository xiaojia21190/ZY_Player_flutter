// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'ting_shu_search.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

TingShuSearch _$TingShuSearchFromJson(Map<String, dynamic> json) {
  return TingShuSearch(
    json['url'] as String,
    json['cover'] as String,
    json['title'] as String,
    json['author'] as String,
    json['state'] as String,
  );
}

Map<String, dynamic> _$TingShuSearchToJson(TingShuSearch instance) =>
    <String, dynamic>{
      'url': instance.url,
      'cover': instance.cover,
      'title': instance.title,
      'author': instance.author,
      'state': instance.state,
    };
