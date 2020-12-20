import 'package:json_annotation/json_annotation.dart';

part 'xiaoshuo_content.g.dart';

@JsonSerializable()
class XiaoshuoContent extends Object {
  @JsonKey(name: 'id')
  int id;

  @JsonKey(name: 'name')
  String name;

  @JsonKey(name: 'cid')
  int cid;

  @JsonKey(name: 'cname')
  String cname;

  @JsonKey(name: 'pid')
  int pid;

  @JsonKey(name: 'nid')
  int nid;

  @JsonKey(name: 'content')
  String content;

  @JsonKey(name: 'hasContent')
  int hasContent;

  XiaoshuoContent(
    this.id,
    this.name,
    this.cid,
    this.cname,
    this.pid,
    this.nid,
    this.content,
    this.hasContent,
  );

  factory XiaoshuoContent.fromJson(Map<String, dynamic> srcJson) => _$XiaoshuoContentFromJson(srcJson);

  Map<String, dynamic> toJson() => _$XiaoshuoContentToJson(this);
}
