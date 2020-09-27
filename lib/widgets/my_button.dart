import 'package:flutter/material.dart';
import 'package:ZY_Player_flutter/res/resources.dart';
import 'package:ZY_Player_flutter/util/theme_utils.dart';

class MyButton extends StatelessWidget {
  const MyButton({
    Key key,
    this.text = '',
    this.fontSize = Dimens.font_sp12,
    this.height = 48,
    this.width = double.infinity,
    @required this.onPressed,
  }) : super(key: key);

  final String text;
  final double fontSize;
  final VoidCallback onPressed;
  final double height;
  final double width;

  @override
  Widget build(BuildContext context) {
    final bool isDark = ThemeUtils.isDark(context);
    return FlatButton(
      onPressed: onPressed,
      textColor: isDark ? Colours.dark_button_text : Colors.white,
      color: isDark ? Colours.dark_app_main : Colours.app_main,
      disabledTextColor: isDark ? Colours.dark_text_disabled : Colours.text_disabled,
      disabledColor: isDark ? Colours.dark_button_disabled : Colours.button_disabled,
      //shape:RoundedRectangleBorder(borderRadius: BorderRadius.circular(20.0)),
      child: Container(
        height: this.height,
        width: this.width,
        alignment: Alignment.center,
        child: Text(
          text,
          style: TextStyle(fontSize: this.fontSize),
        ),
      ),
    );
  }
}
