import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import 'package:flutter/services.dart';
import 'package:ZY_Player_flutter/res/resources.dart';
import 'package:ZY_Player_flutter/util/theme_utils.dart';

/// 搜索页的AppBar
class MySearchBar extends StatefulWidget implements PreferredSizeWidget {
  const MySearchBar(
      {Key? key,
      this.hintText = '',
      this.backImg = 'assets/images/ic_back_black.png',
      this.onPressed,
      this.isBack = false,
      required this.focus})
      : super(key: key);
  final String backImg;
  final String hintText;
  final bool isBack;
  final FocusNode focus;
  final Function(String)? onPressed;

  @override
  _SearchBarState createState() => _SearchBarState();

  @override
  Size get preferredSize => const Size.fromHeight(48.0);
}

class _SearchBarState extends State<MySearchBar> {
  final TextEditingController _controller = TextEditingController();

  @override
  void initState() {
    super.initState();
  }

  @override
  void dispose() {
    widget.focus.dispose();
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final bool isDark = ThemeUtils.isDark(context);
    final Color iconColor =
        isDark ? Colours.dark_text_gray : Colours.text_gray_c;

    Widget back = Semantics(
      label: '返回',
      child: SizedBox(
        width: 48.0,
        height: 48.0,
        child: InkWell(
          onTap: () {
            widget.focus.unfocus();
            Navigator.maybePop(context);
          },
          borderRadius: BorderRadius.circular(24.0),
          child: Padding(
            key: const Key('search_back'),
            padding: const EdgeInsets.all(12.0),
            child: Image.asset(
              widget.backImg,
              color: isDark ? Colours.dark_text : Colours.text,
            ),
          ),
        ),
      ),
    );

    Widget textField = Expanded(
      child: Container(
        height: 32.0,
        decoration: BoxDecoration(
          color: isDark ? Colours.dark_material_bg : Colours.bg_gray,
          borderRadius: BorderRadius.circular(4.0),
        ),
        child: TextField(
          key: const Key('search_text_field'),
          autofocus: true,
          controller: _controller,
          focusNode: widget.focus,
          maxLines: 1,
          textInputAction: TextInputAction.search,
          onSubmitted: (val) {
            widget.focus.unfocus();
            // 点击软键盘的动作按钮时的回调
            widget.onPressed!(val);
          },
          decoration: InputDecoration(
            contentPadding: const EdgeInsets.only(
                top: 0.0, left: -8.0, right: -16.0, bottom: 14.0),
            border: InputBorder.none,
            icon: Padding(
              padding: const EdgeInsets.only(top: 8.0, bottom: 8.0, left: 8.0),
              child: Image.asset(
                'assets/images/order_search.png',
                color: iconColor,
              ),
            ),
            hintText: widget.hintText,
            suffixIcon: GestureDetector(
              child: Semantics(
                label: '清空',
                child: Padding(
                  padding:
                      const EdgeInsets.only(left: 16.0, top: 8.0, bottom: 8.0),
                  child: Image.asset('assets/images/order_delete.png',
                      color: iconColor),
                ),
              ),
              onTap: () {
                /// https://github.com/flutter/flutter/issues/35848
                SchedulerBinding.instance.addPostFrameCallback((_) {
                  _controller.text = '';
                });
              },
            ),
          ),
        ),
      ),
    );

    Widget search = Theme(
      data: Theme.of(context).copyWith(
        buttonTheme: ButtonThemeData(
          padding: const EdgeInsets.symmetric(horizontal: 8.0),
          height: 32.0,
          minWidth: 44.0,
          materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
          // 距顶部距离为0
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(4.0),
          ),
        ),
      ),
      child: TextButton(
        style: ButtonStyle(
          backgroundColor: MaterialStateProperty.all<Color>(
              isDark ? Colours.dark_app_main : Colours.app_main),
        ),
        onPressed: () {
          widget.focus.unfocus();
          widget.onPressed!(_controller.text);
        },
        child: Text('搜索',
            style: TextStyle(
                fontSize: Dimens.font_sp14,
                color: isDark ? Colours.dark_button_text : Colors.white)),
      ),
    );

    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: isDark ? SystemUiOverlayStyle.light : SystemUiOverlayStyle.dark,
      child: Material(
        color: context.backgroundColor,
        child: SafeArea(
          child: Container(
            child: Row(
              children: <Widget>[
                widget.isBack
                    ? back
                    : Container(
                        width: 10,
                      ),
                textField,
                Gaps.hGap8,
                search,
                Gaps.hGap16,
              ],
            ),
          ),
        ),
      ),
    );
  }
}
