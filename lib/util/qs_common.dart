import 'dart:io';
import 'dart:typed_data';
import 'dart:ui' as ui;

import 'package:flutter/rendering.dart';
import 'package:flutter/widgets.dart';
import 'package:path_provider/path_provider.dart';
// import 'package:permission_handler/permission_handler.dart';

class QSCommon {
  /// 截屏图片生成图片流ByteData
  static Future<ByteData?> capturePngToByteData(GlobalKey key) async {
    try {
      RenderRepaintBoundary boundary = key.currentContext!.findRenderObject() as RenderRepaintBoundary;
      double dpr = ui.window.devicePixelRatio;
      ui.Image image = await boundary.toImage(pixelRatio: dpr);
      ByteData? byteData = await image.toByteData(format: ui.ImageByteFormat.png);
      return byteData!;
    } catch (e) {
      debugPrint(e.toString());
    }
    return null;
  }

  /// 把图片ByteData写入File，并触发微信分享
  static Future<File> writeAsImageBytes(ByteData data) async {
    ByteData sourceByteData = data;
    Uint8List sourceBytes = sourceByteData.buffer.asUint8List();
    Directory tempDir = await getTemporaryDirectory();

    String storagePath = tempDir.path;
    File file = File('$storagePath/海报截图.png');

    if (!file.existsSync()) {
      file.createSync();
    }
    file.writeAsBytesSync(sourceBytes);
    return file;
  }

  /// 图片存储权限处理
  // static Future<Null> handlePhotosPermission() async {
  //   // 判断是否有权限
  //   Map<Permission, PermissionStatus> statuses = await [
  //     // Permission.camera,
  //     // Permission.photos,
  //     Permission.storage,
  //   ].request();
  //   //statuses[Permission.camera] == PermissionStatus.denied ||
  //   //         statuses[Permission.photos] == PermissionStatus.denied ||
  //   if (statuses[Permission.storage] == PermissionStatus.denied) {
  //     // 无权限的话就显示设置页面
  //     openAppSettings();
  //     Log.d("无权限");
  //   }
  // }

  /// 保存图片到相册
  static Future saveImageToCamera(ByteData byteData) async {
    // await handlePhotosPermission();

    // Uint8List sourceBytes = byteData.buffer.asUint8List();
    // final result = await ImageGallerySaver.saveImage(sourceBytes);
    // return result;
  }
}
