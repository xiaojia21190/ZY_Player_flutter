import 'package:json_annotation/json_annotation.dart';

part 'player_reource.g.dart';

@JsonSerializable()
class PlayerReource extends Object {
  @JsonKey(name: 'key')
  String key;

  @JsonKey(name: 'name')
  String name;

  @JsonKey(name: 'url')
  String url;

  @JsonKey(name: 'new')
  String newData;

  @JsonKey(name: 'view')
  String view;

  @JsonKey(name: 'search')
  String search;

  @JsonKey(name: 'type')
  int type;

  @JsonKey(name: 'tags')
  List<Tags> tags;

  PlayerReource(
    this.key,
    this.name,
    this.url,
    this.newData,
    this.view,
    this.search,
    this.type,
    this.tags,
  );

  factory PlayerReource.fromJson(Map<String, dynamic> srcJson) => _$PlayerReourceFromJson(srcJson);

  Map<String, dynamic> toJson() => _$PlayerReourceToJson(this);
}

@JsonSerializable()
class Tags extends Object {
  @JsonKey(name: 'title')
  String title;

  @JsonKey(name: 'id')
  int id;

  @JsonKey(name: 'children')
  List<dynamic> children;

  Tags(
    this.title,
    this.id,
    this.children,
  );

  factory Tags.fromJson(Map<String, dynamic> srcJson) => _$TagsFromJson(srcJson);

  Map<String, dynamic> toJson() => _$TagsToJson(this);
}
