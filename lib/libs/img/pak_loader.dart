/// ===========================================================================
/// Copyright (c) 2020-2023, BoxCat. All rights reserved.
/// Date: 2023-04-29 09:26:07
/// LastEditTime: 2023-05-02 00:57:20
/// FilePath: /lib/libs/img/pak_loader.dart
/// ===========================================================================

export "srcat_pack.dart";

class SRCatPackLoader {
  static const String _basePath = "assets/images";
  static const String _pack = "/hidden-pack";
  static const String _magicPath = _basePath + _pack;
  static const String _magicAfter = "srcat-img";

  static String parse(String packFile) {
    return "$_magicPath/$packFile.$_magicAfter";
  }
}
