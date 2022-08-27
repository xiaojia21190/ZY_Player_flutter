// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'hot_home.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

HotHome _$HotHomeFromJson(Map<String, dynamic> json) => HotHome(
      json['zonghetitle'] as String,
      json['zongheicon'] as String,
      (json['contentList'] as List<dynamic>)
          .map((e) => ContentList.fromJson(e as Map<String, dynamic>))
          .toList(),
      json['update'] as String,
    );

Map<String, dynamic> _$HotHomeToJson(HotHome instance) => <String, dynamic>{
      'zonghetitle': instance.zonghetitle,
      'zongheicon': instance.zongheicon,
      'contentList': instance.contentList,
      'update': instance.update,
    };

ContentList _$ContentListFromJson(Map<String, dynamic> json) => ContentList(
      json['title'] as String,
      json['url'] as String,
      json['redu'] as String,
    );

Map<String, dynamic> _$ContentListToJson(ContentList instance) =>
    <String, dynamic>{
      'title': instance.title,
      'url': instance.url,
      'redu': instance.redu,
    };
