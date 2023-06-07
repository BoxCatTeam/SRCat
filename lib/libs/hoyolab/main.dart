/// ===========================================================================
/// Copyright (c) 2020-2023, BoxCat. All rights reserved.
/// Date: 2023-05-25 12:59:12
/// LastEditTime: 2023-05-28 04:55:30
/// FilePath: /lib/libs/hoyolab/main.dart
/// ===========================================================================

import 'package:srcat/utils/main.dart';
import 'package:srcat/utils/http/dio.dart';
import 'package:srcat/config/hoyolab.dart';
import 'package:srcat/libs/hoyolab/dynamic_secret/main.dart';

class HoYoLabLib {
  /// 通过 login_ticket 与 login_uid 获取 SToken 与 LToken
  static Future<Map<String, String>?> generatedMuiltToken({
    required String loginTicket,
    required String loginUid
  }) async {
    String url = HoYoLabConfig.authMuiltApi;
    String api = url.replaceAll("%loginTicket%", loginTicket)
      .replaceAll("%uid%", loginUid);

    String ltoken = "";
    String stoken = "";

    await SCDioUtils.request(
      method: Method.GET,
      uri: Uri.parse(api),
      headers: HoYoLabConfig.xrpcHeaders(""),
      success: (response, data) {
        if (data["retcode"] != null && data["retcode"] != 0) {
          return null;
        } else if (data["data"] is Map<String, dynamic>) {
          List<Map<String, dynamic>> list = data["data"]["list"].cast<Map<String, dynamic>>();
          for (Map<String, dynamic> item in list) {
            if (item["name"] != null && item["name"].toString().toLowerCase() == "ltoken") {
              ltoken = item["token"];
            }
            if (item["name"] != null && item["name"].toString().toLowerCase() == "stoken") {
              stoken = item["token"];
            }
          }
        }
      },
      fail: (code, message, failType, dioError) {
        return null;
      }
    );

    if (ltoken.isEmpty || stoken.isEmpty) {
      return null;
    }

    return {
      "ltoken": ltoken,
      "stoken": stoken
    };
  }

  /// 通过 uid 与 stoken 获取 v2 Stoken
  static Future<Map<String, String>?> getV2StokenBySToekn({
    required String v1Stoken,
    required String v1Uid
  }) async {
    String api = HoYoLabConfig.getV2Stoken;

    HoYoLabDynamicSecretLib ds = HoYoLabDynamicSecretLib(
      version: HoYoLabDynamicSecretVersion.v2,
      saltType: HoYoLabDynamicSecretSaltType.prod,
      includeChars: true
    );

    Map<String, dynamic> headers = {
      "Cookie": "stuid=$v1Uid;stoken=$v1Stoken",
      "DS": ds.generated(url: api, content: "stuid=$v1Uid;stoken=$v1Stoken")
    };

    String deviceId = SRCatUtils.getUUIDv5(v1Uid);

    headers.addAll(HoYoLabConfig.xrpc2Headers(deviceId));

    String v2SToken = "";
    String aid = "";
    String mid = "";

    await SCDioUtils.request(
      uri: Uri.parse(api),
      method: Method.POST,
      headers: headers,
      success: (response, data) {
        if (data["retcode"] != null && data["retcode"] != 0) {
          return null;
        } else if (data["data"] is Map<String, dynamic> &&
          data["data"]["token"] is Map<String, dynamic> &&
          data["data"]["user_info"]  is Map<String, dynamic>
        ) {
          v2SToken = data["data"]["token"]["token"].toString();
          aid = data["data"]["user_info"]["aid"].toString();
          mid = data["data"]["user_info"]["mid"].toString();
        }
      },
      fail: (code, message, failType, dioError) {
        return null;
      }
    );

    if (v2SToken.isEmpty || aid.isEmpty || mid.isEmpty) {
      return null;
    }

    return {
      "token": v2SToken,
      "aid": aid,
      "mid": mid,
      "deviceId": deviceId
    };
  }

  /// 获取 cookieToken
  static Future<String?> getCookieToken({
    required String v2Stoken,
    required String uid,
    required String mid,
    required String deviceId,
  }) async {
    String api = HoYoLabConfig.getCookieByStokenApi;

    HoYoLabDynamicSecretLib ds = HoYoLabDynamicSecretLib(
      version: HoYoLabDynamicSecretVersion.v2,
      saltType: HoYoLabDynamicSecretSaltType.prod,
      includeChars: true
    );

    Map<String, dynamic> headers = {
      "Cookie": "stuid=$uid;stoken=$v2Stoken;mid=$mid",
      "DS": ds.generated(url: api, content: "stuid=$uid;stoken=$v2Stoken;mid=$mid")
    };

    headers.addAll(HoYoLabConfig.xrpc2Headers(deviceId));

    String cookieToken = "";

    await SCDioUtils.request(
      method: Method.GET,
      uri: Uri.parse(api),
      headers: headers,
      success: (response, data) {
        if (data["retcode"] != null && data["retcode"] != 0) {
          return null;
        } else if (data["data"] is Map<String, dynamic>) {
          cookieToken = data["data"]["cookie_token"].toString();
        }
      },
      fail: (code, message, failType, dioError) {
        return null;
      }
    );

    if (cookieToken.isEmpty) {
      return null;
    }

    return cookieToken;
  }
}
