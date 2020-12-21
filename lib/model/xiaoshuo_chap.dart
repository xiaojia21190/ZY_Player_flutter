import 'package:json_annotation/json_annotation.dart';

part 'xiaoshuo_chap.g.dart';

@JsonSerializable()
class XiaoshuoChap extends Object {
  @JsonKey(name: 'page')
  int page;

  @JsonKey(name: 'total')
  int total;

  @JsonKey(name: 'xiaoshuoList')
  List<XiaoshuoList> xiaoshuoList;

  XiaoshuoChap(
    this.page,
    this.total,
    this.xiaoshuoList,
  );

  factory XiaoshuoChap.fromJson(Map<String, dynamic> srcJson) => _$XiaoshuoChapFromJson(srcJson);

  Map<String, dynamic> toJson() => _$XiaoshuoChapToJson(this);
}

@JsonSerializable()
class XiaoshuoList extends Object {
  @JsonKey(name: 'id')
  int id;

  @JsonKey(name: 'name')
  String name;

  @JsonKey(name: 'hasContent')
  int hasContent;

  XiaoshuoList(
    this.id,
    this.name,
    this.hasContent,
  );

  factory XiaoshuoList.fromJson(Map<String, dynamic> srcJson) => _$ChpListFromJson(srcJson);

  Map<String, dynamic> toJson() => _$ChpListToJson(this);
}
