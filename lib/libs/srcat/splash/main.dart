/// ===========================================================================
/// Copyright (c) 2020-2023, BoxCat. All rights reserved.
/// Date: 2023-07-21 03:23:48
/// LastEditTime: 2023-07-21 03:24:55
/// FilePath: /lib/libs/srcat/splash/main.dart
/// ===========================================================================

import 'package:srcat/application.dart';
import 'package:srcat/libs/hoyolab/bbs.dart';
import 'package:srcat/libs/hoyolab/db.dart';
import 'package:srcat/libs/hoyolab/role.dart';
import 'package:srcat/riverpod/global/user.dart';

class SRCatSplashLib {
  static void loadUsers() async {
    List<Map<String, dynamic>> allUsers = await HoYoLabDatabaseLib.allUsers();
    List<Map<String, dynamic>> users = [];
    for (Map<String, dynamic> user in allUsers) {
      if (user["select"] == 1) {
        Application.globalProviderScope.read(globalUserManagerRiverpod).changeUser(user["id"].toString());
      }
      Map<String, dynamic>? userinfo = await HoYoLabBBSLib.selfInfo(
        stoken: user["stoken"].toString(),
        uid: user["uid"].toString(),
        mid: user["mid"].toString(),
        deviceId: user["id"].toString(),
      );
      Map<String, dynamic> roleList = {
        "role": []
      };
      if (userinfo != null) {
        List<Map<String, dynamic>>? roles = await HoYoLabGameRolesLib.stokenGetRoles(
          stoken: user["stoken"].toString(),
          uid: user["uid"].toString(),
          mid: user["mid"].toString(),
          deviceId: user["id"].toString(),
          ltoken: user["ltoken"].toString(),
        );
        if (roles != null && roles.isNotEmpty) {
          roleList = {
            "role": roles
          };
          if (user["select"] == 1) {
            Application.globalProviderScope.read(globalUserManagerRiverpod).changeRole(int.parse(roleList["role"][0]["game_uid"].toString()));
          }
        }
      }
      users.add({
        ...user,
        ...roleList,
        "avatar": (userinfo?["avatar"] ?? "").toString(),
        "nickname": (userinfo?["nickname"] ?? "").toString(),
      });
    }
    Application.globalProviderScope.read(globalUserManagerRiverpod).userListInit(users);
    
    Application.globalProviderScope.read(globalUserManagerRiverpod).setLoadStatus(false);
  }
}
