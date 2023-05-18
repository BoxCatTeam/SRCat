/// ===========================================================================
/// Copyright (c) 2020-2023, BoxCat. All rights reserved.
/// Date: 2023-05-09 07:36:31
/// LastEditTime: 2023-05-16 04:24:18
/// FilePath: /lib/riverpod/pages/tools/game/launch.dart
/// ===========================================================================

import 'package:fluent_ui/fluent_ui.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class GameLaunchPageRiverpod extends ChangeNotifier {
  String? _newAccNickname;
  String? get newAccNickname => _newAccNickname;

  String? _reAccNickname;
  String? get reAccNickname => _reAccNickname;

  int? processId;
  int? get getProcessId => processId;

  void setNewAccNickname(String? nickname) {
    _newAccNickname = nickname;
    notifyListeners();
  }

  void setAccNewNickname(String? nickname) {
    _reAccNickname = nickname;
    notifyListeners();
  }

  void setProcessId(int? id) {
    processId = id;
    notifyListeners();
  }
}

final gameLaunchPageRiverpod = ChangeNotifierProvider((ref) => GameLaunchPageRiverpod());
