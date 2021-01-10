import 'package:json_annotation/json_annotation.dart';

part 'ting_shu_detail.g.dart';

@JsonSerializable()
class TingShuDetail extends Object {
  @JsonKey(name: 'url')
  String url;

  @JsonKey(name: 'cover')
  String cover;

  @JsonKey(name: 'title')
  String title;

  @JsonKey(name: 'zhubo')
  String zhubo;

  @JsonKey(name: 'author')
  String author;

  @JsonKey(name: 'leibie')
  String leibie;

  @JsonKey(name: 'time')
  String time;

  @JsonKey(name: 'state')
  String state;

  @JsonKey(name: 'content')
  String content;

  @JsonKey(name: 'catlogs')
  List<Catlogs> catlogs;

  TingShuDetail(
    this.url,
    this.cover,
    this.title,
    this.zhubo,
    this.author,
    this.leibie,
    this.time,
    this.state,
    this.content,
    this.catlogs,
  );

  factory TingShuDetail.fromJson(Map<String, dynamic> srcJson) => _$TingShuDetailFromJson(srcJson);

  Map<String, dynamic> toJson() => _$TingShuDetailToJson(this);
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
