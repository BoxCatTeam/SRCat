/// ===========================================================================
/// Copyright (c) 2020-2023, BoxCat. All rights reserved.
/// Date: 2023-05-25 05:08:04
/// LastEditTime: 2023-05-25 09:43:39
/// FilePath: /lib/utils/webview2/main.dart
/// ===========================================================================

import 'package:srcat/utils/storage/main.dart';

class SRCatWebView2HelperUtils {
  /// WebView2 Cache Dir
  static String cacheDir = "${SRCatStorageUtils.read("data_path")}/cache/webview2";

  /// 将 Cookie 字符串转换为 Map<String, String>
  static Map<String, String> strCookieToMap(String? cookies) {
    if (cookies == null) {
      return {};
    }

    List<String> cookieList = cookies.split('; ');

    if (cookieList.isEmpty) {
      return {};
    }

    Map<String, String> result = {};

    for (String cookie in cookieList) {
      List<String> cookieSplit = cookie.split('=');
      result.addEntries({
        cookieSplit[0].toString(): cookieSplit[1].toString()
      }.entries);
    }

    return result;
  }
}
