/// ===========================================================================
/// Copyright (c) 2020-2023, BoxCat. All rights reserved.
/// Date: 2023-05-01 23:27:10
/// LastEditTime: 2023-05-04 18:32:13
/// FilePath: /lib/config/db.dart
/// ===========================================================================

import 'package:srcat/config/file.dart';
import 'package:srcat/utils/file/main.dart';

class SCDatabaseConfig {
  /// Base
  static String base = "${FileUtils.getExeDir()}/${SCFileConfig.databases}";
  /// Warp
  static String warpMaster = "$base/warp.db";
  /// Data
  static String dataMaster = "$base/data.db";

  /// Warp Table Name
  static String warpIndexTable = "warp_index";
  static String warpGachaLogOldTable = "gacha_log";
  static String warpGachaLogTable = "warp_gacha_log";
  static String warpItemTable = "item_data"; /// DELETE

  /// Data Table Name
  static String dataItemBaseTable = "sr_base_item";
}
