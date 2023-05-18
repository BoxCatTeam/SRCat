/// ===========================================================================
/// Copyright (c) 2020-2023, BoxCat. All rights reserved.
/// Date: 2023-05-06 22:42:30
/// LastEditTime: 2023-05-07 03:04:19
/// FilePath: /lib/application.dart
/// ===========================================================================

import 'package:fluent_ui/fluent_ui.dart';
import 'package:go_router/go_router.dart';

class Application {
  static late GoRouter router;
  static late GlobalKey<NavigatorState> rootNavigatorKey;
  
  /* Windows buildNumber */
  static late int buildNumber;
  /* Windows productName */
  static late String productName;
}
