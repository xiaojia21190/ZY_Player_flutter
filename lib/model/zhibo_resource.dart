import 'package:json_annotation/json_annotation.dart';

part 'zhibo_resource.g.dart';

@JsonSerializable()
class ZhiboResource extends Object {
  @JsonKey(name: 'name')
  String name;

  @JsonKey(name: 'm3uResult')
  List<M3uResult> m3uResult;

  ZhiboResource(
    this.name,
    this.m3uResult,
  );

  factory ZhiboResource.fromJson(Map<String, dynamic> srcJson) =>
      _$ZhiboResourceFromJson(srcJson);

  Map<String, dynamic> toJson() => _$ZhiboResourceToJson(this);
}

@JsonSerializable()
class M3uResult extends Object {
  @JsonKey(name: 'title')
  String title;

  @JsonKey(name: 'url')
  String url;

  M3uResult(
    this.title,
    this.url,
  );

  factory M3uResult.fromJson(Map<String, dynamic> srcJson) =>
      _$M3uResultFromJson(srcJson);

  Map<String, dynamic> toJson() => _$M3uResultToJson(this);
}
