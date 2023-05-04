/// ===========================================================================
/// Copyright (c) 2020-2023, BoxCat. All rights reserved.
/// Date: 2023-04-28 01:54:10
/// LastEditTime: 2023-05-05 01:56:47
/// FilePath: /lib/main.dart
/// ===========================================================================

import 'dart:io';

import 'package:device_info_plus/device_info_plus.dart';
import 'package:fluent_ui/fluent_ui.dart';
import 'package:srcat/application.dart';
import 'package:srcat/riverpod/global/theme.dart';
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

  DeviceInfoPlugin deviceInfo = DeviceInfoPlugin();
  WindowsDeviceInfo windows = await deviceInfo.windowsInfo;
  Application.buildNumber = windows.buildNumber;
  Application.productName = windows.productName;

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

class SRCatAPP extends ConsumerWidget {
  const SRCatAPP({super.key});
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    bool notWin11 = false;
    final Map<String, dynamic> theme = ref.watch(themeRiverpod);
    ThemeMode themeMode;
    if (theme["theme"] == "auto") {
      themeMode = ThemeMode.system;
    } else if (theme["theme"] == "dark") {
      themeMode = ThemeMode.dark;
    } else {
      themeMode = ThemeMode.light;
    }

    if (Application.buildNumber < 22000) {
      notWin11 = true;
    }

    Widget app = FluentApp.router(
      
      debugShowCheckedModeBanner: false,

      localizationsDelegates: const [
        FluentLocalizations.delegate
      ],

      title: "SRCat",
      
      routeInformationParser: Application.router.routeInformationParser,
      routerDelegate: Application.router.routerDelegate,
      routeInformationProvider: Application.router.routeInformationProvider,

      themeMode: themeMode,
      darkTheme: FluentThemeData(
        fontFamily: "PingFang",
        brightness: Brightness.dark,
        visualDensity: VisualDensity.standard,
        focusTheme: FocusThemeData(
          glowFactor: is10footScreen() ? 2.0 : 0.0,
        ),
        navigationPaneTheme: NavigationPaneThemeData(
          backgroundColor: (theme["material"] == "default" || notWin11) ? null :Colors.transparent
        )
      ),
      theme: FluentThemeData(
        fontFamily: "PingFang",
        visualDensity: VisualDensity.standard,
        focusTheme: FocusThemeData(
          glowFactor: is10footScreen() ? 2.0 : 0.0
        ),
        navigationPaneTheme: NavigationPaneThemeData(
          backgroundColor: (theme["material"] == "default" || notWin11) ? null :Colors.transparent
        )
      ),
    );

    return app;
  }
}
