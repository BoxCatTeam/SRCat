/// ===========================================================================
/// Copyright (c) 2020-2023, BoxCat. All rights reserved.
/// Date: 2023-07-21 00:16:06
/// LastEditTime: 2023-07-21 00:23:32
/// FilePath: /lib/config/settings_db.dart
/// ===========================================================================

class SRCatSettingsDatabaseKey {
  /* ==================== 跃迁 ==================== */
  /// 前缀
  static const String _warpPrefix = "Warp.";
  /// 是否全量刷新跃迁数据
  static String fullRefreshGachaLog = "${_warpPrefix}FullRefreshGachaLog";
  /// 是否显示始发跃迁
  static String showStarterGachaLog = "${_warpPrefix}ShowStarterGachaLog";
}
