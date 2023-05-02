/// ===========================================================================
/// Copyright (c) 2020-2023, BoxCat. All rights reserved.
/// Date: 2023-04-28 01:54:10
/// LastEditTime: 2023-05-01 17:23:55
/// FilePath: /lib/main.dart
/// ===========================================================================

import 'dart:io';

import 'package:fluent_ui/fluent_ui.dart';
import 'package:srcat/application.dart';
import 'package:srcat/utils/file/init.dart';
import 'package:srcat/utils/settings/main.dart';
import 'package:srcat/utils/storage/sqlite.dart';
import 'package:window_manager/window_manager.dart';

import 'package:srcat/libs/router/main.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:sqflite_common_ffi/sqflite_ffi.dart';

import 'package:flutter_acrylic/flutter_acrylic.dart' as flutter_acrylic;

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await FileInitUtils.init();

  if (Platform.isWindows || Platform.isLinux) {
    sqfliteFfiInit();
    databaseFactory = databaseFactoryFfi;
  }

  SCSQLiteUtils.init();

  /* 初始设置项 */
  await SCSettingsUtils.init();

  await flutter_acrylic.Window.initialize();
  await flutter_acrylic.Window.hideWindowControls();

  await WindowManager.instance.ensureInitialized();

  // Window config
  WindowOptions windowOptions = const WindowOptions(
    size: Size(1200, 600),
    minimumSize: Size(900, 600),
    center: true,
    titleBarStyle: TitleBarStyle.hidden,
    windowButtonVisibility: false,
    backgroundColor: Colors.transparent,
    skipTaskbar: false,
    title: "SRCat"
  );
  
  windowManager.waitUntilReadyToShow(windowOptions, () async {
    await windowManager.show();
    await windowManager.setPreventClose(true);
    await windowManager.setMinimizable(true);
  });

  /* 初始化路由 */
  Application.rootNavigatorKey = GlobalKey<NavigatorState>();
  final SRCatRouter router = SRCatRouter();
  router.configureRoutes();
  Application.router = router.goRouter(Application.rootNavigatorKey);

  runApp(const ProviderScope(child: SRCatAPP()));
}

class SRCatAPP extends StatefulWidget {
  const SRCatAPP({Key? key}) : super(key: key);

  @override
  State<SRCatAPP> createState() => _SRCatAPPState();
}

class _SRCatAPPState extends State<SRCatAPP> {
  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    Widget app = FluentApp.router(
      
      debugShowCheckedModeBanner: false,

      localizationsDelegates: const [
        FluentLocalizations.delegate
      ],

      title: "SRCat",
      
      routeInformationParser: Application.router.routeInformationParser,
      routerDelegate: Application.router.routerDelegate,
      routeInformationProvider: Application.router.routeInformationProvider,

      theme: FluentThemeData(
        fontFamily: "PingFang",
        visualDensity: VisualDensity.standard,
        focusTheme: FocusThemeData(
          glowFactor: is10footScreen() ? 2.0 : 0.0
        ),
        navigationPaneTheme: const NavigationPaneThemeData(
          backgroundColor: Colors.transparent
        )
      ),
    );

    return app;
  }
}
