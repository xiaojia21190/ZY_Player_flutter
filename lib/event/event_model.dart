class TabBarChangeIndex {
  int index;
  TabBarChangeIndex({this.index});
}

class DeviceEvent {
  String devicesId;
  String devicesName;
  DeviceEvent(this.devicesId, this.devicesName);
}

class ChangeJujiEvent {
  ChangeJujiEvent();
}

class LoadXiaoShuoEvent {
  int chpId;
  String title;
  LoadXiaoShuoEvent(this.chpId, this.title);
}

class WebViewEvent {
  WebViewStateType stateType;
  String url;
  String id;
  WebViewEvent({this.stateType, this.url, this.id});
}

enum WebViewStateType {
  /// 清除
  clear,

  /// 刷新
  reload,

  /// 隐藏
  hide,

  /// 显示
  show,

  /// 刷新加载页面
  reloadUrl,

  /// 打开下来菜单
  openRightColumn,

  /// 刷新页面大小
  resizeHome,

  resizeOtherHome,
}
