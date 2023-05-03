/// Pages Router
/// ===========================================================================
/// Copyright (c) 2020-2023, BoxCat. All rights reserved.
/// Date: 2023-04-28 03:54:06
/// LastEditTime: 2023-05-01 22:52:17
/// FilePath: /lib/pages/router.dart
/// ===========================================================================

import 'package:fluent_ui/fluent_ui.dart';
import 'package:srcat/libs/router/main.dart';

/// Splash
import 'splash/main.dart';

/// APP
import 'app/main.dart';
/// Home
import 'home/main.dart';
/// Warp
import 'tools/warp.dart';
/// Settings
import 'settings/main.dart';

class PagesRouter implements SRCatRouteInterface {
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
          builder: (context, state) => ToolsWarpPage(uid: state.queryParams["uid"])
        ),
        GoRoute(
          path: "/settings",
          name: "Settings",
          builder: (context, state) => const SettingsPage()
        )
      ],
    );

    return <RouteBase>[
      GoRoute(
        path: "/",
        name: "SplashRoot",
        builder: (context, state) => const SplashPage(),
      ),
      app
    ];
  }
}
