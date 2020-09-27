import 'package:json_annotation/json_annotation.dart';

part 'player_hot.g.dart';

@JsonSerializable()
class PlayerHot extends Object {
  @JsonKey(name: 'type')
  String type;

  @JsonKey(name: 'playlist')
  List<Playlist> playlist;

  PlayerHot(
    this.type,
    this.playlist,
  );

  factory PlayerHot.fromJson(Map<String, dynamic> srcJson) => _$PlayerHotFromJson(srcJson);

  Map<String, dynamic> toJson() => _$PlayerHotToJson(this);
}

@JsonSerializable()
class Playlist extends Object {
  @JsonKey(name: 'url')
  String url;

  @JsonKey(name: 'title')
  String title;

  @JsonKey(name: 'cover')
  String cover;

  Playlist(
    this.url,
    this.title,
    this.cover,
  );

  factory Playlist.fromJson(Map<String, dynamic> srcJson) => _$PlaylistFromJson(srcJson);

  Map<String, dynamic> toJson() => _$PlaylistToJson(this);
}
