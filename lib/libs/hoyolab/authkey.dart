/// ===========================================================================
/// Copyright (c) 2020-2023, BoxCat. All rights reserved.
/// Date: 2023-05-28 00:57:04
/// LastEditTime: 2023-05-29 19:40:27
/// FilePath: /lib/libs/hoyolab/authkey.dart
/// ===========================================================================

import 'dynamic_secret/main.dart';

import 'package:srcat/utils/http/dio.dart';
import 'package:srcat/config/hoyolab.dart';

class HoYoLabAuthKeyLib {
  /// 获取用于刷新跃迁记录的 authKey
  static Future<Map<String, String>?> generateAuthKey({
    required String stoken,
    required String mid,
    required String uid,
    required String deviceId,
    required int gameUid,
  }) async {
    String authApi = HoYoLabConfig.generateAuthKey;

    HoYoLabDynamicSecretLib ds = HoYoLabDynamicSecretLib(
      version: HoYoLabDynamicSecretVersion.v1,
      saltType: HoYoLabDynamicSecretSaltType.lk2,
      includeChars: true
    );

    Map<String, dynamic> body = {
      "auth_appid": "webview_gacha",
      "game_biz": "hkrpg_cn",
      "game_uid": gameUid,
      "region": "prod_gf_cn",
    };

    Map<String, dynamic> headers = {
      "Cookie": "mid=$mid;stoken=$stoken;stuid=$uid;",
      "DS": ds.generated(url: authApi),
      "Referer": HoYoLabConfig.appReferer,
      "Content-Type": "application/json; charset=utf-8"
    };

    headers.addAll(HoYoLabConfig.xrpcHeaders(deviceId));

    String signType = "";
    String version = "";
    String key = "";

    await SCDioUtils.request(
      method: Method.POST,
      uri: Uri.parse(authApi),
      headers: headers,
      params: body,
      success: (response, data) {
        print(data);
        if (data["retcode"] != null && data["retcode"] != 0) {
          return null;
        } else if (data["data"] is Map<String, dynamic>) {
          signType = data["data"]["sign_type"].toString();
          version = data["data"]["authkey_ver"].toString();
          key = data["data"]["authkey"].toString();
        }
      },
      fail: (code, message, failType, dioError) {
        return null;
      }
    );

    if (signType.isEmpty || version.isEmpty || key.isEmpty) {
      return null;
    }

    return {
      "sign_type": signType,
      "authkey_ver": version,
      "authkey": key
    };
  }
}
