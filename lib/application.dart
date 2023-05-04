/// ===========================================================================
/// Copyright (c) 2020-2023, BoxCat. All rights reserved.
/// Date: 2023-04-28 18:09:31
/// LastEditTime: 2023-05-04 22:00:30
/// FilePath: /lib/application.dart
/// ===========================================================================

import 'package:fluent_ui/fluent_ui.dart';
import 'package:go_router/go_router.dart';

class Application {
  static late GoRouter router;
  static late GlobalKey<NavigatorState> rootNavigatorKey;
  static int appNumVersion = 100002;

  /* App NavigatorKey */
  static GlobalKey<NavigatorState> appNavigatorKey = GlobalKey<NavigatorState>();

  /* Windows buildNumber */
  static late int buildNumber;
  /* Windows productName */
  static late String productName;
}
