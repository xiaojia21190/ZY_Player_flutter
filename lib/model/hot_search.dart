import 'package:json_annotation/json_annotation.dart';

part 'hot_search.g.dart';

@JsonSerializable()
class HotSearch extends Object {
  @JsonKey(name: 'id')
  int id;

  @JsonKey(name: 'reptileName')
  String reptileName;

  @JsonKey(name: 'hash')
  String hash;

  @JsonKey(name: 'url')
  String url;

  @JsonKey(name: 'title')
  String title;

  @JsonKey(name: 'tag')
  String tag;

  @JsonKey(name: 'bigType')
  String bigType;

  @JsonKey(name: 'createDate')
  String createDate;

  HotSearch(
    this.id,
    this.reptileName,
    this.hash,
    this.url,
    this.title,
    this.tag,
    this.bigType,
    this.createDate,
  );

  factory HotSearch.fromJson(Map<String, dynamic> srcJson) => _$HotSearchFromJson(srcJson);

  Map<String, dynamic> toJson() => _$HotSearchToJson(this);
}
