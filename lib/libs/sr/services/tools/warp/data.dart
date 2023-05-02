/// ===========================================================================
/// Copyright (c) 2020-2023, BoxCat. All rights reserved.
/// Date: 2023-05-02 08:18:13
/// LastEditTime: 2023-05-03 01:26:58
/// FilePath: /lib/libs/sr/services/tools/warp/data.dart
/// ===========================================================================

import 'package:srcat/config/api.dart';
import 'package:srcat/utils/http/dio.dart';

class SrWrapToolDataService {
  /// 从 SRCat API 下载 item 数据
  static Future<Map<String, dynamic>> downloadItemData() async {
    String api = SRCatAPIConfig.warpItemData;
    Map<String, dynamic> data = {};

    await SCDioUtils.request(
      method: Method.GET,
      uri: Uri.parse(api),
      success: (response, rawData) {
        Map<String, dynamic> res = rawData["data"];
        if (res.isNotEmpty) {
          data = res;
        } else {
          data = {};
        }
      },
      fail: (code, message, failType, error) {
        data = {};
      }
    );

    return data;
  }

  /// 将数据写入数据库
  /// 判断是否需要更新
  static Future<bool> updateItemData() async {
    return false;
  }
}
