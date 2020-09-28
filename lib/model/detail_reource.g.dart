// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'detail_reource.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

DetailReource _$DetailReourceFromJson(Map<String, dynamic> json) {
  return DetailReource(
    (json['videoList'] as List)?.map((e) => e as String)?.toList(),
    json['content'] as String,
    json['cover'] as String,
    json['title'] as String,
    json['pingfen'] as String,
    json['daoyan'] as String,
    json['zhuyan'] as String,
    json['leixing'] as String,
    json['diqu'] as String,
    json['yuyan'] as String,
    json['url'] as String,
  );
}

Map<String, dynamic> _$DetailReourceToJson(DetailReource instance) =>
    <String, dynamic>{
      'videoList': instance.videoList,
      'content': instance.content,
      'cover': instance.cover,
      'title': instance.title,
      'pingfen': instance.pingfen,
      'daoyan': instance.daoyan,
      'zhuyan': instance.zhuyan,
      'leixing': instance.leixing,
      'diqu': instance.diqu,
      'yuyan': instance.yuyan,
      'url': instance.url,
    };
