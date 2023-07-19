/// ===========================================================================
/// Copyright (c) 2020-2023, BoxCat. All rights reserved.
/// Date: 2023-05-09 09:43:45
/// LastEditTime: 2023-07-20 03:56:46
/// FilePath: /lib/libs/srcat/warp/main.dart
/// ===========================================================================

//import 'package:srcat/config/hoyolab.dart';
import 'package:srcat/utils/http/dio.dart';
import 'package:srcat/utils/main.dart';

import 'cache.dart';

enum GachaGetType { stoken, proxy, cache, url }
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
    Map<String, dynamic>? stokenData,
    String? userInptLink,
  }) async {
    String apiUrl = "https://api-takumi.mihoyo.com/common/gacha_record/api/getGachaLog?"
      "authkey_ver=%authkey_ver%"               "&"
      "sign_type=%sign_type%"                   "&"
      "auth_appid=webview_gacha"                "&"
      "win_mod=fullscreen"                      "&"
      "gacha_id=%gacha_id%"                     "&"
      "timestamp=%timestamp%"                   "&"
      "region=%region%"                         "&"
      "default_gacha_type=%default_gacha_type%" "&"
      "lang=zh-cn"                              "&"
      "authkey=%authkey%"                       "&"
      "game_biz=%game_biz%"                     "&"
      "os_system=%os_system%"                   "&"
      "device_model=%device_model%"             "&"
      "plat_type=pc"                            "&"
      "page=%page%"                             "&"
      "size=%size%"                             "&"
      "gacha_type=%gacha_type%"                 "&" // 11: 角色 | 12: 武器 | 1: 常驻 | 2: 新手
      "end_id=%end_id%"                         "";

    switch (type) {
      case GachaGetType.stoken:
        await _getDataFromSToken(
          success: success,
          fail: fail,
          page: page,
          apiUrl: apiUrl,
          size: size,
          endId: endId,
          warpType: warpType,
          stokenData: stokenData
        );
        break;
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
        await _getDataFromLink(
          success: success,
          fail: fail,
          apiUrl: apiUrl,
          page: page,
          size: size,
          endId: endId,
          warpType: warpType,
          userInptLink: userInptLink
        );
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
      .replaceAll("%sign_type%", params["sign_type"]!)
      .replaceAll("%authkey_ver%", params["authkey_ver"]!)
      .replaceAll("%timestamp%", params["timestamp"]!)
      .replaceAll("%region%", params["region"]!)
      .replaceAll("%default_gacha_type%", gachaWarpTypeValue[warpType].toString())
      .replaceAll("%authkey%", params["authkey"]!.replaceAll("+", "%2B"))
      .replaceAll("%os_system%", params["os_system"]!)
      .replaceAll("%device_model%", params["device_model"]!)
      .replaceAll("%game_biz%", params["game_biz"] ?? "hkrpg_cn")
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

  static Future<void> _getDataFromSToken({
    required Success success,
    required Fail fail,
    int page = 1,
    int size = 5,
    int endId = 0,
    required String apiUrl,
    GachaWarpType warpType = GachaWarpType.regular,
    Map<String, dynamic>? stokenData
  }) async {
    if (stokenData == null) {
      fail(statusCode[Status.warpCacheEmpty]!, "获取 AuthKey 失败", FailType.mhu, null);
      return;
    }

    /*String api = apiUrl.replaceAll("%timestamp%", stokenData["timestamp"].toString())
      .replaceAll("%sign_type%", stokenData["sign_type"]!)
      .replaceAll("%authkey_ver%", stokenData["authkey_ver"]!)
      .replaceAll("%authkey%", stokenData["authkey"].toString().replaceAll("+", "%2B").replaceAll("/", "%2F").replaceAll("=", "%3D"))
      .replaceAll("%region%", stokenData["region"])
      .replaceAll("%game_biz%", stokenData["game_biz"])
      .replaceAll("%default_gacha_type%", gachaWarpTypeValue[warpType].toString())
      .replaceAll("%page%", page.toString())
      .replaceAll("%size%", size.toString())
      .replaceAll("%gacha_type%", gachaWarpTypeValue[warpType].toString())
      .replaceAll("%end_id%", endId.toString())
      // 非必要参数
      .replaceAll("%os_system%", stokenData["os_system"])
      .replaceAll("%device_model%", stokenData["device_model"])
      .replaceAll("%gacha_id%", "0");*/

    //String api = "${HoYoLabConfig.authKeyGetGachaLogApi}?"
    //  "timestamp=${stokenData["timestamp"].toString()}"
    //  "&sign_type=${stokenData["sign_type"]}"
    //  "&authkey=${stokenData["authkey"].toString().replaceAll("+", "%2B")}"
    //  "&region=${stokenData["region"]}"
    //  "&game_biz=${stokenData["game_biz"]}"
    //  "&page=$page"
    //  "&size=$size"
    //  "&gacha_type=${gachaWarpTypeValue[warpType].toString()}"
    //  "&end_id=${endId.toString()}"
    //  "&os_system=${stokenData["os_system"]}"
    //  "&device_model=${stokenData["device_model"]}"
    //  "&default_gacha_type=${gachaWarpTypeValue[warpType].toString()}";
    //print(api);

    //await SCDioUtils.request(
    //  method: Method.GET,
    //  uri: Uri.parse(api),
    //  success: success,
    //  fail: fail
    //);
  }

  static Future<void> _getDataFromLink({
    required Success success,
    required Fail fail,
    required String apiUrl,
    int page = 1,
    int size = 5,
    int endId = 0,
    GachaWarpType warpType = GachaWarpType.regular,
    String? userInptLink,
  }) async {
    if (userInptLink == null) {
      fail(statusCode[Status.warpUserInputError]!, "用户输入链接为空", FailType.mhu, null);
      return;
    }

    Uri link = Uri.parse(userInptLink);
    Map<String, String> params = link.queryParameters;

    if (
      params["authkey"] == null ||
      params["game_biz"] == null ||
      params["region"] == null
    ) {
      fail(statusCode[Status.warpUserInputError]!, "链接不完整，关键参数丢失。", FailType.mhu, null);
      return;
    }

    String api = apiUrl.replaceAll("%gacha_id%", params["gacha_id"] ?? "0")
      .replaceAll("%sign_type%", params["sign_type"] ?? "")
      .replaceAll("%authkey_ver%", params["authkey_ver"] ?? "2")
      .replaceAll("%timestamp%", params["timestamp"] ?? SRCatUtils.getUnixTime().toString())
      .replaceAll("%region%", params["region"] ?? "prod_gf_cn")
      .replaceAll("%default_gacha_type%", gachaWarpTypeValue[warpType].toString())
      .replaceAll("%authkey%", params["authkey"] != null ? params["authkey"]!.replaceAll("+", "%2B") : "")
      .replaceAll("%os_system%", params["os_system"] ?? "Windows 11  (10.0.22621) 64bit")
      .replaceAll("%device_model%", params["device_model"] ?? "System Product Name (ASUS)")
      .replaceAll("%game_biz%", params["game_biz"] ?? "hkrpg_cn")
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
