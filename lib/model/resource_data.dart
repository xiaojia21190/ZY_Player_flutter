import 'package:json_annotation/json_annotation.dart';

part 'resource_data.g.dart';

@JsonSerializable()
class ResourceData extends Object {
  @JsonKey(name: 'url')
  String url;

  @JsonKey(name: 'title')
  String title;

  @JsonKey(name: 'type')
  String type;

  ResourceData(
    this.url,
    this.title,
    this.type,
  );

  factory ResourceData.fromJson(Map<String, dynamic> srcJson) => _$ResourceDataFromJson(srcJson);

  Map<String, dynamic> toJson() => _$ResourceDataToJson(this);
}
