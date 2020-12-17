import 'package:json_annotation/json_annotation.dart';

part 'player_hot.g.dart';

@JsonSerializable()
class PlayerHot extends Object {
  @JsonKey(name: 'swiper')
  List<SwiperList> swipera;

  @JsonKey(name: 'types')
  List<Types> types;

  PlayerHot(
    this.swipera,
    this.types,
  );

  factory PlayerHot.fromJson(Map<String, dynamic> srcJson) => _$PlayerHotFromJson(srcJson);

  Map<String, dynamic> toJson() => _$PlayerHotToJson(this);
}

@JsonSerializable()
class SwiperList extends Object {
  @JsonKey(name: 'url')
  String url;

  @JsonKey(name: 'cover')
  String cover;

  @JsonKey(name: 'title')
  String title;

  SwiperList(
    this.url,
    this.cover,
    this.title,
  );

  factory SwiperList.fromJson(Map<String, dynamic> srcJson) => _$SwiperFromJson(srcJson);

  Map<String, dynamic> toJson() => _$SwiperToJson(this);
}

@JsonSerializable()
class Types extends Object {
  @JsonKey(name: 'type')
  String type;

  @JsonKey(name: 'playlist')
  List<Playlist> playlist;

  Types(
    this.type,
    this.playlist,
  );

  factory Types.fromJson(Map<String, dynamic> srcJson) => _$TypesFromJson(srcJson);

  Map<String, dynamic> toJson() => _$TypesToJson(this);
}

@JsonSerializable()
class Playlist extends Object {
  @JsonKey(name: 'cover')
  String cover;

  @JsonKey(name: 'url')
  String url;

  @JsonKey(name: 'bofang')
  String bofang;

  @JsonKey(name: 'qingxi')
  String qingxi;

  @JsonKey(name: 'title')
  String title;

  @JsonKey(name: 'pingfen')
  String pingfen;

  Playlist(
    this.cover,
    this.url,
    this.bofang,
    this.qingxi,
    this.title,
    this.pingfen,
  );

  factory Playlist.fromJson(Map<String, dynamic> srcJson) => _$PlaylistFromJson(srcJson);

  Map<String, dynamic> toJson() => _$PlaylistToJson(this);
}
