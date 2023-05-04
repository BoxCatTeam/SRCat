/// 全局主题状态管理
/// ===========================================================================
/// Copyright (c) 2020-2023, BoxCat. All rights reserved.
/// Date: 2023-05-04 23:56:53
/// LastEditTime: 2023-05-05 00:05:47
/// FilePath: /lib/riverpod/global/theme.dart
/// ===========================================================================

import 'package:srcat/config/settings.dart';
import 'package:srcat/utils/settings/main.dart';
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
    "theme": SCSettingsUtils.get(SCSettingsSPKey.theme) is String ? SCSettingsUtils.get(SCSettingsSPKey.theme) : "auto",
    "material": SCSettingsUtils.get(SCSettingsSPKey.material) is String ? SCSettingsUtils.get(SCSettingsSPKey.material) : "mica"
  });
});
