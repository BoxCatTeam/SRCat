/// ===========================================================================
/// Copyright (c) 2020-2023, BoxCat. All rights reserved.
/// Date: 2023-04-28 03:37:34
/// LastEditTime: 2023-04-28 18:35:32
/// FilePath: /lib/libs/router/main.dart
/// ===========================================================================

export 'interface.dart';

import 'package:fluent_ui/fluent_ui.dart';

import 'interface.dart';
import 'package:srcat/pages/router.dart';

export 'package:go_router/go_router.dart';
import 'package:go_router/go_router.dart';

class SRCatRouter {
  static String rootRoute = "/";

  /// 路由列表
  static final List<SRCatRouteInterface> _routes = [];
  /// 路由结果
  static final List<RouteBase> _routesResult = [];

  /// 路由初始化
  void configureRoutes() {
    /* 清空路由列表 */
    _routes.clear();

    /* 注册各模块的路由 */
    /* 将路由注册入口添加至待注册列表 */
    _routes.add(PagesRouter());

    /* 注册路由 */
    for (var router in _routes) {
      _routesResult.addAll(router.initRouter());
    }
  }

  /// 获取路由
  GoRouter goRouter(GlobalKey<NavigatorState> rootNavigatorKey) {
    return GoRouter(
      navigatorKey: rootNavigatorKey,
      initialLocation: '/',
      routes: _routesResult
    );
  }
}
