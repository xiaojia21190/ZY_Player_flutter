// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'ting_shu_detail.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

TingShuDetail _$TingShuDetailFromJson(Map<String, dynamic> json) {
  return TingShuDetail(
    json['url'] as String,
    json['cover'] as String,
    json['title'] as String,
    json['zhubo'] as String,
    json['author'] as String,
    json['leibie'] as String,
    json['time'] as String,
    json['state'] as String,
    json['content'] as String,
    (json['catlogs'] as List)
        ?.map((e) =>
            e == null ? null : Catlogs.fromJson(e as Map<String, dynamic>))
        ?.toList(),
  );
}

Map<String, dynamic> _$TingShuDetailToJson(TingShuDetail instance) =>
    <String, dynamic>{
      'url': instance.url,
      'cover': instance.cover,
      'title': instance.title,
      'zhubo': instance.zhubo,
      'author': instance.author,
      'leibie': instance.leibie,
      'time': instance.time,
      'state': instance.state,
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
