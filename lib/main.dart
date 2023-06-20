/// ===========================================================================
/// Copyright (c) 2020-2023, BoxCat. All rights reserved.
/// Date: 2023-05-06 19:23:46
/// LastEditTime: 2023-06-07 02:13:23
/// FilePath: /lib/main.dart
/// ===========================================================================

import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:sentry_flutter/sentry_flutter.dart';

import 'package:srcat/application.dart';
import 'package:srcat/libs/router/main.dart';
import 'package:device_info_plus/device_info_plus.dart';
import 'package:package_info_plus/package_info_plus.dart';

import 'package:fluent_ui/fluent_ui.dart';
import 'package:system_theme/system_theme.dart';
import 'package:srcat/riverpod/global/theme.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:srcat/utils/file/init.dart';
import 'package:srcat/utils/settings.dart';
import 'package:srcat/utils/storage/main.dart';

import 'package:srcat/utils/storage/sqlite.dart';
import 'package:sqflite_common_ffi/sqflite_ffi.dart';

import 'package:window_manager/window_manager.dart';
import 'package:flutter_acrylic/flutter_acrylic.dart';

import 'package:flutter_i18n/flutter_i18n.dart';
// ignore: depend_on_referenced_packages
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_i18n/loaders/decoders/toml_decode_strategy.dart';

import 'package:srcat/components/global/base/dialog.dart';

Future<void> main(List<String> args) async {
  WidgetsFlutterBinding.ensureInitialized();

  DeviceInfoPlugin deviceInfo = DeviceInfoPlugin();
  WindowsDeviceInfo windows = await deviceInfo.windowsInfo;
  Application.buildNumber = windows.buildNumber;
  Application.productName = windows.productName;
  Application.packageInfo = await PackageInfo.fromPlatform();

  if (Platform.isWindows) {
    sqfliteFfiInit();
    databaseFactory = databaseFactoryFfi;
  }

  await SRCatStorageUtils.init();
  if (await SRCatStorageUtils.asyncRead("data_path") != null) {
    await SRCatFileInitUtils.init();
    await SRCatSQLiteUtils.init();
  }
  
  await SRCatSettingsUtils.init();

  SystemTheme.fallbackColor = const Color(0xfff6b4f8);
  await SystemTheme.accentColor.load();

  if (Platform.isWindows) {
    await Window.initialize();
    await Window.hideWindowControls();
    await WindowManager.instance.ensureInitialized();

    // Default window size
    Size size = const Size(1200, 600);
    // window position
   Offset? position;

    if (SRCatStorageUtils.read("window_size") != null) {
      if (SRCatStorageUtils.read("window_size") is List) {
        List<dynamic> windowSize = SRCatStorageUtils.read("window_size");
        size = Size(windowSize[0], windowSize[1]);
      }
    }

    if (SRCatStorageUtils.read("window_position") != null) {
      if (SRCatStorageUtils.read("window_position") is List) {
        List<dynamic> windowPosition = SRCatStorageUtils.read("window_position");
        position = Offset(windowPosition[0], windowPosition[1]);
      }
    }

    // Window config
    WindowOptions windowOptions = WindowOptions(
      size: size,
      minimumSize: const Size(1000, 300),
      center: true,
      skipTaskbar: false,
      windowButtonVisibility: false,
      titleBarStyle: TitleBarStyle.hidden,
      title: "SRCat"
    );

    await windowManager.waitUntilReadyToShow(windowOptions, () async {
      if (position != null) {
        await windowManager.setPosition(position);
      }
      await windowManager.show();
      await windowManager.setPreventClose(true);
      await windowManager.setMinimizable(true);
    });
  }

  /* 初始化路由 */
  Application.rootNavigatorKey = GlobalKey<NavigatorState>();
  final SRCatRouter router = SRCatRouter();
  router.configureRoutes();
  Application.router = router.goRouter(Application.rootNavigatorKey);

  // 如果是在开发模式下则不初始化 Sentry
  if (kDebugMode) {
    runApp(const ProviderScope(child: SRCatAPP()));
  } else {
    /* Init Sentry */
    await SentryFlutter.init(
      (options) {
        options.dsn = 'https://28b63ea28b5f4d1189ce8f7e1696d80a@o4505208485183488.ingest.sentry.io/4505208511791104';
        options.tracesSampleRate = 1.0;
      },
      appRunner: () => runApp(const ProviderScope(child: SRCatAPP()))
    );
  }
}

class SRCatAPP extends ConsumerStatefulWidget {
  const SRCatAPP({Key? key}) : super(key: key);

  @override
  ConsumerState<SRCatAPP> createState() => _SRCatAPP();
}

class _SRCatAPP extends ConsumerState<SRCatAPP> {
  @override
  void initState() {
    super.initState();
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    Application.globalProviderScope = ProviderScope.containerOf(context);
  }
  
  @override
  Widget build(BuildContext context) {
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

      /// 支持的语言列表
      supportedLocales: const [
        Locale('zh', 'CN'), // 简体中文 (中国大陆)
      ],

      localizationsDelegates: [
        FluentLocalizations.delegate,
        FlutterI18nDelegate(
          translationLoader: FileTranslationLoader(
            useCountryCode: true, // 使用国家 (地区) 代码命名
            fallbackFile: "zh-CN", // 默认语言配置
            basePath: "assets/i18n",
            decodeStrategies: [TomlDecodeStrategy()]
          )
        ),
        GlobalMaterialLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate
      ],

      routeInformationParser: Application.router.routeInformationParser,
      routerDelegate: Application.router.routerDelegate,
      routeInformationProvider: Application.router.routeInformationProvider,

      themeMode: themeMode,
      theme: FluentThemeData(
        fontFamily: "PingFang",
        accentColor: SystemTheme.accentColor.accent.toAccentColor(),
        visualDensity: VisualDensity.standard,
        focusTheme: FocusThemeData(
          glowFactor: is10footScreen(context) ? 2.0 : 0.0,
        ),
        navigationPaneTheme: NavigationPaneThemeData(
          backgroundColor: (theme["material"] == "default" || notWin11) ? null :Colors.transparent
        ),
      ),
      darkTheme: FluentThemeData(
        fontFamily: "PingFang",
        brightness: Brightness.dark,
        visualDensity: VisualDensity.standard,
        accentColor: SystemTheme.accentColor.accent.toAccentColor(),
        focusTheme: FocusThemeData(
          glowFactor: is10footScreen(context) ? 2.0 : 0.0
        ),
        navigationPaneTheme: NavigationPaneThemeData(
          backgroundColor: (theme["material"] == "default" || notWin11) ? null :Colors.transparent
        ),
      ),

      builder: (context, child) {
        Widget stack = Stack(
          children: <Widget>[
            child!,
            const Positioned(
              top: 0,
              left: 0,
              right: 0,
              bottom: 0,
              child: SRCatGlobalDialog()
            )
          ]
        );

        return Overlay(
          initialEntries: [
            OverlayEntry(
              builder: (context) => stack,
            )
          ]
        );
      }
    );

    return app;
  }
}

