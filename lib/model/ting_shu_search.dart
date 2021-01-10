import 'package:json_annotation/json_annotation.dart';

part 'ting_shu_search.g.dart';

@JsonSerializable()
class TingShuSearch extends Object {
  @JsonKey(name: 'url')
  String url;

  @JsonKey(name: 'cover')
  String cover;

  @JsonKey(name: 'title')
  String title;

  @JsonKey(name: 'author')
  String author;

  @JsonKey(name: 'state')
  String state;

  TingShuSearch(
    this.url,
    this.cover,
    this.title,
    this.author,
    this.state,
  );

  factory TingShuSearch.fromJson(Map<String, dynamic> srcJson) => _$TingShuSearchFromJson(srcJson);

  Map<String, dynamic> toJson() => _$TingShuSearchToJson(this);
}
