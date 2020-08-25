import 'package:json_annotation/json_annotation.dart';

part 'xiaoshuo_catlog.g.dart';

@JsonSerializable()
class XiaoshuoCatlog extends Object {
  @JsonKey(name: 'url')
  String url;

  @JsonKey(name: 'title')
  String title;

  XiaoshuoCatlog(
    this.url,
    this.title,
  );

  factory XiaoshuoCatlog.fromJson(Map<String, dynamic> srcJson) => _$XiaoshuoCatlogFromJson(srcJson);

  Map<String, dynamic> toJson() => _$XiaoshuoCatlogToJson(this);
}
