/// ===========================================================================
/// Copyright (c) 2020-2023, BoxCat. All rights reserved.
/// Date: 2023-05-06 22:30:03
/// LastEditTime: 2023-05-17 23:35:39
/// FilePath: /lib/pages/routes.dart
/// ===========================================================================

import 'package:fluent_ui/fluent_ui.dart';
import 'package:srcat/libs/router/main.dart';

import 'splash.dart';
import 'setup.dart';
import 'download.dart';

/* ==================== App ==================== */
import 'app/main.dart';
import 'app/home/main.dart';
/* ========== Tools ========== */
import 'app/tools/warp.dart';
import 'app/tools/game/launch.dart';
import 'app/tools/game/photo.dart';
/* ========== Other ========== */
import 'app/settings.dart';

class PageRoutes implements SRCatRouteInterface {
  final _shellNavigatorKey = GlobalKey<NavigatorState>();

  @override
  List<RouteBase> initRouter() {
    ShellRoute app = ShellRoute(
      navigatorKey: _shellNavigatorKey,
      builder: (context, state, child) {
        return AppPage(
          shellContext: _shellNavigatorKey.currentContext,
          state: state,
          child: child,
        );
      },
      routes: [
        GoRoute(
          path: "/home",
          name: "Home",
          builder: (context, state) => const HomePage()
        ),
        GoRoute(
          path: "/tools/warp",
          name: "ToolsWarp",
          builder: (context, state) => ToolsWarpPage(uid: state.queryParameters["uid"])
        ),
        GoRoute(
          path: "/tools/game/launch",
          name: "ToolsGameLaunch",
          builder: (context, state) => const GameLaunchToolPage()
        ),
        GoRoute(
          path: "/tools/game/photo",
          name: "ToolsGamePhoto",
          builder: (context, state) => const GamePhotoToolPage()
        ),
        GoRoute(
          path: "/settings",
          name: "Settings",
          builder: (context, state) => const SettingsPage()
        ),
      ]
    );

    return <RouteBase>[
      GoRoute(
        path: "/",
        name: "SplashRoot",
        builder: (context, state) => const SplashPage(),
      ),
      GoRoute(
        path: "/setup",
        name: "Setup",
        builder: (context, state) => const SetupPage(),
      ),
      GoRoute(
        path: "/download",
        name: "Download",
        builder: (context, state) => DownloadPage(isUpdate: state.queryParameters["isUpdate"]),
      ),
      app
    ];
  }
}
