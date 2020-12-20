import 'package:json_annotation/json_annotation.dart';

part 'xiaoshuo_chap.g.dart';

@JsonSerializable()
class XiaoshuoChap extends Object {
  @JsonKey(name: 'name')
  String name;

  @JsonKey(name: 'list')
  List<ChpList> chpList;

  XiaoshuoChap(
    this.name,
    this.chpList,
  );

  factory XiaoshuoChap.fromJson(Map<String, dynamic> srcJson) => _$XiaoshuoChapFromJson(srcJson);

  Map<String, dynamic> toJson() => _$XiaoshuoChapToJson(this);
}

@JsonSerializable()
class ChpList extends Object {
  @JsonKey(name: 'id')
  int id;

  @JsonKey(name: 'name')
  String name;

  @JsonKey(name: 'hasContent')
  int hasContent;

  ChpList(
    this.id,
    this.name,
    this.hasContent,
  );

  factory ChpList.fromJson(Map<String, dynamic> srcJson) => _$ChpListFromJson(srcJson);

  Map<String, dynamic> toJson() => _$ChpListToJson(this);
}
