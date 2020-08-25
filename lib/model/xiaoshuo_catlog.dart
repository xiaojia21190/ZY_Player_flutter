import 'package:json_annotation/json_annotation.dart';

part 'xiaoshuo_catlog.g.dart';

@JsonSerializable()
class XiaoshuoCatlog extends Object {
  @JsonKey(name: 'ret')
  int ret;

  @JsonKey(name: 'resourceid')
  int resourceid;

  @JsonKey(name: 'page_No')
  int pageNo;

  @JsonKey(name: 'page_count')
  int pageCount;

  @JsonKey(name: 'rows')
  List<Rows> rows;

  XiaoshuoCatlog(
    this.ret,
    this.resourceid,
    this.pageNo,
    this.pageCount,
    this.rows,
  );

  factory XiaoshuoCatlog.fromJson(Map<String, dynamic> srcJson) => _$XiaoshuoCatlogFromJson(srcJson);

  Map<String, dynamic> toJson() => _$XiaoshuoCatlogToJson(this);
}

@JsonSerializable()
class Rows extends Object {
  @JsonKey(name: 'chargetype')
  int chargetype;

  @JsonKey(name: 'contentlen')
  int contentlen;

  @JsonKey(name: 'contenttype')
  int contenttype;

  @JsonKey(name: 'intro')
  String intro;

  @JsonKey(name: 'payed')
  String payed;

  @JsonKey(name: 'price')
  int price;

  @JsonKey(name: 'resourceid')
  String resourceid;

  @JsonKey(name: 'serialid')
  int serialid;

  @JsonKey(name: 'serialname')
  String serialname;

  Rows(
    this.chargetype,
    this.contentlen,
    this.contenttype,
    this.intro,
    this.payed,
    this.price,
    this.resourceid,
    this.serialid,
    this.serialname,
  );

  factory Rows.fromJson(Map<String, dynamic> srcJson) => _$RowsFromJson(srcJson);

  Map<String, dynamic> toJson() => _$RowsToJson(this);
}
