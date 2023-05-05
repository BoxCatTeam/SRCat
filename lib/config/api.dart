/// ===========================================================================
/// Copyright (c) 2020-2023, BoxCat. All rights reserved.
/// Date: 2023-05-02 23:54:44
/// LastEditTime: 2023-05-04 18:44:06
/// FilePath: /lib/config/api.dart
/// ===========================================================================

import 'package:srcat/application.dart';

class SRCatAPIConfig {
  static String base = "https://srcat-static.api.cat.beer/api/v1";
  /// Check Update
  static String checkUpdate = "$base/base/check-update.json?v=${Application.appNumVersion}";
  /// Item Base Data
  static String itemBaseData = "$base/warp/100001/item.json?v=${Application.appNumVersion}";
}
