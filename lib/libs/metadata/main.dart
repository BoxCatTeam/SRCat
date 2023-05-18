/// ===========================================================================
/// Copyright (c) 2020-2023, BoxCat. All rights reserved.
/// Date: 2023-05-17 22:14:16
/// LastEditTime: 2023-05-17 23:50:32
/// FilePath: /lib/libs/metadata/main.dart
/// ===========================================================================

import 'package:srcat/config/api.dart';
import 'package:srcat/utils/http/dio.dart';
import 'package:srcat/utils/main.dart';

import 'db.dart';

class SRCatMetadataLib {
  /// 检查元数据库是否有更新
  static Future<bool> checkIndexUpdate() async {
    bool hasNewVer = false;
    List<Map<String, dynamic>> allVersion = await SRCatMetadataDatabaseLib.getVersionInfo(lang: "chs");
    if (allVersion.isEmpty) {
      return false;
    }
    
    Map<String, dynamic> latestVersion = allVersion[0];

    /// 从 API 获取更新信息
    await SCDioUtils.request(method: Method.GET,
      uri: Uri.parse(SRCatAPIConfig.metadataCheckUpdate),
      success: (response, data) {
        if (SRCatUtils.getVersionNumber(data["version"]) > SRCatUtils.getVersionNumber(latestVersion["version"])) {
          hasNewVer = true;
        }
      },
      fail: (code, message, failType, dioError) {}
    );

    return hasNewVer;
  }
}
