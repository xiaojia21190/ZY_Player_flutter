class TabBarChangeIndex {
  int index;
  TabBarChangeIndex({required this.index});
}

class CurrentDownLoadVideo {
  final String videoUrl;
  final String videoName;
  final String videoCover;
  final double progress;
  final String speed;
  final int state;
  CurrentDownLoadVideo(
      {required this.videoUrl, required this.videoName, required this.speed, required this.videoCover, required this.progress, required this.state});
}

class DeviceEvent {
  final int device;
  DeviceEvent(this.device);
}

// class ChangeJujiEvent {
//   ChangeJujiEvent();
// }

class LoadXiaoShuoEvent {
  int chpId;
  String title;
  LoadXiaoShuoEvent(this.chpId, this.title);
}

class WebViewEvent {
  WebViewStateType stateType;
  String url;
  String id;
  WebViewEvent({required this.stateType, required this.url, required this.id});
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
