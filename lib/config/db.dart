/// ===========================================================================
/// Copyright (c) 2020-2023, BoxCat. All rights reserved.
/// Date: 2023-05-08 23:33:07
/// LastEditTime: 2023-05-15 16:33:02
/// FilePath: /lib/config/db.dart
/// ===========================================================================

<<<<<<< HEAD
/// 数据库配置文件
class SRCatDatabaseConfig {
  /// 用户数据库
  static String userdata = "userdata.db";
  /// 元数据数据库
  static String metadata = "metadata.db";
  
  /* ==================== 用户数据库 - 表 ==================== */
  /// 跃迁记录存档
  static String userdataWarpIndexTable = "warp_index";
  /// 跃迁记录
  static String userdataWarpGachaLogTable = "warp_gacha_log";
  /// 游戏账号
  static String userdataGameAccountsTable = "game_accounts";
  
  /* ==================== 元数据数据库 - 表 ==================== */
  /// 版本历史
  static String metadataVersionTable = "version";
  /// 图片
  static String metadataImageTable = "images";
  /// 信息
  static String metadataFilesTable = "files";
=======
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
>>>>>>> bf52e1f8badeeb9d60ede91a40c54344d5a423a3
}
