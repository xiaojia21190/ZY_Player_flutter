// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'ting_shu_hot.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

TingShuHot _$TingShuHotFromJson(Map<String, dynamic> json) {
  return TingShuHot(
    (json['rmtj'] as List)
        ?.map(
            (e) => e == null ? null : Rmtj.fromJson(e as Map<String, dynamic>))
        ?.toList(),
    (json['audiList'] as List)
        ?.map((e) =>
            e == null ? null : AudiList.fromJson(e as Map<String, dynamic>))
        ?.toList(),
  );
}

Map<String, dynamic> _$TingShuHotToJson(TingShuHot instance) =>
    <String, dynamic>{
      'rmtj': instance.rmtj,
      'audiList': instance.audiList,
    };

Rmtj _$RmtjFromJson(Map<String, dynamic> json) {
  return Rmtj(
    json['name'] as String,
    json['url'] as String,
  );
}

Map<String, dynamic> _$RmtjToJson(Rmtj instance) => <String, dynamic>{
      'name': instance.name,
      'url': instance.url,
    };

AudiList _$AudiListFromJson(Map<String, dynamic> json) {
  return AudiList(
    json['name'] as String,
    (json['types'] as List)
        ?.map(
            (e) => e == null ? null : Types.fromJson(e as Map<String, dynamic>))
        ?.toList(),
  );
}

Map<String, dynamic> _$AudiListToJson(AudiList instance) => <String, dynamic>{
      'name': instance.name,
      'types': instance.types,
    };

Types _$TypesFromJson(Map<String, dynamic> json) {
  return Types(
    json['url'] as String,
    json['title'] as String,
    json['author'] as String,
    json['cover'] as String,
  );
}

Map<String, dynamic> _$TypesToJson(Types instance) => <String, dynamic>{
      'url': instance.url,
      'title': instance.title,
      'author': instance.author,
      'cover': instance.cover,
    };
