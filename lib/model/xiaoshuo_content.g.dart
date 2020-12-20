// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'xiaoshuo_content.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

XiaoshuoContent _$XiaoshuoContentFromJson(Map<String, dynamic> json) {
  return XiaoshuoContent(
    json['id'] as int,
    json['name'] as String,
    json['cid'] as int,
    json['cname'] as String,
    json['pid'] as int,
    json['nid'] as int,
    json['content'] as String,
    json['hasContent'] as int,
  );
}

Map<String, dynamic> _$XiaoshuoContentToJson(XiaoshuoContent instance) =>
    <String, dynamic>{
      'id': instance.id,
      'name': instance.name,
      'cid': instance.cid,
      'cname': instance.cname,
      'pid': instance.pid,
      'nid': instance.nid,
      'content': instance.content,
      'hasContent': instance.hasContent,
    };
