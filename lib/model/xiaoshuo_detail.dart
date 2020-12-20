import 'package:json_annotation/json_annotation.dart';

part 'xiaoshuo_detail.g.dart';

@JsonSerializable()
class XiaoshuoDetail extends Object {
  @JsonKey(name: 'Id')
  String id;

  @JsonKey(name: 'Name')
  String name;

  @JsonKey(name: 'Author')
  String author;

  @JsonKey(name: 'Img')
  String img;

  @JsonKey(name: 'Desc')
  String desc;

  @JsonKey(name: 'BookStatus')
  String bookStatus;

  @JsonKey(name: 'LastChapterId')
  String lastChapterId;

  @JsonKey(name: 'LastChapter')
  String lastChapter;

  @JsonKey(name: 'CName')
  String cName;

  @JsonKey(name: 'UpdateTime')
  String updateTime;

  XiaoshuoDetail(
    this.id,
    this.name,
    this.author,
    this.img,
    this.desc,
    this.bookStatus,
    this.lastChapterId,
    this.lastChapter,
    this.cName,
    this.updateTime,
  );

  factory XiaoshuoDetail.fromJson(Map<String, dynamic> srcJson) => _$XiaoshuoDetailFromJson(srcJson);

  Map<String, dynamic> toJson() => _$XiaoshuoDetailToJson(this);
}
