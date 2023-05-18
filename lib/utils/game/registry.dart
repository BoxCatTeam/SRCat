/// ===========================================================================
/// Copyright (c) 2020-2023, BoxCat. All rights reserved.
/// Date: 2023-05-07 22:52:01
/// LastEditTime: 2023-05-17 23:19:50
/// FilePath: /lib/utils/game/registry.dart
/// ===========================================================================

import 'dart:io';
import 'dart:convert';
import 'package:convert/convert.dart';

import 'package:srcat/utils/main.dart';
import 'package:win32_registry/win32_registry.dart';

/// 猫猫注册表工具类
class SRCatGameRegistry {
  static const String _hsrKey = "Software\\miHoYo\\崩坏：星穹铁道";
  static const String _accKey = "MIHOYOSDK_ADL_PROD_CN_h3123967166";
  static const String _gsKey = "GraphicsSettings_Model_h2986158309";
  static const String _gspcKey = "GraphicsSettings_PCResolution_h431323223";

  /// 读取值
  static Future<String?> read() async {
    // 原先使用 win_registry 库读取值，但是读取到的内容总是包含乱码
    // 导致 sdkey 保存后无法使用
    // 目前以命令行形式从注册表查询再用正则获取 sdkey

    ProcessResult result = await Process.run("reg query", [
      "HKEY_CURRENT_USER\\$_hsrKey",
      "/v",
      _accKey
    ], runInShell: true);

    String restr = result.stdout;
    String newRestr = restr.replaceAll(RegExp(r'\s+'), '');
    RegExpMatch? match = RegExp(r'REG_BINARY(.*)').firstMatch(newRestr);

    if (match != null) {
      return utf8.decode(hex.decode(match.group(1)!));
    }

    return null;
  }

  /// 写入值
  static void write(String sdkey) {
    final reg = Registry.openPath(
      RegistryHive.currentUser,
      path: _hsrKey,
      desiredAccessRights: AccessRights.writeOnly
    );
    
    /// Token 转换为 List<int>
    List<int> token = sdkey.codeUnits;

    reg.createValue(RegistryValue(_accKey, RegistryValueType.binary, token));
  }

  /// 修改 FPS
  static bool setFPS(int fps) {
    final reg = Registry.openPath(
      RegistryHive.currentUser,
      path: _hsrKey,
      desiredAccessRights: AccessRights.allAccess
    );
    if (reg.getValue(_gsKey) == null) {
      return false;
    }

    List<int> list = reg.getValue(_gsKey)!.data as List<int>;
    String config = SRCatUtils.listToString(list);

    /// 这里的字符串没法正常使用 json.decode 解析为 Map 所以只能用正则替换
    RegExp regExp = RegExp(r'"FPS":\d+,');
    config = config.replaceAll(regExp, '"FPS":$fps,');

    reg.createValue(RegistryValue(_gsKey, RegistryValueType.binary, config.codeUnits));
    return true;
  }

  /// 获取游戏内默认分辨率
  static List<int>? getWindowSize() {
    final reg = Registry.openPath(
      RegistryHive.currentUser,
      path: _hsrKey,
      desiredAccessRights: AccessRights.allAccess
    );

    if (reg.getValue(_gspcKey) == null) {
      return null;
    }

    List<int> list = reg.getValue(_gspcKey)!.data as List<int>;
    final listFilter = list.where((byte) => byte > 32 && byte < 127).toList();
    Map<String, dynamic> result;
    try {
      result = json.decode(SRCatUtils.listToString(listFilter));
    } catch (e) {
      return [0, 0];
    }

    return [result["width"], result["height"]];
  }

  /// 修改游戏窗口与分辨率
  static bool setWindow({
    bool? isFullScreen,
    int? width,
    int? height
  }) {
    final reg = Registry.openPath(
      RegistryHive.currentUser,
      path: _hsrKey,
      desiredAccessRights: AccessRights.allAccess
    );
    if (reg.getValue(_gspcKey) == null) {
      return false;
    }

    List<int> list = reg.getValue(_gspcKey)!.data as List<int>;
    String config = SRCatUtils.listToString(list);

    /// 这里的字符串没法正常使用 json.decode 解析为 Map 所以只能用正则替换
    if (isFullScreen != null) {
      RegExp regExp = RegExp(r'"isFullScreen":(true|false)');
      config = config.replaceAll(regExp, '"isFullScreen":${isFullScreen.toString()}');
    }

    if (width != null) {
      RegExp regExp = RegExp(r'"width":\d+,');
      config = config.replaceAll(regExp, '"width":$width,');
    }

    if (height != null) {
      RegExp regExp = RegExp(r'"height":\d+,');
      config = config.replaceAll(regExp, '"height":$height,');
    }
    
    reg.createValue(RegistryValue(_gspcKey, RegistryValueType.binary, config.codeUnits));
    
    return true;
  }
}
