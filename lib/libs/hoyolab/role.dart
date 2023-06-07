/// ===========================================================================
/// Copyright (c) 2020-2023, BoxCat. All rights reserved.
/// Date: 2023-05-27 22:47:26
/// LastEditTime: 2023-05-28 04:49:02
/// FilePath: /lib/libs/hoyolab/role.dart
/// ===========================================================================

import 'package:srcat/application.dart';

import 'dynamic_secret/main.dart';

import 'package:srcat/utils/http/dio.dart';
import 'package:srcat/config/hoyolab.dart';

class HoYoLabGameRolesLib {
  /// 通过 actionTicket 获取用户角色信息
  static Future<List<Map<String, dynamic>>?> stokenGetRoles({
    required String stoken,
    required String ltoken,
    required String uid,
    required String mid,
    required String deviceId,
  }) async {
    String api = HoYoLabConfig.authActionTicketApi
      .replaceAll("%actionType%", "game_role")
      .replaceAll("%stoken%", stoken)
      .replaceAll("%uid%", uid);

    HoYoLabDynamicSecretLib getAuthDs = HoYoLabDynamicSecretLib(
      version: HoYoLabDynamicSecretVersion.v1,
      saltType: HoYoLabDynamicSecretSaltType.k2,
      includeChars: true
    );

    Map<String, dynamic> getAuthHeaders = {
      "Cookie": "stuid=$uid;stoken=$stoken;mid=$mid",
      "DS": getAuthDs.generated(url: api, content: "stuid=$uid;stoken=$stoken;mid=$mid"),
      "User-Agent": "BoxCatTeam SRCat/${Application.packageInfo.version}.0"
    };

    String ticket = "";

    /// 等待获取 ticket
    await SCDioUtils.request(
      method: Method.GET,
      uri: Uri.parse(api),
      headers: getAuthHeaders,
      success: (response, data) {
        if (data["retcode"] != null && data["retcode"] != 0) {
          return null;
        } else if (data["data"] is Map<String, dynamic>) {
          ticket = data["data"]["ticket"].toString();
        }
      },
      fail: (code, message, failType, dioError) {
        return null;
      }
    );

    if (ticket == "") {
      return null;
    }

    String roleApi = HoYoLabConfig.actionTicketGetRoles
      .replaceAll("%actionTicket%", ticket);

    Map<String, dynamic> headers = {
      "Cookie": "ltuid=$uid;ltoken=$ltoken;",
      "User-Agent": "BoxCatTeam SRCat/${Application.packageInfo.version}.0"
    };

    List<Map<String, dynamic>> roles = [];

    await SCDioUtils.request(
      method: Method.GET,
      uri: Uri.parse(roleApi),
      headers: headers,
      success: (response, data) {
        if (data["retcode"] != null && data["retcode"] != 0) {
          return null;
        } else if (data["data"] is Map<String, dynamic>) {
          for(Map<String, dynamic> role in data["data"]["list"].cast<Map<String, dynamic>>()) {
            roles.add({
              "game_uid": int.parse(role["game_uid"].toString()),
              "nickname": role["nickname"].toString(),
              "region_name": role["region_name"].toString(),
              "level": int.parse(role["level"].toString()),
              "game_biz": role["game_biz"].toString(),
              "region": role["region"].toString(),
              "is_official": role["is_official"] as bool
            });
          }
        }
      },
      fail: (code, message, failType, dioError) {
        return null;
      }
    );

    if (roles.isEmpty) {
      return [];
    }

    return roles;
  }
}
