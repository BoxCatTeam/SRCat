///
/// Author: ohmyga
/// Date: 2023-05-13 17:45:29
/// LastEditTime: 2023-05-14 07:34:56
///
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
<<<<<<< HEAD
  
=======
  static int appNumVersion = 100006;

  /* App NavigatorKey */
  static GlobalKey<NavigatorState> appNavigatorKey = GlobalKey<NavigatorState>();

>>>>>>> bf52e1f8badeeb9d60ede91a40c54344d5a423a3
  /* Windows buildNumber */
  static late int buildNumber;
  /* Windows productName */
  static late String productName;
}
