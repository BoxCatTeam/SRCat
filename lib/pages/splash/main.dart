/// Splash 屏闪页 & 初始化页面
/// ===========================================================================
/// Copyright (c) 2020-2023, BoxCat. All rights reserved.
/// Date: 2023-04-28 03:59:16
/// LastEditTime: 2023-04-29 01:40:33
/// FilePath: /lib/pages/splash/main.dart
/// ===========================================================================

import 'package:fluent_ui/fluent_ui.dart';
import 'package:srcat/application.dart';

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

  @override
  void dispose() {
    super.dispose();
  }

  /// SRCat Init
  void initSRCatApp() async {
    await Future.delayed(const Duration(seconds: 5));
    Application.router.go("/home");
  }

  @override
  Widget build(BuildContext context) {
    initSRCatApp();
    
    return Container(
      decoration: const BoxDecoration(
        color: Colors.white,
      ),
      child: const Center(
        child: ProgressRing(
          strokeWidth: 5,
        ),
      ),
    );
  }
}
