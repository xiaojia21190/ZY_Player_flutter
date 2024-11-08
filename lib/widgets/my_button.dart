import 'package:ZY_Player_flutter/res/colors.dart';
import 'package:ZY_Player_flutter/res/dimens.dart';
import 'package:ZY_Player_flutter/util/theme_utils.dart';
import 'package:flutter/material.dart';

/// 默认字号18，白字蓝底，高度48
class MyButton extends StatelessWidget {
  const MyButton({
    Key? key,
    this.text = '',
    this.fontSize = Dimens.font_sp16,
    this.textColor,
    this.disabledTextColor,
    this.backgroundColor,
    this.disabledBackgroundColor,
    this.minHeight = 48.0,
    this.minWidth = double.infinity,
    this.padding = const EdgeInsets.symmetric(horizontal: 16.0),
    this.radius = 5.0,
    this.side = BorderSide.none,
    required this.onPressed,
  }) : super(key: key);

  final String text;
  final double fontSize;
  final Color? textColor;
  final Color? disabledTextColor;
  final Color? backgroundColor;
  final Color? disabledBackgroundColor;
  final double? minHeight;
  final double? minWidth;
  final VoidCallback? onPressed;
  final EdgeInsetsGeometry padding;
  final double radius;
  final BorderSide side;

  @override
  Widget build(BuildContext context) {
    final bool isDark = context.isDark;
    return TextButton(
        onPressed: onPressed,
        style: ButtonStyle(
          // 文字颜色
          foregroundColor: WidgetStateProperty.resolveWith(
            (states) {
              if (states.contains(WidgetState.disabled)) {
                return disabledTextColor ?? (isDark ? Colours.dark_text_disabled : Colours.text_disabled);
              }
              return textColor ?? (isDark ? Colours.dark_button_text : Colors.white);
            },
          ),
          // 背景颜色
          backgroundColor: WidgetStateProperty.resolveWith((states) {
            if (states.contains(WidgetState.disabled)) {
              return disabledBackgroundColor ?? (isDark ? Colours.dark_button_disabled : Colours.button_disabled);
            }
            return backgroundColor ?? (isDark ? Colours.dark_app_main : Colours.app_main);
          }),
          // 水波纹
          overlayColor: WidgetStateProperty.resolveWith((states) {
            return (textColor ?? (isDark ? Colours.dark_button_text : Colors.white)).withOpacity(0.12);
          }),
          // 按钮最小大小
          minimumSize: (minWidth == null || minHeight == null) ? null : WidgetStateProperty.all<Size>(Size(minWidth!, minHeight!)),
          padding: WidgetStateProperty.all<EdgeInsetsGeometry>(padding),
          shape: WidgetStateProperty.all<OutlinedBorder>(
            RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(radius),
            ),
          ),
          side: WidgetStateProperty.all<BorderSide>(side),
        ),
        child: Text(
          text,
          style: TextStyle(fontSize: fontSize),
        ));
  }
}
