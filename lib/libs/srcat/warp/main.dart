/// ===========================================================================
/// Copyright (c) 2020-2023, BoxCat. All rights reserved.
/// Date: 2023-05-09 09:43:45
/// LastEditTime: 2023-05-09 09:49:10
/// FilePath: /lib/libs/srcat/warp/main.dart
/// ===========================================================================

import 'package:srcat/utils/http/dio.dart';

import 'cache.dart';

enum GachaGetType { proxy, cache, url }
enum GachaWarpType { regular, character, lightCone, starter }
const gachaWarpTypeValue = {
  GachaWarpType.regular: 1,
  GachaWarpType.starter: 2,
  GachaWarpType.character: 11,
  GachaWarpType.lightCone: 12,
};

class SRCatWarpLib {
  /// 从缓存获取跃迁链接
  static Future<Uri?> gachaLink() async {
    String? uri = await SRCatWarpCacheFileLib.getWarpUrl();
    if (uri == null) return null;

    return Uri.parse(uri);
  }

  /// 获取跃迁链接并拉取数据
  static Future<void> getGachaData({
    GachaGetType type = GachaGetType.cache,
    required Success success,
    required Fail fail,
    int page = 1,
    int size = 5,
    int endId = 0,
    GachaWarpType warpType = GachaWarpType.regular,
  }) async {
    String apiUrl = "https://api-takumi.mihoyo.com/common/gacha_record/api/getGachaLog?"
      "authkey_ver=1"                           "&"
      "sign_type=2"                             "&"
      "auth_appid=webview_gacha"                "&"
      "win_mod=fullscreen"                      "&"
      "gacha_id=%gacha_id%"                     "&"
      "timestamp=%timestamp%"                   "&"
      "region=%region%"                         "&"
      "default_gacha_type=%default_gacha_type%" "&"
      "lang=zh-cn"                              "&"
      "authkey=%authkey%"                       "&"
      "game_biz=hkrpg_cn"                       "&"
      "os_system=%os_system%"                   "&"
      "device_model=%device_model%"             "&"
      "plat_type=pc"                            "&"
      "page=%page%"                             "&"
      "size=%size%"                             "&"
      "gacha_type=%gacha_type%"                 "&" // 11: 角色 | 12: 武器 | 1: 常驻 | 2: 新手
      "end_id=%end_id%"                         "";

    switch (type) {
      case GachaGetType.proxy:
        break;
      case GachaGetType.cache:
        await _getDataFromCache(
          success: success,
          fail: fail,
          apiUrl: apiUrl,
          page: page,
          size: size,
          endId: endId,
          warpType: warpType
        );
        break;
      case GachaGetType.url:
        break;
    }
  }

  static Future<void> _getDataFromCache({
    required Success success,
    required Fail fail,
    required String apiUrl,
    int page = 1,
    int size = 5,
    int endId = 0,
    GachaWarpType warpType = GachaWarpType.regular,
  }) async {
    Uri? cache = await gachaLink();
    if (cache == null) {
      fail(statusCode[Status.warpCacheEmpty]!, "获取缓存失败", FailType.mhu, null);
      return;
    }

    Map<String, String> params = cache.queryParameters;
    String api = apiUrl.replaceAll("%gacha_id%", params["gacha_id"]!)
      .replaceAll("%timestamp%", params["timestamp"]!)
      .replaceAll("%region%", params["region"]!)
      .replaceAll("%default_gacha_type%", gachaWarpTypeValue[warpType].toString())
      .replaceAll("%authkey%", params["authkey"]!.replaceAll("+", "%2B"))
      .replaceAll("%os_system%", params["os_system"]!)
      .replaceAll("%device_model%", params["device_model"]!)
      .replaceAll("%page%", page.toString())
      .replaceAll("%size%", size.toString())
      .replaceAll("%gacha_type%", gachaWarpTypeValue[warpType].toString())
      .replaceAll("%end_id%", endId.toString());

    await SCDioUtils.request(
      method: Method.GET,
      uri: Uri.parse(api),
      success: success,
      fail: fail
    );
  }
}
