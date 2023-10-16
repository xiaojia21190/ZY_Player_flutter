import 'dart:convert';

import 'package:ZY_Player_flutter/login/login_router.dart';
import 'package:ZY_Player_flutter/net/net.dart';
import 'package:ZY_Player_flutter/routes/fluro_navigator.dart';
import 'package:dio/dio.dart';
import 'package:flustars_flutter3/flustars_flutter3.dart';
import 'package:ZY_Player_flutter/common/common.dart';
import 'package:ZY_Player_flutter/util/log_utils.dart';

class AuthInterceptor extends Interceptor {
  @override
  void onRequest(RequestOptions options, RequestInterceptorHandler handler) {
    final String? accessToken = SpUtil.getString(Constant.accessToken);
    if (accessToken!.isNotEmpty) {
      options.headers['Authorization'] = '$accessToken';
    }

    return super.onRequest(options, handler);
  }
}

class TokenInterceptor extends Interceptor {
  Dio? _tokenDio;

  Future<String?> getToken() async {
    final Map<String, String> params = <String, String>{};
    params['username'] = SpUtil.getString(Constant.email)!;
    params['password'] = SpUtil.getString(Constant.password)!;

    try {
      _tokenDio ??= Dio();
      _tokenDio!.options = DioUtils.instance.dio.options;
      final Response response =
          await _tokenDio!.post(HttpApi.login, data: params);
      if (response.statusCode == ExceptionHandle.success) {
        return json.decode(response.data.toString())["data"]['token'];
      }
    } catch (e) {
      Log.e('刷新Token失败！');
    }
    return null;
  }

  @override
  Future<void> onResponse(
      Response response, ResponseInterceptorHandler handler) async {
    //401代表token过期
    if (response.statusCode == ExceptionHandle.unauthorized) {
      if (SpUtil.getString(Constant.email) == null &&
          SpUtil.getString(Constant.password) == null) {
        Log.d('-----------必须先登录------------');
        // 返回登录页面
        NavigatorUtils.push(navigatorState!.context, LoginRouter.loginPage);
      } else {
        Log.d('-----------自动刷新Token------------');
        final Dio dio = DioUtils.instance.dio;
        final String? accessToken = await getToken(); // 获取新的accessToken
        Log.e('-----------NewToken: $accessToken ------------');
        SpUtil.putString(Constant.accessToken, accessToken!);
        if (accessToken != "") {
          // 重新请求失败接口
          final RequestOptions request = response.requestOptions;
          request.headers['Authorization'] = '$accessToken';

          try {
            Log.e('----------- 重新请求接口 ------------');

            /// 避免重复执行拦截器，使用tokenDio
            final Response response = await _tokenDio!.fetch(request);
            handler.next(response);
          } on DioException catch (error) {
            handler.reject(error, true);
          } finally {}
        }
      }
    }
    return super.onResponse(response, handler);
  }
}

class LoggingInterceptor extends Interceptor {
  DateTime? _startTime;
  DateTime? _endTime;

  @override
  void onRequest(RequestOptions options, RequestInterceptorHandler handler) {
    _startTime = DateTime.now();
    Log.d('----------Start----------');
    if (options.queryParameters.isEmpty) {
      Log.d('RequestUrl: ' + options.baseUrl + options.path);
    } else {
      Log.d('RequestUrl: ' +
          options.baseUrl +
          options.path +
          '?' +
          Transformer.urlEncodeMap(options.queryParameters));
    }
    Log.d('RequestMethod: ' + options.method);
    Log.d('RequestHeaders:' + options.headers.toString());
    Log.d('RequestContentType: ${options.contentType}');
    Log.d('RequestData: ${options.data.toString()}');
    return super.onRequest(options, handler);
  }

  @override
  void onResponse(Response response, ResponseInterceptorHandler handler) {
    _endTime = DateTime.now();
    int duration = _endTime!.difference(_startTime!).inMilliseconds;
    if (response.statusCode == ExceptionHandle.success) {
      Log.d('ResponseCode: ${response.statusCode}');
    } else {
      Log.e('ResponseCode: ${response.statusCode}');
    }
    // 输出结果
    Log.json(response.data.toString());
    Log.d('----------End: $duration 毫秒----------');
    return super.onResponse(response, handler);
  }

  @override
  void onError(DioError err, ErrorInterceptorHandler handler) {
    Log.d('----------Error-----------');
    return super.onError(err, handler);
  }
}
