// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'hot_search.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

HotSearch _$HotSearchFromJson(Map<String, dynamic> json) {
  return HotSearch(
    json['url'] as String,
    json['title'] as String,
    json['cover'] as String,
    json['shuming'] as String,
    json['updatetime'] as String,
  );
}

Map<String, dynamic> _$HotSearchToJson(HotSearch instance) => <String, dynamic>{
      'url': instance.url,
      'title': instance.title,
      'cover': instance.cover,
      'shuming': instance.shuming,
      'updatetime': instance.updatetime,
    };
