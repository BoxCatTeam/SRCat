/// ===========================================================================
/// Copyright (c) 2020-2023, BoxCat. All rights reserved.
/// Date: 2023-05-14 09:00:30
/// LastEditTime: 2023-05-18 04:37:39
/// FilePath: /lib/config/api.dart
/// ===========================================================================

/// API 配置文件
class SRCatAPIConfig {
  /// Base Url
  static String base = "https://srcat-api.cat.beer";
  /// RESTAPI Version
  static String version = "v1";
  /// Check Update
  static String checkUpdate = "$base/app/check-update";

  /// Metadata
  static String metadata = "$base/$version/metadata";
  /// Metadata Check Update
  static String metadataCheckUpdate = "$base/$version/metadata/check-update";

  /// Item Info
  static String itemInfo = "$base/$version/item/{item_id}/{lang}";
  /// Item Dict
  static String itemDict = "$base/$version/dict/{item_id}/{lang}";
}
