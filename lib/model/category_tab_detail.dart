import 'package:json_annotation/json_annotation.dart';

part 'category_tab_detail.g.dart';

@JsonSerializable()
class CategoryTabDetail extends Object {
  @JsonKey(name: 'albumId')
  int albumId;

  @JsonKey(name: 'albumName')
  String albumName;

  @JsonKey(name: 'coverImg')
  String coverImg;

  @JsonKey(name: 'title')
  String? title;

  @JsonKey(name: 'finished')
  int finished;

  @JsonKey(name: 'playCnt')
  int playCnt;

  @JsonKey(name: 'songTotal')
  int songTotal;

  @JsonKey(name: 'nowTotal')
  int nowTotal;

  @JsonKey(name: 'songNum')
  int songNum;

  @JsonKey(name: 'artistId')
  int artistId;

  @JsonKey(name: 'artistName')
  String artistName;

  @JsonKey(name: 'vip')
  int vip;

  CategoryTabDetail(
    this.albumId,
    this.albumName,
    this.coverImg,
    this.title,
    this.finished,
    this.playCnt,
    this.songTotal,
    this.nowTotal,
    this.songNum,
    this.artistId,
    this.artistName,
    this.vip,
  );

  factory CategoryTabDetail.fromJson(Map<String, dynamic> srcJson) => _$CategoryTabDetailFromJson(srcJson);

  Map<String, dynamic> toJson() => _$CategoryTabDetailToJson(this);
}
