import 'package:json_annotation/json_annotation.dart';

part 'hot_xiaoshuo.g.dart';

@JsonSerializable()
class HotXiaoshuo extends Object {
  @JsonKey(name: 'Id')
  int id;

  @JsonKey(name: 'Name')
  String name;

  @JsonKey(name: 'Author')
  String author;

  @JsonKey(name: 'Img')
  String img;

  @JsonKey(name: 'CName')
  String cName;

  @JsonKey(name: 'Score')
  String score;

  HotXiaoshuo(
    this.id,
    this.name,
    this.author,
    this.img,
    this.cName,
    this.score,
  );

  factory HotXiaoshuo.fromJson(Map<String, dynamic> srcJson) => _$HotXiaoshuoFromJson(srcJson);

  Map<String, dynamic> toJson() => _$HotXiaoshuoToJson(this);
}
