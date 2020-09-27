import 'package:json_annotation/json_annotation.dart';

part 'detail_reource.g.dart';

@JsonSerializable()
class DetailReource extends Object {
  @JsonKey(name: 'videoList')
  List<String> videoList;

  @JsonKey(name: 'content')
  String content;

  @JsonKey(name: 'cover')
  String cover;

  @JsonKey(name: 'title')
  String title;

  @JsonKey(name: 'pingfen')
  String pingfen;

  @JsonKey(name: 'daoyan')
  String daoyan;

  @JsonKey(name: 'zhuyan')
  String zhuyan;

  @JsonKey(name: 'leixing')
  String leixing;

  @JsonKey(name: 'diqu')
  String diqu;

  @JsonKey(name: 'yuyan')
  String yuyan;

  @JsonKey(name: 'url')
  String url;

  DetailReource(
    this.videoList,
    this.content,
    this.cover,
    this.title,
    this.pingfen,
    this.daoyan,
    this.zhuyan,
    this.leixing,
    this.diqu,
    this.yuyan,
    this.url,
  );

  factory DetailReource.fromJson(Map<String, dynamic> srcJson) => _$DetailReourceFromJson(srcJson);

  Map<String, dynamic> toJson() => _$DetailReourceToJson(this);
}
