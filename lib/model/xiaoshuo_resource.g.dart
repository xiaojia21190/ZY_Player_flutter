// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'xiaoshuo_resource.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

XiaoshuoResource _$XiaoshuoReourceFromJson(Map<String, dynamic> json) {
  return XiaoshuoResource(
    json['url'] as String,
    json['title'] as String,
    json['author'] as String,
    json['cover'] as String,
    json['jianjie'] as String,
  );
}

Map<String, dynamic> _$XiaoshuoReourceToJson(XiaoshuoResource instance) => <String, dynamic>{
      'url': instance.url,
      'title': instance.title,
      'author': instance.author,
      'cover': instance.cover,
      'jianjie': instance.jianjie,
    };
