/// ===========================================================================
/// Copyright (c) 2020-2023, BoxCat. All rights reserved.
/// Date: 2023-05-08 00:24:09
/// LastEditTime: 2023-05-27 13:09:15
/// FilePath: /lib/utils/main.dart
/// ===========================================================================
// ignore_for_file: depend_on_referenced_packages

import 'dart:convert';

import 'package:uuid/uuid.dart';
import 'package:crypto/crypto.dart';
import 'package:url_launcher/url_launcher.dart';

/// 常用工具类
class SRCatUtils {
  static String listToString(List<int> list) {
    final codeUnits = list.map((i) => String.fromCharCode(i)).toList();
    return codeUnits.join('');
  }

  /// 打开外部链接
  static void openUrl(Uri uri) => launchUrl(uri);
  /// 打开目录
  static void openFolder(Uri folder) => launchUrl(
    folder,
    mode: LaunchMode.externalApplication,
  );

  /// 字符串转 10 位时间戳
  static strToUnixTime(String time) {
    DateTime dateTime = DateTime.parse(time);
    return dateTime.millisecondsSinceEpoch ~/ 1000;
  }

  /// 10 位数 Unix 时间戳转换为时间
  static unixTimeToStr(int unixTime, { String format = "yyyy/MM/dd" }) {
    DateTime dateTime = DateTime.fromMillisecondsSinceEpoch(unixTime * 1000);
    /// 按照 format 格式化时间
    return format.replaceAll("yyyy", dateTime.year.toString())
      .replaceAll("MM", dateTime.month.toString().padLeft(2, "0"))
      .replaceAll("dd", dateTime.day.toString().padLeft(2, "0"))
      .replaceAll("HH", dateTime.hour.toString().padLeft(2, "0"))
      .replaceAll("mm", dateTime.minute.toString().padLeft(2, "0"))
      .replaceAll("ss", dateTime.second.toString().padLeft(2, "0"));
  }

  /// 获取当前时间戳
  static int getUnixTime() => DateTime.now().millisecondsSinceEpoch ~/ 1000;

  /// 根据值获取 UUID v5
  static String getUUIDv5(String value) {
    Uuid uuid = const Uuid();
    return uuid.v5(Uuid.NAMESPACE_URL, value);
  }

  /// 字符串版本号转为数字版本号
  static int getVersionNumber(String version) {
    List versionCells = version.split('.');
    versionCells = versionCells.map((i) => int.parse(i)).toList();
    return versionCells[0] * 100000 + versionCells[1] * 1000 + versionCells[2];
  }

  /// 获取字符串的 MD5 计算结果
  static String toMd5HexString(String source) {
    final hash = md5.convert(utf8.encode(source));
    return hash.toString();
  }
}
