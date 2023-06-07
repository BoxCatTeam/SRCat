/// ===========================================================================
/// Copyright (c) 2020-2023, BoxCat. All rights reserved.
/// Date: 2023-05-25 10:37:05
/// LastEditTime: 2023-05-29 19:23:47
/// FilePath: /lib/config/hoyolab.dart
/// ===========================================================================

import 'package:srcat/libs/hoyolab/dynamic_secret/salt_type.dart';

class HoYoLabConfig {
  static String geetestApi = "https://api.geetest.com";
  static String geetestApiV6 = "https://apiv6.geetest.com";

  static String takumiBaseApi = "https://api-takumi.mihoyo.com";
  static String takumiAuthApi = "$takumiBaseApi/auth/api";
  static String takumiBindingApi = "$takumiBaseApi/binding/api";
  static String takumiAccountApi = "$takumiBaseApi/account/auth/api";

  static String passportApi = "https://passport-api.mihoyo.com";
  static String passportAuthApi = "$passportApi/account/auth/api";
  static String passportApiV4  = "https://passport-api-v4.mihoyo.com";

  /// 获取 stoken 与 ltoken
  static String authMuiltApi = "$takumiAuthApi/getMultiTokenByLoginTicket?login_ticket=%loginTicket%&uid=%uid%&token_types=3";
  /// 获取 stoken 与 ltoken
  static String authActionTicketApi = "$takumiAuthApi/getActionTicketBySToken?action_type=%actionType%&stoken=%stoken%&uid=%uid%";
  /// 获取 cookieToken
  static String getCookieByStokenApi = "$passportAuthApi/getCookieAccountInfoBySToken";
  /// 获取 Ltoken
  static String getLtokenByStoken = "$passportAuthApi/getLTokenBySToken";
  /// 获取 V2Stoken
  static String getV2Stoken = "$passportApi/account/ma-cn-session/app/getTokenBySToken";
  /// 使用密码登录
  static String loginByPassword = "$passportApi/account/ma-cn-passport/app/loginByPassword";
  /// 验证 Ltoken 是否有效
  static String verifyLtoken = "$passportApiV4/account/ma-cn-session/web/verifyLtoken";
  /// 创建 ActionTicket
  static String createActionTicket = "$passportApi/account/ma-cn-verifier/app/createActionTicketByToken";
  /// 创建 AuthKey
  static String generateAuthKey = "$takumiAuthApi/genAuthKey";
  static String generateBindingAuthKey = "$takumiBindingApi/genAuthKey";
  static String generateAccountAuthKey = "$takumiAccountApi/genAuthKey";

  /// 获取用户角色信息
  static String stokenGetRoles = "$takumiBindingApi/getUserGameRolesByStoken";
  static String actionTicketGetRoles = "$takumiBindingApi/getUserGameRoles?action_ticket=%actionTicket%&game_biz=hkrpg_cn";

  static String bbsBaseApi = "https://bbs-api.mihoyo.com";
  static String bbsUserApi = "$bbsBaseApi/user/wapi";
  static String getSelfInfo = "$bbsUserApi/getUserFullInfo?gids=2";
  static String bbsReferer = "https://bbs.mihoyo.com/";

  static String appReferer = "https://app.mihoyo.com/";

  static String webStaticWarpIndex = "https://webstatic.mihoyo.com/hkrpg/event/e20211215gacha-v2/index.html";

  static String hkrpgApi = "https://hkrpg-api.mihoyo.com";
  static String hkrpgGachaInfoApi = "$hkrpgApi/event/gacha_info/api";
  static String authKeyGetGachaLogApi = "$hkrpgGachaInfoApi/getGachaLog";

  static String hoyolabLoginPageUrl = "https://user.mihoyo.com/#/login/password";

  /// ====================================================================================================
  static String xrpcVersion = "2.50.1";
  static String userAgent = "Mozilla/5.0 (Windows NT 11.0; Win64; x64) miHoYoBBS/%XrpcVersion%";
  static String mobileUserAgent = "Mozilla/5.0 (Google Pixel 5; Android 13) Mobile miHoYoBBS/%XrpcVersion%";

  static String salts(HoYoLabDynamicSecretSaltType saltType) {
    const Map<HoYoLabDynamicSecretSaltType, String> saltList = {
      HoYoLabDynamicSecretSaltType.x4: "xV8v4Qu54lUKrEYFZkJhB8cuOh9Asafs",
      HoYoLabDynamicSecretSaltType.x6: "t0qEgfub6cvueAPgR5m9aQWWVciEer7v",
      HoYoLabDynamicSecretSaltType.k2: "A4lPYtN0KGRVwE5M5Fm0DqQiC5VVMVM3",
      HoYoLabDynamicSecretSaltType.lk2: "kkFiNdhyHqZ1VnDRHnU1podIvO4eiHcs",
      HoYoLabDynamicSecretSaltType.prod: "JwYDpKvLj6MrMqqYU6jTKF17KNO2PXoS"
    };

    return saltList[saltType].toString();
  }

  static Map<String, dynamic> xrpcHeaders(String deviceId) => {
    "User-Agent": userAgent.replaceAll("%XrpcVersion%", xrpcVersion),
    "Accept": "application/json",
    "x-rpc-app_version": xrpcVersion,
    "x-rpc-client_type": "5",
    "x-rpc-device_id": deviceId
  };

  static Map<String, dynamic> xrpc2Headers(String deviceId) => {
    "User-Agent": userAgent.replaceAll("%XrpcVersion%", xrpcVersion),
    "Accept": "application/json",
    "x-rpc-aigis": "",
    "x-rpc-app_id": "bll8iq97cem8",
    "x-rpc-app_version": xrpcVersion,
    "x-rpc-client_type": "2",
    "x-rpc-device_id": deviceId,
    "x-rpc-game_biz": "bbs_cn",
    "x-rpc-sdk_version": "1.3.1.2"
  };
}
