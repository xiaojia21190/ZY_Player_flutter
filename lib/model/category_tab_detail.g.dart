// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'category_tab_detail.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

CategoryTabDetail _$CategoryTabDetailFromJson(Map<String, dynamic> json) => CategoryTabDetail(
      json['albumId'] as int,
      json['albumName'] as String,
      json['coverImg'] as String,
      json['title'] as String?,
      json['finished'] as int,
      json['playCnt'] as int,
      json['songTotal'] as int,
      json['nowTotal'] as int,
      json['songNum'] as int,
      json['artistId'] as int,
      json['artistName'] as String,
      json['vip'] as int,
    );

Map<String, dynamic> _$CategoryTabDetailToJson(CategoryTabDetail instance) => <String, dynamic>{
      'albumId': instance.albumId,
      'albumName': instance.albumName,
      'coverImg': instance.coverImg,
      'title': instance.title,
      'finished': instance.finished,
      'playCnt': instance.playCnt,
      'songTotal': instance.songTotal,
      'nowTotal': instance.nowTotal,
      'songNum': instance.songNum,
      'artistId': instance.artistId,
      'artistName': instance.artistName,
      'vip': instance.vip,
    };
