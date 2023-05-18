/// ===========================================================================
/// Copyright (c) 2020-2023, BoxCat. All rights reserved.
/// Date: 2023-05-18 15:28:14
/// LastEditTime: 2023-05-18 16:16:00
/// FilePath: /lib/riverpod/pages/settings.dart
/// ===========================================================================

import 'package:fluent_ui/fluent_ui.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

/// 设置页面状态管理
class SettingsRiverpod extends ChangeNotifier {
  bool _isCheckingUpdate = false;
  bool get isCheckingUpdate => _isCheckingUpdate;

  void changeCheckUpdateStatus(bool status) {
    _isCheckingUpdate = status;
    notifyListeners();
  } 
}

final settingsRiverpod = ChangeNotifierProvider((ref) => SettingsRiverpod());
