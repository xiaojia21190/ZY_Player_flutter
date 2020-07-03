class AuthEvent {
  final String code;
  AuthEvent(this.code);
}

class TabBarChangeIndex {
  int index;
  TabBarChangeIndex({this.index});
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
