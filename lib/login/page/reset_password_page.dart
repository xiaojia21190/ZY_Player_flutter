import 'package:ZY_Player_flutter/localization/app_localizations.dart';
import 'package:ZY_Player_flutter/login/widgets/my_text_field.dart';
import 'package:ZY_Player_flutter/res/resources.dart';
import 'package:ZY_Player_flutter/util/change_notifier_manage.dart';
import 'package:ZY_Player_flutter/util/toast.dart';
import 'package:ZY_Player_flutter/util/utils.dart';
import 'package:ZY_Player_flutter/widgets/my_app_bar.dart';
import 'package:ZY_Player_flutter/widgets/my_button.dart';
import 'package:ZY_Player_flutter/widgets/my_scroll_view.dart';
import 'package:flutter/material.dart';

/// design/1注册登录/index.html#artboard9
class ResetPasswordPage extends StatefulWidget {
  const ResetPasswordPage({Key? key}) : super(key: key);

  @override
  _ResetPasswordPageState createState() => _ResetPasswordPageState();
}

class _ResetPasswordPageState extends State<ResetPasswordPage> with ChangeNotifierMixin<ResetPasswordPage> {
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

  void _reset() {
    Toast.show(AppLocalizations.of(context)!.confirm);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: MyAppBar(
        title: AppLocalizations.of(context)!.forgotPasswordLink,
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
        AppLocalizations.of(context)!.resetLoginPassword,
        style: TextStyles.textBold26,
      ),
      Gaps.vGap16,
      MyTextField(
        focusNode: _nodeText1,
        controller: _nameController,
        maxLength: 11,
        keyboardType: TextInputType.phone,
        hintText: AppLocalizations.of(context)!.inputPhoneHint,
      ),
      Gaps.vGap8,
      MyTextField(
        focusNode: _nodeText2,
        controller: _vCodeController,
        keyboardType: TextInputType.number,
        getVCode: () {
          return Future.value(true);
        },
        maxLength: 6,
        hintText: AppLocalizations.of(context)!.inputVerificationCodeHint,
      ),
      Gaps.vGap8,
      MyTextField(
        focusNode: _nodeText3,
        isInputPwd: true,
        controller: _passwordController,
        maxLength: 16,
        keyboardType: TextInputType.visiblePassword,
        hintText: AppLocalizations.of(context)!.inputPasswordHint,
      ),
      Gaps.vGap24,
      MyButton(
        onPressed: _clickable ? _reset : () => {},
        text: AppLocalizations.of(context)!.confirm,
      )
    ];
  }
}
