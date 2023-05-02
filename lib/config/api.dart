/// ===========================================================================
/// Copyright (c) 2020-2023, BoxCat. All rights reserved.
/// Date: 2023-05-02 23:54:44
/// LastEditTime: 2023-05-03 02:55:32
/// FilePath: /lib/config/api.dart
/// ===========================================================================

import 'package:srcat/application.dart';

class SRCatAPIConfig {
  static String base = "https://srcat-static.api.cat.beer/api/v1";
  /// Item Data
  static String warpItemData = "$base/warp/100001/item.json?v=${Application.appNumVersion}";
  /// Check Update
  static String checkUpdate = "$base/base/check-update.json?v=${Application.appNumVersion}";
}
