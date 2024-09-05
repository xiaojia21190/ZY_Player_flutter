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

/// design/1注册登录/index.html#artboard11
class RegisterPage extends StatefulWidget {
  const RegisterPage({Key? key}) : super(key: key);

  @override
  _RegisterPageState createState() => _RegisterPageState();
}

class _RegisterPageState extends State<RegisterPage> with ChangeNotifierMixin<RegisterPage> {
  //定义一个controller
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _vCodeController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final FocusNode _nodeText1 = FocusNode();
  final FocusNode _nodeText2 = FocusNode();
  final FocusNode _nodeText3 = FocusNode();
  bool _clickable = false;

  @override
  Map<ChangeNotifier, List<VoidCallback>?>? changeNotifier() {
    final List<VoidCallback> callbacks = <VoidCallback>[_verify];
    return <ChangeNotifier, List<VoidCallback>?>{
      _nameController: callbacks,
      _vCodeController: callbacks,
      _passwordController: callbacks,
      _nodeText1: null,
      _nodeText2: null,
      _nodeText3: null,
    };
  }

  AppStateProvider? appStateProvider;
  @override
  void initState() {
    appStateProvider = Store.value<AppStateProvider>(context);
    super.initState();
  }

  void _verify() {
    final String name = _nameController.text;
    final String vCode = _vCodeController.text;
    final String password = _passwordController.text;
    bool clickable = true;
    if (name.isEmpty || name.length < 11) {
      clickable = false;
    }
    if (vCode.isEmpty || vCode.length < 6) {
      clickable = false;
    }
    if (password.isEmpty || password.length < 6) {
      clickable = false;
    }
    if (clickable != _clickable) {
      setState(() {
        _clickable = clickable;
      });
    }
  }

  void _register() async {
    var uuid = await Utils.getUniqueId();
    appStateProvider?.setloadingState(true);
    await DioUtils.instance
        .requestNetwork(Method.post, HttpApi.register, params: {
      "username": _nameController.text,
      "code": _vCodeController.text,
      "password": _passwordController.text,
      "uuid": uuid
    }, onSuccess: (data) {
      Log.d(data["token"]);
      appStateProvider?.setloadingState(false);
      SpUtil.putString(Constant.accessToken, data["token"]);
      SpUtil.putString(Constant.email, _nameController.text);
      SpUtil.putString(Constant.orderid, "0");
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
      appBar: MyAppBar(
        title: AppLocalizations.of(context)!.register,
      ),
      body: MyScrollView(
        keyboardConfig: Utils.getKeyboardActionsConfig(context, <FocusNode>[_nodeText1, _nodeText2, _nodeText3]),
        crossAxisAlignment: CrossAxisAlignment.center,
        padding: const EdgeInsets.only(left: 16.0, right: 16.0, top: 20.0),
        children: _buildBody(),
      ),
    );
  }

  List<Widget> _buildBody() {
    return <Widget>[
      Text(
        AppLocalizations.of(context)!.openYourAccount,
        style: TextStyles.textBold26,
      ),
      Gaps.vGap16,
      MyTextField(
        key: const Key('email'),
        focusNode: _nodeText1,
        controller: _nameController,
        keyboardType: TextInputType.emailAddress,
        hintText: "请输入邮箱",
      ),
      Gaps.vGap8,
      MyTextField(
        key: const Key('vcode'),
        focusNode: _nodeText2,
        controller: _vCodeController,
        keyboardType: TextInputType.number,
        getVCode: () async {
          const String regexEmail = "^\\w+([-+.]\\w+)*@\\w+([-.]\\w+)*\\.\\w+([-.]\\w+)*\$";
          bool flag = RegExp(regexEmail).hasMatch(_nameController.text);
          if (flag) {
            Toast.show("开始发送验证码");
            //sendMailSms
            await DioUtils.instance.requestNetwork(Method.post, HttpApi.sendMailSms, params: {
              "to": _nameController.text,
            }, onSuccess: (data) {
              Log.d("发送成功");
              // SpUtil.putString(Constant.accessToken, data["token"]);
              // NavigatorUtils.push(context, Routes.home);
            }, onError: (_, msg) {
              Toast.show(msg);
            });

            /// 一般可以在这里发送真正的请求，请求成功返回true
            return true;
          } else {
            Toast.show("请输入有效邮箱!");
            return false;
          }
        },
        maxLength: 6,
        hintText: AppLocalizations.of(context)!.inputVerificationCodeHint,
      ),
      Gaps.vGap8,
      MyTextField(
        key: const Key('password'),
        keyName: 'password',
        focusNode: _nodeText3,
        isInputPwd: true,
        controller: _passwordController,
        keyboardType: TextInputType.visiblePassword,
        maxLength: 16,
        hintText: AppLocalizations.of(context)!.inputPasswordHint,
      ),
      Gaps.vGap24,
      MyButton(
        key: const Key('register'),
        minHeight: 50,
        fontSize: 20,
        onPressed: _clickable ? _register : () => Toast.show("请填写相关信息"),
        text: AppLocalizations.of(context)!.register,
      )
    ];
  }
}
