// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'resource_data.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

ResourceData _$ResourceDataFromJson(Map<String, dynamic> json) {
  return ResourceData(
    json['url'] as String,
    json['title'] as String,
    json['cover'] as String,
  );
}

Map<String, dynamic> _$ResourceDataToJson(ResourceData instance) => <String, dynamic>{
      'url': instance.url,
      'title': instance.title,
      'cover': instance.cover,
    };
