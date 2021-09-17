// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'hot_xiaoshuo.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

HotXiaoshuo _$HotXiaoshuoFromJson(Map<String, dynamic> json) {
  return HotXiaoshuo(
    json['Id'] as int,
    json['Name'] as String,
    json['Author'] as String,
    json['Img'] as String,
    json['CName'] as String,
    json['Score'] as String,
  );
}

Map<String, dynamic> _$HotXiaoshuoToJson(HotXiaoshuo instance) =>
    <String, dynamic>{
      'Id': instance.id,
      'Name': instance.name,
      'Author': instance.author,
      'Img': instance.img,
      'CName': instance.cName,
      'Score': instance.score,
    };
