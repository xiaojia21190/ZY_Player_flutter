// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'audio_detail.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

AudioDetail _$AudioDetailFromJson(Map<String, dynamic> json) => AudioDetail(
      json['duration'] as String,
      json['tpay'] as String,
      json['pay'] as String,
      json['formats'] as String,
      json['artist'] as String,
      json['index'] as int,
      json['name'] as String,
      json['online'] as String,
      json['id'] as String,
      json['musicrid'] as String,
    );

Map<String, dynamic> _$AudioDetailToJson(AudioDetail instance) =>
    <String, dynamic>{
      'duration': instance.duration,
      'tpay': instance.tpay,
      'pay': instance.pay,
      'formats': instance.formats,
      'artist': instance.artist,
      'index': instance.index,
      'name': instance.name,
      'online': instance.online,
      'id': instance.id,
      'musicrid': instance.musicrid,
    };
