import 'package:flutter/material.dart';
import 'package:ZY_Player_flutter/res/resources.dart';
import 'package:ZY_Player_flutter/routes/fluro_navigator.dart';

/// 自定义dialog的模板
class BaseDialog extends StatelessWidget {
  const BaseDialog({Key? key, this.title, this.onPressed, this.hiddenTitle = false, required this.child}) : super(key: key);

  final String? title;
  final VoidCallback? onPressed;
  final Widget child;
  final bool hiddenTitle;

  @override
  Widget build(BuildContext context) {
    var dialogTitle = Visibility(
      visible: !hiddenTitle,
      child: Padding(
        padding: const EdgeInsets.only(bottom: 8.0),
        child: Text(
          hiddenTitle ? '' : title ?? '',
          style: TextStyles.textBold18,
        ),
      ),
    );

    var bottomButton = Row(
      children: <Widget>[
        _DialogButton(
          text: '取消',
          textColor: Colours.text_gray,
          onPressed: () => NavigatorUtils.goBack(context),
        ),
        const SizedBox(
          height: 48.0,
          width: 16,
          child: VerticalDivider(),
        ),
        _DialogButton(
          text: '确定',
          textColor: Theme.of(context).primaryColor,
          onPressed: onPressed,
        ),
      ],
    );

    var body = Material(
      borderRadius: BorderRadius.circular(8.0),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: <Widget>[
          Gaps.vGap24,
          dialogTitle,
          Flexible(child: child),
          Gaps.vGap8,
          Gaps.line,
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 8),
            child: bottomButton,
          )
        ],
      ),
    );

    return AnimatedPadding(
      padding: MediaQuery.of(context).viewInsets + const EdgeInsets.symmetric(horizontal: 40.0, vertical: 24.0),
      duration: const Duration(milliseconds: 120),
      curve: Curves.easeInCubic,
      child: MediaQuery.removeViewInsets(
        removeLeft: true,
        removeTop: true,
        removeRight: true,
        removeBottom: true,
        context: context,
        child: Center(
          child: SizedBox(
            width: 270.0,
            child: body,
          ),
        ),
      ),
    );
  }
}

class _DialogButton extends StatelessWidget {
  const _DialogButton({
    Key? key,
    required this.text,
    this.textColor,
    this.onPressed,
  }) : super(key: key);

  final String text;
  final Color? textColor;
  final VoidCallback? onPressed;

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: SizedBox(
        height: 48.0,
        child: ElevatedButton(
          style: ButtonStyle(textStyle: WidgetStateProperty.all<TextStyle>(TextStyle(color: textColor))),
          onPressed: onPressed,
          child: Text(
            text,
            style: const TextStyle(fontSize: Dimens.font_sp18),
          ),
        ),
      ),
    );
  }
}
