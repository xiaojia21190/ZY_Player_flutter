import 'package:json_annotation/json_annotation.dart';

part 'hot_home.g.dart';

@JsonSerializable()
class HotHome extends Object {
  @JsonKey(name: 'zonghetitle')
  String zonghetitle;

  @JsonKey(name: 'zongheicon')
  String zongheicon;

  @JsonKey(name: 'contentList')
  List<ContentList> contentList;

  @JsonKey(name: 'update')
  String update;

  HotHome(
    this.zonghetitle,
    this.zongheicon,
    this.contentList,
    this.update,
  );

  factory HotHome.fromJson(Map<String, dynamic> srcJson) => _$HotHomeFromJson(srcJson);

  Map<String, dynamic> toJson() => _$HotHomeToJson(this);
}

@JsonSerializable()
class ContentList extends Object {
  @JsonKey(name: 'title')
  String title;

  @JsonKey(name: 'url')
  String url;

  @JsonKey(name: 'redu')
  String redu;

  ContentList(
    this.title,
    this.url,
    this.redu,
  );

  factory ContentList.fromJson(Map<String, dynamic> srcJson) => _$ContentListFromJson(srcJson);

  Map<String, dynamic> toJson() => _$ContentListToJson(this);
}
