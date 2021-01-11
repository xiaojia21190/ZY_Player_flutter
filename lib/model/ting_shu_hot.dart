import 'package:json_annotation/json_annotation.dart';

part 'ting_shu_hot.g.dart';

@JsonSerializable()
class TingShuHot extends Object {
  @JsonKey(name: 'rmtj')
  List<Rmtj> rmtj;

  @JsonKey(name: 'audiList')
  List<AudiList> audiList;

  TingShuHot(
    this.rmtj,
    this.audiList,
  );

  factory TingShuHot.fromJson(Map<String, dynamic> srcJson) => _$TingShuHotFromJson(srcJson);

  Map<String, dynamic> toJson() => _$TingShuHotToJson(this);
}

@JsonSerializable()
class Rmtj extends Object {
  @JsonKey(name: 'name')
  String name;

  @JsonKey(name: 'url')
  String url;

  Rmtj(
    this.name,
    this.url,
  );

  factory Rmtj.fromJson(Map<String, dynamic> srcJson) => _$RmtjFromJson(srcJson);

  Map<String, dynamic> toJson() => _$RmtjToJson(this);
}

@JsonSerializable()
class AudiList extends Object {
  @JsonKey(name: 'name')
  String name;

  @JsonKey(name: 'types')
  List<Types> types;

  AudiList(
    this.name,
    this.types,
  );

  factory AudiList.fromJson(Map<String, dynamic> srcJson) => _$AudiListFromJson(srcJson);

  Map<String, dynamic> toJson() => _$AudiListToJson(this);
}

@JsonSerializable()
class Types extends Object {
  @JsonKey(name: 'url')
  String url;

  @JsonKey(name: 'title')
  String title;

  @JsonKey(name: 'author')
  String author;

  @JsonKey(name: 'cover')
  String cover;

  Types(
    this.url,
    this.title,
    this.author,
    this.cover,
  );

  factory Types.fromJson(Map<String, dynamic> srcJson) => _$TypesFromJson(srcJson);

  Map<String, dynamic> toJson() => _$TypesToJson(this);
}
