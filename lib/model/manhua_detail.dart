import 'package:json_annotation/json_annotation.dart';

part 'manhua_detail.g.dart';

@JsonSerializable()
class ManhuaDetail extends Object {
  @JsonKey(name: 'url')
  String url;

  @JsonKey(name: 'title')
  String title;

  @JsonKey(name: 'author')
  String author;

  @JsonKey(name: 'cover')
  String cover;

  ManhuaDetail(
    this.url,
    this.title,
    this.author,
    this.cover,
  );

  factory ManhuaDetail.fromJson(Map<String, dynamic> srcJson) => _$ManhuaDetailFromJson(srcJson);

  Map<String, dynamic> toJson() => _$ManhuaDetailToJson(this);
}
