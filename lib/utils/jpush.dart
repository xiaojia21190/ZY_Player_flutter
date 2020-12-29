import 'package:janalytics_fluttify/janalytics_fluttify.dart';
import 'package:jpush_flutter/jpush_flutter.dart';

class JpushUtil {
  static JPush jpush;

  static setUp() {
    jpush = new JPush();
    jpush.setup(
      appKey: "e5f443aa7c04dc808c6d022d",
      channel: "theChannel",
      production: false,
      debug: false, // 设置是否打印 debug 日志
    );
  }

  static tonzhi(String title, String content, [String subtitle]) {
    var fireDate = DateTime.fromMillisecondsSinceEpoch(DateTime.now().millisecondsSinceEpoch + 3000);
    var localNotification = LocalNotification(
      id: 234,
      title: title,
      buildId: 1,
      content: content,
      fireTime: fireDate,
      subtitle: subtitle, // 该参数只有在 iOS 有效
      badge: 5, // 该参数只有在 iOS 有效
    );
    jpush.sendLocalNotification(localNotification).then((res) {});
  }

  static tongjiSetUp() {
    JAnalytics.init(iosKey: 'e5f443aa7c04dc808c6d022d');
    JAnalytics.setDebugEnable(true);
    JAnalytics.startCrashHandler();
    JAnalytics.setReportPeriod(Duration(seconds: 60));
  }
}
