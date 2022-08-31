// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'xiaoshuo_detail.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

XiaoshuoDetail _$XiaoshuoDetailFromJson(Map<String, dynamic> json) =>
    XiaoshuoDetail(
      json['Id'] as String,
      json['Name'] as String,
      json['Author'] as String,
      json['Img'] as String,
      json['Desc'] as String,
      json['BookStatus'] as String,
      json['LastChapterId'] as String,
      json['LastChapter'] as String,
      json['CName'] as String,
      json['UpdateTime'] as String,
    );

Map<String, dynamic> _$XiaoshuoDetailToJson(XiaoshuoDetail instance) =>
    <String, dynamic>{
      'Id': instance.id,
      'Name': instance.name,
      'Author': instance.author,
      'Img': instance.img,
      'Desc': instance.desc,
      'BookStatus': instance.bookStatus,
      'LastChapterId': instance.lastChapterId,
      'LastChapter': instance.lastChapter,
      'CName': instance.cName,
      'UpdateTime': instance.updateTime,
    };
