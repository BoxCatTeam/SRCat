/// ===========================================================================
/// Copyright (c) 2020-2023, BoxCat. All rights reserved.
/// Date: 2023-05-09 09:51:27
/// LastEditTime: 2023-07-19 23:32:54
/// FilePath: /lib/libs/srcat/warp/cache.dart
/// ===========================================================================

import 'dart:io';
import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:srcat/utils/file/main.dart';
import 'package:srcat/utils/storage/main.dart';

class SRCatWarpCacheFileLib {
  /// 获取基本目录
  static String baseFolder() {
    String file = SRCatStorageUtils.read("hsr_path");
    if (file == "") throw Exception("Unkown Path");

    return file.replaceAll(RegExp(r"StarRail.exe"), "");
  }

  /// 获取缓存目录
  static Future<String?> cacheFolder() async {
    String base = baseFolder();
    String baseCache = "${base}StarRail_Data/webCaches";
    Directory baseCacheDir = Directory(baseCache);
    // 获取 webCaches 下的所有文件夹（不包括文件）
    Iterable<Directory> subDirectories = baseCacheDir.listSync().whereType<Directory>();

    // 版本号缓存
    List<String> versions = [];
    for (Directory subDirectory in subDirectories) {
      String subDirName = subDirectory.path.split('\\').last;

      // 正则获取版本号
      RegExp verRegExp = RegExp(r'([\d.]+)$');
      RegExpMatch? match = verRegExp.firstMatch(subDirName);
      if (match != null) {
        versions.add(match.group(1).toString());
      }
    }

    // 如果版本号为空则返回默认目录
    if (versions.isEmpty) {
      Directory defaultDir = Directory("$baseCache/Cache/Cache_Data");
      try {
        if (!await defaultDir.exists()) {
          throw Exception("Not Found HSR cache folder");
        }
      } catch (e) {
        if (kDebugMode) print("[MHoYFile Utils] 寻找缓存目录失败 | 错误原因: $e");
        return null;
      }

      return defaultDir.path.toString();
    }

    String latestVersion = versions.first;

    for (var i = 1; i < versions.length; i++) {
      var version = versions[i];

      var list1 = latestVersion.split('.').map(int.parse).toList();
      var list2 = version.split('.').map(int.parse).toList();

      for (var i = 0; i < list1.length; i++) {
        if (list1[i] > list2[i]) {
          break;
        } else if (list1[i] < list2[i]) {
          latestVersion = version;
          break;
        }
      }
    }

    Directory currentDir = Directory("$baseCache/$latestVersion/Cache/Cache_Data");

    try {
      if (!await currentDir.exists()) {
        throw Exception("Not Found HSR cache folder");
      }
    } catch (e) {
      if (kDebugMode) print("[MHoYFile Utils] 寻找缓存目录失败 | 错误原因: $e");
      return null;
    }

    return currentDir.path.toString();
  }

  /// 读取缓存文件
  static Future<Uint8List?> readCacheFileBytes() async {
    String? cache = await cacheFolder();
    if (cache == null) return null;

    String path = "${SRCatFileUtils.getExeDir()}/data/hsr_data_temp";
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
