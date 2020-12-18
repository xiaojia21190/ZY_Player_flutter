import 'package:json_annotation/json_annotation.dart';

part 'detail_reource.g.dart';

@JsonSerializable()
class DetailReource extends Object {
  @JsonKey(name: 'ziyuanName')
  String ziyuanName;

  @JsonKey(name: 'ziyuanUrl')
  List<ZiyuanUrl> ziyuanUrl;

  DetailReource(
    this.ziyuanName,
    this.ziyuanUrl,
  );

  factory DetailReource.fromJson(Map<String, dynamic> srcJson) => _$DetailReourceFromJson(srcJson);

  Map<String, dynamic> toJson() => _$DetailReourceToJson(this);
}

@JsonSerializable()
class ZiyuanUrl extends Object {
  @JsonKey(name: 'url')
  String url;

  @JsonKey(name: 'title')
  String title;

  ZiyuanUrl(
    this.url,
    this.title,
  );

  factory ZiyuanUrl.fromJson(Map<String, dynamic> srcJson) => _$ZiyuanUrlFromJson(srcJson);

  Map<String, dynamic> toJson() => _$ZiyuanUrlToJson(this);
}
