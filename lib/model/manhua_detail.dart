import 'package:json_annotation/json_annotation.dart';

part 'manhua_detail.g.dart';

@JsonSerializable()
class ManhuaDetail extends Object {
  @JsonKey(name: 'name')
  String name;

  @JsonKey(name: 'types')
  List<Types> types;

  ManhuaDetail(
    this.name,
    this.types,
  );

  factory ManhuaDetail.fromJson(Map<String, dynamic> srcJson) => _$ManhuaDetailFromJson(srcJson);

  Map<String, dynamic> toJson() => _$ManhuaDetailToJson(this);
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
