/// ===========================================================================
/// Copyright (c) 2020-2023, BoxCat. All rights reserved.
/// Date: 2023-05-01 18:02:34
/// LastEditTime: 2023-05-01 18:16:30
/// FilePath: /lib/utils/http/dio.dart
/// ===========================================================================

import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:dio/dio.dart';

// ignore: constant_identifier_names
enum Method { GET, POST, PUT, DELETE, OPTIONS, HEAD, PATCH }
enum Status { networkError, responseError, unkownError, warpCacheEmpty }
enum FailType { mhu, srcat, dio }

const methodValues = {
  Method.GET: "get",
  Method.POST: "post",
  Method.PUT: "put",
  Method.OPTIONS: "options",
  Method.DELETE: "delete",
  Method.PATCH: "patch",
  Method.HEAD: "head",
};

const statusCode = {
  Status.networkError: 10001,
  Status.responseError: 10002,
  Status.unkownError: 10003,
  Status.warpCacheEmpty: 10010
};

typedef Success<T> = Function(Response response, T data);
typedef Fail = Function(int code, String message, FailType failType, DioError? dioError);

class SCDioUtils {
  static Dio? _dio;

  /// 创建并返回单例句柄
  static Dio createInstance() {
    if (_dio == null) {
      var options = BaseOptions(
        connectTimeout: const Duration(milliseconds: 15000),
        receiveTimeout: const Duration(milliseconds: 15000),
        sendTimeout: const Duration(milliseconds: 10000),
      );

      _dio = Dio(options);
    }

    return _dio!;
  }

  /// 清除单例句柄
  static clear() => _dio = null;

  /// 发起网络请求
  static Future request<T>({
    required Method method,
    required Uri uri,
    Map<String, dynamic>? headers,
    Map<String, dynamic>? params,
    required Success success,
    required Fail fail
  }) async {
    try {
      var connectivityResult = await (Connectivity().checkConnectivity());

      if (connectivityResult == ConnectivityResult.none) {
        fail(statusCode[Status.networkError]!, "网络连接失败", FailType.dio, null);
        return;
      }

      Dio dio = createInstance();
      Response response = await dio.requestUri(uri,
          data: method == Method.POST ? params : uri.queryParameters,
          options: Options(method: methodValues[method], headers: headers));
      success(response, response.data);
    }  on DioError catch (e) {
      if (e.response != null) {
         fail(e.response?.statusCode ?? statusCode[Status.responseError]!,
            e.response?.statusMessage ?? "未知错误", FailType.dio, e);
      } else {
        fail(statusCode[Status.unkownError]!, "未知错误", FailType.dio, e);
      }
    }
  }
}
