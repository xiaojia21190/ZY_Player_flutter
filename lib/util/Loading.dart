import 'dart:ui';

import 'package:ZY_Player_flutter/common/common.dart';
import 'package:ZY_Player_flutter/res/resources.dart';
import 'package:ZY_Player_flutter/util/screen_utils.dart';
import 'package:flutter/material.dart';

class Loading {
  static LoadingView preToast;

  static show(String msg) {
    preToast?.dismiss();
    preToast = null;
    OverlayState overlay = Constant.navigatorKey.currentState.overlay;
    OverlayEntry overlayEntry;
    overlayEntry = new OverlayEntry(builder: (context) {
      return buildToastLayout(msg);
    });

    var toastView = LoadingView();
    toastView.overlayState = overlay;
    toastView.overlayEntry = overlayEntry;

    preToast = toastView;
    toastView._show();
  }


  static hide() {
    preToast.dismiss();
  }

  static LayoutBuilder buildToastLayout(String msg) {
    return LayoutBuilder(builder: (context, constraints) {
      return IgnorePointer(
        ignoring: true,
        child: Material(
          color: Colors.white.withOpacity(0),
          child: Container(
            width: Screen.widthOt,
            height: Screen.heightOt,
            padding: const EdgeInsets.all(15),
            decoration: const BoxDecoration(color: Colors.black54),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const CircularProgressIndicator(
                  backgroundColor: Colors.white,
                ),
                Gaps.vGap8,
                Text(
                  msg ?? "正在加载中...",
                  style: TextStyle(color: Colors.white),
                )
              ],
            ),
            alignment: Alignment.center,
          ),
        ),
      );
    });
  }
}

class LoadingView {
  OverlayEntry overlayEntry;
  OverlayState overlayState;
  bool dismissed = false;

  _show() async {
    overlayState.insert(overlayEntry);
  }

  dismiss() async {
    if (dismissed) {
      return;
    }
    this.dismissed = true;
    overlayEntry?.remove();
  }
}
