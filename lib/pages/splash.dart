/// ===========================================================================
/// Copyright (c) 2020-2023, BoxCat. All rights reserved.
/// Date: 2023-05-06 22:33:34
/// LastEditTime: 2023-07-21 03:25:03
/// FilePath: /lib/pages/splash.dart
/// ===========================================================================

import 'package:srcat/application.dart';
import 'package:fluent_ui/fluent_ui.dart';
import 'package:srcat/libs/metadata/main.dart';
import 'package:srcat/libs/srcat/splash/main.dart';
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
    await Future.delayed(const Duration(milliseconds: 100));
    if (await SRCatStorageUtils.read("installed") != null) {
      await Future.delayed(const Duration(milliseconds: 100));
      bool metadataStatus = await checkMetadata();

      // load user - async
      SRCatSplashLib.loadUsers();

      await Future.delayed(const Duration(milliseconds: 500));

      if (metadataStatus == false) {
        Application.router.go("/home");
      } else {
        Application.router.go("/download?isUpdate=true");
      }
    } else {
      await Future.delayed(const Duration(milliseconds: 100));
      Application.router.go("/setup");
    }
  }

  Future<bool> checkMetadata() async {
    bool hasUpdate = await SRCatMetadataLib.checkIndexUpdate();
    return hasUpdate;
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
