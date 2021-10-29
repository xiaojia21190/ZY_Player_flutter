import 'dart:ui';

import 'package:ZY_Player_flutter/common/common.dart';
import 'package:ZY_Player_flutter/res/resources.dart';
import 'package:flustars/flustars.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

extension ThemeModeExtension on ThemeMode {
  String get value => <String>['System', 'Light', 'Dark'][index];
}

class ThemeProvider extends ChangeNotifier {
  static const Map<ThemeMode, String> themes = {ThemeMode.dark: 'Dark', ThemeMode.light: 'Light', ThemeMode.system: 'System'};

  void syncTheme() {
    final String theme = SpUtil.getString(Constant.theme) ?? '';
    if (theme.isNotEmpty && theme != ThemeMode.system.value) {
      notifyListeners();
    }
  }

  void setTheme(ThemeMode themeMode) {
    SpUtil.putString(Constant.theme, themeMode.value);
    notifyListeners();
  }

  ThemeMode getThemeMode() {
    final String theme = SpUtil.getString(Constant.theme) ?? '';
    switch (theme) {
      case 'Dark':
        return ThemeMode.dark;
      case 'Light':
        return ThemeMode.light;
      default:
        return ThemeMode.system;
    }
  }

  ThemeData getTheme({bool isDarkMode = false}) {
    return ThemeData(
      errorColor: isDarkMode ? Colours.dark_red : Colours.red,
      primaryColor: isDarkMode ? Colours.dark_app_main : Colours.app_main,
      colorScheme: ColorScheme.fromSwatch().copyWith(
        brightness: isDarkMode ? Brightness.dark : Brightness.light,
        secondary: isDarkMode ? Colours.dark_app_main : Colours.app_main,
      ),
      // Tab指示器颜色
      indicatorColor: isDarkMode ? Colours.dark_app_main : Colours.app_main,
      // 页面背景色
      scaffoldBackgroundColor: isDarkMode ? Colours.dark_bg_color : Colors.white,
      // 主要用于Material背景色
      canvasColor: isDarkMode ? Colours.dark_material_bg : Colors.white,
      // 文字选择色（输入框选择文字等）
      // textSelectionColor: Colours.app_main.withAlpha(70),
      // textSelectionHandleColor: Colours.app_main,
      // 稳定版：1.23 变更(https://flutter.dev/docs/release/breaking-changes/text-selection-theme)
      textSelectionTheme: TextSelectionThemeData(
        selectionColor: Colours.app_main.withAlpha(70),
        selectionHandleColor: Colours.app_main,
        cursorColor: Colours.app_main,
      ),
      textTheme: TextTheme(
        // TextField输入文字颜色
        subtitle1: isDarkMode ? TextStyles.textDarkWhite : TextStyles.text,
        // Text文字样式
        bodyText2: isDarkMode ? TextStyles.textDarkWhite : TextStyles.text,
        subtitle2: isDarkMode ? TextStyles.textDarkGray12 : TextStyles.textGray12,
      ),
      inputDecorationTheme: InputDecorationTheme(
        hintStyle: isDarkMode ? TextStyles.textHint14 : TextStyles.textDarkGray14,
      ),
      appBarTheme: AppBarTheme(
        elevation: 0.0,
        color: isDarkMode ? Colours.dark_bg_color : Colours.app_main,
        systemOverlayStyle: isDarkMode ? SystemUiOverlayStyle.light : SystemUiOverlayStyle.dark,
      ),
      dividerTheme: DividerThemeData(color: isDarkMode ? Colours.dark_line : Colours.line, space: 0.6, thickness: 0.6),
      cupertinoOverrideTheme: CupertinoThemeData(
        brightness: isDarkMode ? Brightness.dark : Brightness.light,
      ),
      visualDensity: VisualDensity.standard, // https://github.com/flutter/flutter/issues/77142
    );
  }
}
