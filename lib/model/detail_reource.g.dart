// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'detail_reource.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

DetailReource _$DetailReourceFromJson(Map<String, dynamic> json) {
  return DetailReource(
    json['ziyuanName'] as String,
    (json['ziyuanUrl'] as List)
        ?.map((e) =>
            e == null ? null : ZiyuanUrl.fromJson(e as Map<String, dynamic>))
        ?.toList(),
  );
}

Map<String, dynamic> _$DetailReourceToJson(DetailReource instance) =>
    <String, dynamic>{
      'ziyuanName': instance.ziyuanName,
      'ziyuanUrl': instance.ziyuanUrl,
    };

ZiyuanUrl _$ZiyuanUrlFromJson(Map<String, dynamic> json) {
  return ZiyuanUrl(
    json['url'] as String,
    json['title'] as String,
  );
}

Map<String, dynamic> _$ZiyuanUrlToJson(ZiyuanUrl instance) => <String, dynamic>{
      'url': instance.url,
      'title': instance.title,
    };
