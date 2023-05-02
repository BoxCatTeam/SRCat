/// ===========================================================================
/// Copyright (c) 2020-2023, BoxCat. All rights reserved.
/// Date: 2023-05-01 18:17:17
/// LastEditTime: 2023-05-02 06:50:56
/// FilePath: /lib/utils/file/mh.dart
/// ===========================================================================

import 'dart:io';
import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:srcat/config/settings.dart';
import 'package:srcat/utils/settings/main.dart';

import 'main.dart';

class MHoYFileUtils {
  /// 获取基本目录
  static String baseFolder() {
    String file = SCSettingsUtils.get(SCSettingsSPKey.hsrExe);
    if (file == "") throw Exception("Unkown Path");

    return file.replaceAll(RegExp(r"StarRail.exe"), "");
  }

  /// 获取缓存目录
  static Future<String?> cacheFolder() async {
    String base = baseFolder();
    String cache = "${base}StarRail_Data/webCaches/Cache/Cache_Data";
    Directory dir = Directory(cache);

    try {
      if (!await dir.exists()) {
        throw Exception("Not Found HSR cache folder");
      }
    } catch (e) {
      if (kDebugMode) print("[MHoYFile Utils] 寻找缓存目录失败 | 错误原因: $e");
      return null;
    }

    return cache;
  }

  /// 读取缓存文件
  static Future<Uint8List?> readCacheFileBytes() async {
    String? cache = await cacheFolder();
    if (cache == null) return null;

    String path = "${FileUtils.getExeDir()}/data/ga_temp";
    File tempCache = File(path);

    if (await tempCache.exists()) {
      await tempCache.delete();
    }
    
    File cacheFile = File("$cache/data_2");
    await cacheFile.copy(path);
    
    RandomAccessFile raf = tempCache.openSync(mode: FileMode.read);
    Uint8List bytes = raf.readSync(tempCache.lengthSync());

    await raf.close();

    return bytes;
  }

  /// 从缓存文件中读取跃迁链接
  static Future<String?> getWarpUrl() async {
    Uint8List? bytes = await readCacheFileBytes();
    if (bytes == null) return null;

    int lastIndexOf(Uint8List source, Uint8List target) {
      for (int i = source.length - target.length; i >= 0; i--) {
        bool found = true;
        for (int j = 0; j < target.length; j++) {
          if (source[i + j] != target[j]) {
            found = false;
            break;
          }
        }
        if (found) return i;
      }
      return -1;
    }

    String link = "https://webstatic.mihoyo.com/hkrpg/event/e20211215gacha-v2/index.html";
    Uint8List linkList = Uint8List.fromList(link.codeUnits);

    int index = lastIndexOf(bytes, linkList);
    if (index >= 0) {
      int length = bytes.sublist(index).indexOf(0);
      return utf8.decode(bytes.sublist(index, index + length));
    }

    return null;
  }
}
