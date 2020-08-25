// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'xiaoshuo_catlog.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

XiaoshuoCatlog _$XiaoshuoCatlogFromJson(Map<String, dynamic> json) {
  return XiaoshuoCatlog(
    json['ret'] as int,
    json['resourceid'] as int,
    json['page_No'] as int,
    json['page_count'] as int,
    (json['rows'] as List)?.map((e) => e == null ? null : Rows.fromJson(e as Map<String, dynamic>))?.toList(),
  );
}

Map<String, dynamic> _$XiaoshuoCatlogToJson(XiaoshuoCatlog instance) => <String, dynamic>{
      'ret': instance.ret,
      'resourceid': instance.resourceid,
      'page_No': instance.pageNo,
      'page_count': instance.pageCount,
      'rows': instance.rows,
    };

Rows _$RowsFromJson(Map<String, dynamic> json) {
  return Rows(
    json['chargetype'] as int,
    json['contentlen'] as int,
    json['contenttype'] as int,
    json['intro'] as String,
    json['payed'] as String,
    json['price'] as int,
    json['resourceid'] as String,
    json['serialid'] as int,
    json['serialname'] as String,
  );
}

Map<String, dynamic> _$RowsToJson(Rows instance) => <String, dynamic>{
      'chargetype': instance.chargetype,
      'contentlen': instance.contentlen,
      'contenttype': instance.contenttype,
      'intro': instance.intro,
      'payed': instance.payed,
      'price': instance.price,
      'resourceid': instance.resourceid,
      'serialid': instance.serialid,
      'serialname': instance.serialname,
    };
