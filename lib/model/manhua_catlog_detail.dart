import 'package:json_annotation/json_annotation.dart';

part 'manhua_catlog_detail.g.dart';

@JsonSerializable()
class ManhuaCatlogDetail extends Object {
  @JsonKey(name: 'gengxin')
  String gengxin;

  @JsonKey(name: 'author')
  String author;

  @JsonKey(name: 'leixing')
  String leixing;

  @JsonKey(name: 'gengxinTime')
  String gengxinTime;

  @JsonKey(name: 'content')
  String content;

  @JsonKey(name: 'catlogs')
  List<Catlogs> catlogs;

  ManhuaCatlogDetail(
    this.gengxin,
    this.author,
    this.leixing,
    this.gengxinTime,
    this.content,
    this.catlogs,
  );

  factory ManhuaCatlogDetail.fromJson(Map<String, dynamic> srcJson) => _$ManhuaCatlogDetailFromJson(srcJson);

  Map<String, dynamic> toJson() => _$ManhuaCatlogDetailToJson(this);
}

@JsonSerializable()
class Catlogs extends Object {
  @JsonKey(name: 'url')
  String url;

  @JsonKey(name: 'text')
  String text;

  Catlogs(
    this.url,
    this.text,
  );

  factory Catlogs.fromJson(Map<String, dynamic> srcJson) => _$CatlogsFromJson(srcJson);

  Map<String, dynamic> toJson() => _$CatlogsToJson(this);
}
