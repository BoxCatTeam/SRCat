/// ===========================================================================
/// Copyright (c) 2020-2023, BoxCat. All rights reserved.
/// Date: 2023-05-08 23:33:07
/// LastEditTime: 2023-05-15 16:33:02
/// FilePath: /lib/config/db.dart
/// ===========================================================================

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
  /// 用户账号
  static String userdataUserAccountsTable = "user_accounts";
  
  /* ==================== 元数据数据库 - 表 ==================== */
  /// 版本历史
  static String metadataVersionTable = "version";
  /// 图片
  static String metadataImageTable = "images";
  /// 信息
  static String metadataFilesTable = "files";
}
