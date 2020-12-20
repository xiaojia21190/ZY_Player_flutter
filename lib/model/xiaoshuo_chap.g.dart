// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'xiaoshuo_chap.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

XiaoshuoChap _$XiaoshuoChapFromJson(Map<String, dynamic> json) {
  return XiaoshuoChap(
    json['name'] as String,
    (json['list'] as List)
        ?.map((e) =>
            e == null ? null : ChpList.fromJson(e as Map<String, dynamic>))
        ?.toList(),
  );
}

Map<String, dynamic> _$XiaoshuoChapToJson(XiaoshuoChap instance) =>
    <String, dynamic>{
      'name': instance.name,
      'list': instance.chpList,
    };

ChpList _$ChpListFromJson(Map<String, dynamic> json) {
  return ChpList(
    json['id'] as int,
    json['name'] as String,
    json['hasContent'] as int,
  );
}

Map<String, dynamic> _$ChpListToJson(ChpList instance) => <String, dynamic>{
      'id': instance.id,
      'name': instance.name,
      'hasContent': instance.hasContent,
    };
