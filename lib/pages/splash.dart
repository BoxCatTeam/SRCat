/// ===========================================================================
/// Copyright (c) 2020-2023, BoxCat. All rights reserved.
/// Date: 2023-05-06 22:33:34
/// LastEditTime: 2023-05-27 21:02:20
/// FilePath: /lib/pages/splash.dart
/// ===========================================================================

import 'package:srcat/application.dart';
import 'package:fluent_ui/fluent_ui.dart';
import 'package:srcat/libs/hoyolab/bbs.dart';
import 'package:srcat/libs/hoyolab/db.dart';
import 'package:srcat/libs/metadata/main.dart';
import 'package:srcat/riverpod/global/user.dart';
import 'package:srcat/utils/storage/main.dart';

/// Splash 屏闪页 & 初始化页面
class SplashPage extends StatefulWidget {
  const SplashPage({Key? key}) : super(key: key);

  @override
  State<SplashPage> createState() => _SplashPageState();
}

class _SplashPageState extends State<SplashPage> {
  @override
  void initState() {
    super.initState();
  }

  void initSRCat() async {
    await Future.delayed(const Duration(seconds: 1));
    if (await SRCatStorageUtils.read("installed") != null) {
      bool metadataStatus = await checkMetadata();

      // load user - async
      _loadUsers();

      if (metadataStatus == false) {
        Application.router.go("/home");
      } else {
        Application.router.go("/download?isUpdate=true");
      }
    } else {
      Application.router.go("/setup");
    }
  }

  Future<bool> checkMetadata() async {
    bool hasUpdate = await SRCatMetadataLib.checkIndexUpdate();
    return hasUpdate;
  }

  void _loadUsers() async {
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
      users.add({
        ...user,
        "avatar": (userinfo?["avatar"] ?? "").toString(),
        "nickname": (userinfo?["nickname"] ?? "").toString(),
      });
    }
    Application.globalProviderScope.read(globalUserManagerRiverpod).userListInit(users);
    
    Application.globalProviderScope.read(globalUserManagerRiverpod).setLoadStatus(false);
  }

  @override
  Widget build(BuildContext context) {
    initSRCat();
    
    return Container(
      decoration: BoxDecoration(
        // 判断是否为暗黑模式
        color: FluentTheme.of(context).brightness.isDark
            ? const Color(0xff212121)
            : const Color(0xfffafafa),
      ),
      child: const Center(
        child: ProgressRing(
          strokeWidth: 5,
        ),
      )
    );
  }
}
