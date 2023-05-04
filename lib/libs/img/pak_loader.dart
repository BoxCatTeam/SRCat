/// ===========================================================================
/// Copyright (c) 2020-2023, BoxCat. All rights reserved.
/// Date: 2023-04-29 09:26:07
/// LastEditTime: 2023-05-04 22:29:41
/// FilePath: /lib/libs/img/pak_loader.dart
/// ===========================================================================

export "srcat_pack.dart";

enum SRCatPackLoaderImageType {
  normal,
  webp,
}

class SRCatPackLoader {
  static const String _basePath = "assets/images";
  static const String _pack = "/hidden-pack";
  static const String _magicPath = _basePath + _pack;

  static String parse(String packFile, {
    SRCatPackLoaderImageType type = SRCatPackLoaderImageType.normal
  }) {
    String after = "srcat-img";
    if (type == SRCatPackLoaderImageType.webp) after = "srcat-webp-img";
    if (type == SRCatPackLoaderImageType.normal) after = "srcat-img";
    return "$_magicPath/$packFile.$after";
  }
}
