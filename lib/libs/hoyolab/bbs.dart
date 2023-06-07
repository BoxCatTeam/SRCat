/// ===========================================================================
/// Copyright (c) 2020-2023, BoxCat. All rights reserved.
/// Date: 2023-05-27 19:46:14
/// LastEditTime: 2023-05-28 04:49:33
/// FilePath: /lib/libs/hoyolab/bbs.dart
/// ===========================================================================

import 'dynamic_secret/main.dart';

import 'package:srcat/utils/http/dio.dart';
import 'package:srcat/config/hoyolab.dart';

class HoYoLabBBSLib {
  /// 获取自己的个人资料
  /// 需要使用 DS
  static Future<Map<String, dynamic>?> selfInfo({
    required String stoken,
    required String uid,
    required String mid,
    required String deviceId,
  }) async {
    String api = HoYoLabConfig.getSelfInfo;
    api = "$api&uid=$uid";

    HoYoLabDynamicSecretLib ds = HoYoLabDynamicSecretLib(
      version: HoYoLabDynamicSecretVersion.v2,
      saltType: HoYoLabDynamicSecretSaltType.k2,
      includeChars: true
    );

    Map<String, dynamic> headers = {
      "Cookie": "stuid=$uid;stoken=$stoken;mid=$mid",
      "DS": ds.generated(url: api, content: "stuid=$uid;stoken=$stoken;mid=$mid"),
      "Referer": HoYoLabConfig.bbsReferer
    };

    headers.addAll(HoYoLabConfig.xrpcHeaders(deviceId));

    Map<String, dynamic> userinfo = {};

    await SCDioUtils.request(
      method: Method.GET,
      uri: Uri.parse(api),
      headers: headers,
      success: (response, data) {
        if (data["retcode"] != null && data["retcode"] != 0) {
          return null;
        } else if (data["data"] is Map<String, dynamic>) {
          userinfo = {
            "nickname": data["data"]["user_info"]["nickname"].toString(),
            "avatar": data["data"]["user_info"]["avatar_url"].toString(),
            "is_blacklist": data["data"]["is_in_blacklist"] as bool
          };
        }
      },
      fail: (code, message, failType, dioError) {
        return null;
      }
    );

    if (userinfo.isEmpty) {
      return null;
    }

    return userinfo;
  }
}
