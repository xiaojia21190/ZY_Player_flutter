// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'manhua_catlog_detail.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

ManhuaCatlogDetail _$ManhuaCatlogDetailFromJson(Map<String, dynamic> json) {
  return ManhuaCatlogDetail(
    json['url'] as String,
    json['cover'] as String,
    json['gengxin'] as String,
    json['author'] as String,
    json['leixing'] as String,
    json['gengxinTime'] as String,
    json['content'] as String,
    (json['catlogs'] as List)?.map((e) => e == null ? null : Catlogs.fromJson(e as Map<String, dynamic>))?.toList(),
  );
}

Map<String, dynamic> _$ManhuaCatlogDetailToJson(ManhuaCatlogDetail instance) => <String, dynamic>{
      'url': instance.url,
      'cover': instance.cover,
      'gengxin': instance.gengxin,
      'author': instance.author,
      'leixing': instance.leixing,
      'gengxinTime': instance.gengxinTime,
      'content': instance.content,
      'catlogs': instance.catlogs,
    };

Catlogs _$CatlogsFromJson(Map<String, dynamic> json) {
  return Catlogs(
    json['url'] as String,
    json['text'] as String,
  );
}

Map<String, dynamic> _$CatlogsToJson(Catlogs instance) => <String, dynamic>{
      'url': instance.url,
      'text': instance.text,
    };
