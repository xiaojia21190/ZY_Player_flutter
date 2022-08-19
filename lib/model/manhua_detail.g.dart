// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'manhua_detail.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

ManhuaDetail _$ManhuaDetailFromJson(Map<String, dynamic> json) => ManhuaDetail(
      json['name'] as String,
      (json['types'] as List<dynamic>)
          .map((e) => Types.fromJson(e as Map<String, dynamic>))
          .toList(),
    );

Map<String, dynamic> _$ManhuaDetailToJson(ManhuaDetail instance) =>
    <String, dynamic>{
      'name': instance.name,
      'types': instance.types,
    };

Types _$TypesFromJson(Map<String, dynamic> json) => Types(
      json['url'] as String,
      json['title'] as String,
      json['author'] as String,
      json['cover'] as String,
    );

Map<String, dynamic> _$TypesToJson(Types instance) => <String, dynamic>{
      'url': instance.url,
      'title': instance.title,
      'author': instance.author,
      'cover': instance.cover,
    };
