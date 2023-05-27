/// ===========================================================================
/// Copyright (c) 2020-2023, BoxCat. All rights reserved.
/// Date: 2023-05-27 12:03:32
/// LastEditTime: 2023-05-27 13:42:53
/// FilePath: /lib/libs/hoyolab/dynamic_secret/main.dart
/// ===========================================================================

import 'dart:math';

export 'version.dart';
export "salt_type.dart";

import 'version.dart';
import 'salt_type.dart';
import 'package:srcat/config/hoyolab.dart';
import 'package:srcat/utils/main.dart';

class HoYoLabDynamicSecretLib {
  final HoYoLabDynamicSecretVersion version;
  final HoYoLabDynamicSecretSaltType saltType;
  final bool includeChars;

  HoYoLabDynamicSecretLib({
    required this.version,
    required this.saltType,
    required this.includeChars
  });

  final String _randStrRanges = "abcdefghijklmnopqrstuvwxyz1234567890";

  String get defaultBody => saltType == HoYoLabDynamicSecretSaltType.prod ? "{}" : "";

  String get randStr => includeChars ? _randStrWithChars() : _randStrNoChars();

  String _randStrWithChars() {
    final random = Random();
    final strbuffer = StringBuffer();

    for (var i = 0; i < 6; i++) {
      int pos = random.nextInt(_randStrRanges.length);
      strbuffer.write(_randStrRanges[pos]);
    }

    return strbuffer.toString();
  }

  String _randStrNoChars() {
    final rand = Random().nextInt(100000) + 100000;
    return rand == 100000 ? '642367' : rand.toString();
  }

  /// 生成 DS
  String generated({
    dynamic content,
    required String url
  }) {
    String salt = HoYoLabConfig.salts(saltType);
    int timestamp = SRCatUtils.getUnixTime();
    String randString = randStr;

    String dsContent = "salt=$salt&t=$timestamp&r=$randString";

    if (version == HoYoLabDynamicSecretVersion.v2) {
      String b = content != null ? content.toString() : defaultBody.toString();
      List<String> queries = Uri.decodeFull(url).split("?");
      final q = queries.length == 2 ? (() {
        List<String> list = queries[1].split('&');
        list.sort();
        return list;
      })() : [];

      dsContent = "$dsContent&b=$b&q=${q.join('&')}";
    }

    String check = SRCatUtils.toMd5HexString(dsContent).toString();

    return "$timestamp,$randStr,$check";
  }
}
