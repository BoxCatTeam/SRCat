/// ===========================================================================
/// Copyright (c) 2020-2023, BoxCat. All rights reserved.
/// Date: 2023-05-09 01:02:24
/// LastEditTime: 2023-05-09 01:02:40
/// FilePath: /lib/riverpod/global/theme.dart
/// ===========================================================================

import 'package:srcat/utils/settings.dart';
import 'package:srcat/config/settings.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class GlobalThemeRiverpod extends StateNotifier<Map<String, dynamic>> {
  GlobalThemeRiverpod (Map<String, dynamic> data) : super(data);

  void setMaterial(String material) {
    state = {
      ...state,
      "material": material
    };
  }

  void setTheme(String theme) {
    state = {
      ...state,
      "theme": theme
    };
  }
}

final themeRiverpod = StateNotifierProvider<GlobalThemeRiverpod, Map<String, dynamic>>((ref) {
  return GlobalThemeRiverpod({
    "theme": SRCatSettingsUtils.get(SRCatSettingsKey.theme) is String ? SRCatSettingsUtils.get(SRCatSettingsKey.theme) : "auto",
    "material": SRCatSettingsUtils.get(SRCatSettingsKey.material) is String ? SRCatSettingsUtils.get(SRCatSettingsKey.material) : "default"
  });
});
