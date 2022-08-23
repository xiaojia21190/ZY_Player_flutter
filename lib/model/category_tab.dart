import 'package:json_annotation/json_annotation.dart';

part 'category_tab.g.dart';

@JsonSerializable()
class CategoryTab extends Object {
  @JsonKey(name: 'type')
  String type;

  @JsonKey(name: 'url')
  String url;

  CategoryTab(
    this.type,
    this.url,
  );

  factory CategoryTab.fromJson(Map<String, dynamic> srcJson) => _$CategoryTabFromJson(srcJson);

  Map<String, dynamic> toJson() => _$CategoryTabToJson(this);
}
