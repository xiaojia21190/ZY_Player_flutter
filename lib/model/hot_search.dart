import 'package:json_annotation/json_annotation.dart';

part 'hot_search.g.dart';

@JsonSerializable()
class HotSearch extends Object {
  @JsonKey(name: 'url')
  String url;

  @JsonKey(name: 'title')
  String title;

  @JsonKey(name: 'cover')
  String cover;

  @JsonKey(name: 'shuming')
  String shuming;

  @JsonKey(name: 'updatetime')
  String updatetime;

  HotSearch(
    this.url,
    this.title,
    this.cover,
    this.shuming,
    this.updatetime,
  );

  factory HotSearch.fromJson(Map<String, dynamic> srcJson) => _$HotSearchFromJson(srcJson);

  Map<String, dynamic> toJson() => _$HotSearchToJson(this);
}
