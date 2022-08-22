import 'package:json_annotation/json_annotation.dart';

part 'audio_loc.g.dart';


@JsonSerializable()
class AudioLoc extends Object {

  @JsonKey(name: 'url')
  String url;

  @JsonKey(name: 'title')
  String title;

  @JsonKey(name: 'cover')
  String cover;

  AudioLoc(this.url,this.title,this.cover,);

  factory AudioLoc.fromJson(Map<String, dynamic> srcJson) => _$AudioLocFromJson(srcJson);

}


