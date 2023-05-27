/// ===========================================================================
/// Copyright (c) 2020-2023, BoxCat. All rights reserved.
/// Date: 2023-05-06 22:42:30
/// LastEditTime: 2023-05-25 01:32:12
/// FilePath: /lib/application.dart
/// ===========================================================================

import 'package:fluent_ui/fluent_ui.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:package_info_plus/package_info_plus.dart';

class Application {
  static late GoRouter router;
  static late GlobalKey<NavigatorState> rootNavigatorKey;
  
  /* Windows buildNumber */
  static late int buildNumber;
  /* Windows productName */
  static late String productName;

  static late PackageInfo packageInfo;

  static late ProviderContainer globalProviderScope;
}
