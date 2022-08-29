import 'package:ZY_Player_flutter/common/common.dart';
import 'package:ZY_Player_flutter/localization/app_localizations.dart';
import 'package:ZY_Player_flutter/login/widgets/my_text_field.dart';
import 'package:ZY_Player_flutter/net/dio_utils.dart';
import 'package:ZY_Player_flutter/net/http_api.dart';
import 'package:ZY_Player_flutter/provider/app_state_provider.dart';
import 'package:ZY_Player_flutter/res/resources.dart';
import 'package:ZY_Player_flutter/routes/fluro_navigator.dart';
import 'package:ZY_Player_flutter/routes/routers.dart';
import 'package:ZY_Player_flutter/util/change_notifier_manage.dart';
import 'package:ZY_Player_flutter/util/log_utils.dart';
import 'package:ZY_Player_flutter/util/provider.dart';
import 'package:ZY_Player_flutter/util/toast.dart';
import 'package:ZY_Player_flutter/util/utils.dart';
import 'package:ZY_Player_flutter/widgets/my_app_bar.dart';
import 'package:ZY_Player_flutter/widgets/my_button.dart';
import 'package:ZY_Player_flutter/widgets/my_scroll_view.dart';
import 'package:flustars_flutter3/flustars_flutter3.dart';
import 'package:flutter/material.dart';

import '../login_router.dart';

/// design/1注册登录/index.html
class LoginPage extends StatefulWidget {
  @override
  _LoginPageState createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> with ChangeNotifierMixin<LoginPage> {
  //定义一个controller
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final FocusNode _nodeText1 = FocusNode();
  final FocusNode _nodeText2 = FocusNode();
  bool _clickable = false;
  AppStateProvider? appStateProvider;

  @override
  Map<ChangeNotifier, List<VoidCallback>?>? changeNotifier() {
    final List<VoidCallback> callbacks = <VoidCallback>[_verify];
    return <ChangeNotifier, List<VoidCallback>?>{
      _nameController: callbacks,
      _passwordController: callbacks,
      _nodeText1: null,
      _nodeText2: null,
    };
  }

  @override
  void initState() {
    super.initState();
    appStateProvider = Store.value<AppStateProvider>(context);
    _nameController.text = SpUtil.getString(Constant.email)!;
  }

  void _verify() {
    final String name = _nameController.text;
    final String password = _passwordController.text;
    bool clickable = true;
    if (name.isEmpty || name.length < 11) {
      clickable = false;
    }
    if (password.isEmpty || password.length < 6) {
      clickable = false;
    }

    /// 状态不一样在刷新，避免重复不必要的setState
    if (clickable != _clickable) {
      setState(() {
        _clickable = clickable;
      });
    }
  }

  void _login() async {
    // 进行登录
    var uuid = await Utils.getUniqueId();
    appStateProvider?.setloadingState(true);
    await DioUtils.instance.requestNetwork(Method.post, HttpApi.login, params: {"username": _nameController.text, "password": _passwordController.text, "uuid": uuid}, onSuccess: (data) {
      Log.d(data["token"]);
      appStateProvider?.setloadingState(false);
      SpUtil.putString(Constant.accessToken, data["token"]);
      SpUtil.putString(Constant.email, _nameController.text);
      SpUtil.putString(Constant.orderid, data["orderid"] ?? "0");
      SpUtil.putString(Constant.jihuoDate, data["jihuoDate"]);
      SpUtil.putString(Constant.password, _passwordController.text);
      NavigatorUtils.push(context, Routes.home);
    }, onError: (_, __) {
      appStateProvider?.setloadingState(false);
      Log.d('登录失败，账号，密码不正确！');
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: const MyAppBar(
        isBack: false,
        // actionName: AppLocalizations.of(context).verificationCodeLogin,
        // onPressed: () {
        //   NavigatorUtils.push(context, LoginRouter.smsLoginPage);
        // },
      ),
      body: MyScrollView(
        keyboardConfig: Utils.getKeyboardActionsConfig(context, <FocusNode>[_nodeText1, _nodeText2]),
        padding: const EdgeInsets.only(left: 16.0, right: 16.0, top: 20.0),
        children: _buildBody,
      ),
    );
  }

  List<Widget> get _buildBody => <Widget>[
        const Text(
          "邮箱登录",
          style: TextStyles.textBold26,
        ),
        Gaps.vGap16,
        MyTextField(
          key: const Key('email'),
          focusNode: _nodeText1,
          controller: _nameController,
          keyboardType: TextInputType.emailAddress,
          maxLength: 100,
          hintText: "请输入邮箱",
        ),
        Gaps.vGap8,
        MyTextField(
          key: const Key('password'),
          keyName: 'password',
          focusNode: _nodeText2,
          isInputPwd: true,
          controller: _passwordController,
          keyboardType: TextInputType.visiblePassword,
          maxLength: 16,
          hintText: "请输入密码",
        ),
        Gaps.vGap24,
        MyButton(
          key: const Key('login'),
          minHeight: 50,
          onPressed: _clickable ? _login : () => Toast.show("请填写邮箱跟密码"),
          text: "登录",
          fontSize: 20,
        ),
        Gaps.vGap16,
        Container(
            alignment: Alignment.center,
            child: GestureDetector(
              child: Text(
                AppLocalizations.of(context)!.noAccountRegisterLink,
                key: const Key('noAccountRegister'),
                style: TextStyle(color: Theme.of(context).primaryColor),
              ),
              onTap: () => NavigatorUtils.push(context, LoginRouter.registerPage),
            )),
        Gaps.vGap16,
        const Divider(),
        Container(
          margin: const EdgeInsets.symmetric(vertical: 20),
          child: Center(
            child: Text(
              "不想注册,直接进入京东短信登陆",
              style: TextStyle(color: Theme.of(context).primaryColor, fontSize: 16),
            ),
          ),
        ),
        MyButton(
          key: const Key('loginJd'),
          minHeight: 50,
          onPressed: () => NavigatorUtils.goWebViewPage(
            context,
            "京东短信登陆",
            "https://bean.m.jd.com/bean/signIndex.action",
          ),
          text: "京东短信登陆",
          fontSize: 20,
        ),
      ];
}
