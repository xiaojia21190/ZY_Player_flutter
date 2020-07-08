// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'manhua_detail.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

ManhuaDetail _$ManhuaDetailFromJson(Map<String, dynamic> json) {
  return ManhuaDetail(
    json['url'] as String,
    json['title'] as String,
    json['author'] as String,
    json['cover'] as String,
  );
}

Map<String, dynamic> _$ManhuaDetailToJson(ManhuaDetail instance) =>
    <String, dynamic>{
      'url': instance.url,
      'title': instance.title,
      'author': instance.author,
      'cover': instance.cover,
    };
