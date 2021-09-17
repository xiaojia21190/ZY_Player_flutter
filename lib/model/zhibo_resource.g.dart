// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'zhibo_resource.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

ZhiboResource _$ZhiboResourceFromJson(Map<String, dynamic> json) {
  return ZhiboResource(
    json['name'] as String,
    (json['m3uResult'] as List<dynamic>)
        .map((e) => M3uResult.fromJson(e as Map<String, dynamic>))
        .toList(),
  );
}

Map<String, dynamic> _$ZhiboResourceToJson(ZhiboResource instance) =>
    <String, dynamic>{
      'name': instance.name,
      'm3uResult': instance.m3uResult,
    };

M3uResult _$M3uResultFromJson(Map<String, dynamic> json) {
  return M3uResult(
    json['title'] as String,
    json['url'] as String,
  );
}

Map<String, dynamic> _$M3uResultToJson(M3uResult instance) => <String, dynamic>{
      'title': instance.title,
      'url': instance.url,
    };
