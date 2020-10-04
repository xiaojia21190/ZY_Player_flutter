import 'package:ZY_Player_flutter/widgets/my_button.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:ZY_Player_flutter/res/resources.dart';
import 'package:ZY_Player_flutter/util/image_utils.dart';
import 'package:ZY_Player_flutter/util/theme_utils.dart';

typedef RefreshCallback = Future<void> Function();

/// design/9暂无状态页面/index.html#artboard3
class StateLayout extends StatelessWidget {
  const StateLayout({Key key, @required this.type, this.hintText, this.onRefresh}) : super(key: key);

  final StateType type;
  final String hintText;
  final RefreshCallback onRefresh;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.center,
      mainAxisAlignment: MainAxisAlignment.center,
      children: <Widget>[
        if (type == StateType.loading)
          const CircularProgressIndicator()
        else if (type != StateType.empty)
          Opacity(
            opacity: ThemeUtils.isDark(context) ? 0.5 : 1,
            child: type != StateType.network
                ? Container(
                    height: 120.0,
                    width: 120.0,
                    decoration: BoxDecoration(
                      image: DecorationImage(
                        image: ImageUtils.getAssetImage('state/${type.img}'),
                      ),
                    ),
                  )
                : MyButton(
                    text: "点击刷新",
                    width: 60,
                    height: 30,
                    onPressed: () {
                      onRefresh();
                    },
                  ),
          ),
        const SizedBox(
          width: double.infinity,
          height: Dimens.gap_dp16,
        ),
        Text(
          hintText ?? type.hintText,
          style: Theme.of(context).textTheme.subtitle2.copyWith(fontSize: Dimens.font_sp14),
        ),
        Gaps.vGap50,
      ],
    );
  }
}

enum StateType {
  /// 订单
  order,

  /// 商品
  goods,

  /// 无网络
  network,

  /// 消息
  message,

  /// 无提现账号
  account,

  /// 加载中
  loading,

  /// 空
  empty
}

extension StateTypeExtension on StateType {
  String get img => ['zwdd', 'zwsp', 'zwwl', 'zwxx', 'zwzh', '', ''][this.index];

  String get hintText => ['暂无订单', '暂无商品', '无网络连接', '暂无消息', '马上添加提现账号吧', '', ''][this.index];
}
