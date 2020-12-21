// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'xiaoshuo_chap.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

XiaoshuoChap _$XiaoshuoChapFromJson(Map<String, dynamic> json) {
  return XiaoshuoChap(
    json['page'] as int,
    json['total'] as int,
    (json['xiaoshuoList'] as List)
        ?.map((e) => e == null ? null : XiaoshuoList.fromJson(e as Map<String, dynamic>))
        ?.toList(),
  );
}

Map<String, dynamic> _$XiaoshuoChapToJson(XiaoshuoChap instance) => <String, dynamic>{
      'page': instance.page,
      'total': instance.total,
      'list': instance.xiaoshuoList,
    };

XiaoshuoList _$ChpListFromJson(Map<String, dynamic> json) {
  return XiaoshuoList(
    json['id'] as int,
    json['name'] as String,
    json['hasContent'] as int,
  );
}

Map<String, dynamic> _$ChpListToJson(XiaoshuoList instance) => <String, dynamic>{
      'id': instance.id,
      'name': instance.name,
      'hasContent': instance.hasContent,
    };
