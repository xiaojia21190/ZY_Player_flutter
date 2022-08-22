import 'package:json_annotation/json_annotation.dart';

part 'audio_detail.g.dart';

@JsonSerializable()
class AudioDetail extends Object {
  @JsonKey(name: 'duration')
  String duration;

  @JsonKey(name: 'tpay')
  String tpay;

  @JsonKey(name: 'pay')
  String pay;

  @JsonKey(name: 'formats')
  String formats;

  @JsonKey(name: 'artist')
  String artist;

  @JsonKey(name: 'index')
  int index;

  @JsonKey(name: 'name')
  String name;

  @JsonKey(name: 'online')
  String online;

  @JsonKey(name: 'id')
  String id;

  @JsonKey(name: 'musicrid')
  String musicrid;

  AudioDetail(
    this.duration,
    this.tpay,
    this.pay,
    this.formats,
    this.artist,
    this.index,
    this.name,
    this.online,
    this.id,
    this.musicrid,
  );

  factory AudioDetail.fromJson(Map<String, dynamic> srcJson) => _$AudioDetailFromJson(srcJson);

  Map<String, dynamic> toJson() => _$AudioDetailToJson(this);
}
