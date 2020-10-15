import 'package:json_annotation/json_annotation.dart';

part 'xiaoshuo_resource.g.dart';

@JsonSerializable()
class XiaoshuoResource extends Object {
  @JsonKey(name: 'url')
  String url;

  @JsonKey(name: 'title')
  String title;

  @JsonKey(name: 'author')
  String author;

  @JsonKey(name: 'cover')
  String cover;

  @JsonKey(name: 'jianjie')
  String jianjie;

  XiaoshuoResource(
    this.url,
    this.title,
    this.author,
    this.cover,
    this.jianjie,
  );

  factory XiaoshuoResource.fromJson(Map<String, dynamic> srcJson) => _$XiaoshuoReourceFromJson(srcJson);

  Map<String, dynamic> toJson() => _$XiaoshuoReourceToJson(this);
}
