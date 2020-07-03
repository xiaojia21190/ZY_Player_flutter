import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'package:ZY_Player_flutter/res/colors.dart';
import 'package:ZY_Player_flutter/res/styles.dart';

class ThemeDatas {
  static var commonTheme = ThemeData(
      errorColor: Colours.red,
      brightness: Brightness.light,
      primaryColor: Colours.app_main,
      accentColor: Colours.app_main,
      // Tab指示器颜色
      indicatorColor: Colours.app_main,
      // 页面背景色
      scaffoldBackgroundColor: Colors.white,
      // 主要用于Material背景色
      canvasColor: Colors.white,
      // 文字选择色（输入框复制粘贴菜单）
      textSelectionColor: Colours.app_main.withAlpha(70),
      textSelectionHandleColor: Colours.app_main,
      textTheme: TextTheme(
        // TextField输入文字颜色
        subtitle2: TextStyles.text,
        // Text文字样式
        bodyText2: TextStyles.text,
        bodyText1: TextStyles.textGray12,
      ),
      inputDecorationTheme: InputDecorationTheme(
        hintStyle: TextStyles.textDarkGray14,
      ),
      appBarTheme: AppBarTheme(
        elevation: 0.0,
        color: Colors.white,
        brightness: Brightness.light,
      ),
      dividerTheme: DividerThemeData(color: Colours.line, space: 0.6, thickness: 0.6),
      cupertinoOverrideTheme: CupertinoThemeData(
        brightness: Brightness.light,
      ));
}
