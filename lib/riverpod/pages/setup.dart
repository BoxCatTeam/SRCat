/// ===========================================================================
/// Copyright (c) 2020-2023, BoxCat. All rights reserved.
/// Date: 2023-05-08 05:47:14
/// LastEditTime: 2023-05-08 22:23:57
/// FilePath: /lib/riverpod/pages/setup.dart
/// ===========================================================================

import 'package:fluent_ui/fluent_ui.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

/// 设置向导页面 状态管理
class SetupPageRiverpod extends ChangeNotifier {
  bool _hideSetup1 = false;
  bool get hideSetup1 => _hideSetup1;
  bool _hideSetup2 = true;
  bool get hideSetup2 => _hideSetup2;
  bool _hideSetup3 = true;
  bool get hideSetup3 => _hideSetup3;
  bool _hideSetup4 = true;
  bool get hideSetup4 => _hideSetup4;

  int _contentBox = 0;
  int get contentBox => _contentBox;

  bool _setup1CanNext = true;
  bool get setup1CanNext => _setup1CanNext;
  bool _setup2CanNext = false;
  bool get setup2CanNext => _setup2CanNext;
  bool _setup3CanNext = false;
  bool get setup3CanNext => _setup3CanNext;

  String? _gamePath;
  String? get gamePath => _gamePath;

  String? _filePath;
  String? get filePath => _filePath;

  bool _setup2Loading = false;
  bool get setup2Loading => _setup2Loading;

  bool _hasWebView2 = false;
  bool get hasWebView2 => _hasWebView2;
  bool _checkedWebView2 = false;
  bool get checkedWebView2 => _checkedWebView2;

  void hiddenSetup(int setup) {
    switch (setup) {
      case 1:
        _hideSetup1 = true;
        break;
      case 2:
        _hideSetup2 = true;
        break;
      case 3:
        _hideSetup3 = true;
        break;
      case 4:
        _hideSetup4 = true;
        break;
    }

    notifyListeners();
  }

  void showSetup(int setup) {
    switch (setup) {
      case 1:
        _hideSetup1 = false;
        break;
      case 2:
        _hideSetup2 = false;
        break;
      case 3:
        _hideSetup3 = false;
        break;
      case 4:
        _hideSetup4 = false;
        break;
    }

    notifyListeners();
  }

  void changeContentBox(int contentBox) {
    _contentBox = contentBox;
    notifyListeners();
  }

  void changeSetup1CanNext(bool setup1CanNext) {
    _setup1CanNext = setup1CanNext;
    notifyListeners();
  }

  void changeSetup2CanNext(bool setup2CanNext) {
    _setup2CanNext = setup2CanNext;
    notifyListeners();
  }

  void changeSetup3CanNext(bool setup3CanNext) {
    _setup3CanNext = setup3CanNext;
    notifyListeners();
  }

  void setGamePath(String gamePath) {
    _gamePath = gamePath;
    notifyListeners();
  }

  void setFilePath(String filePath) {
    _filePath = filePath;
    notifyListeners();
  }

  void changeSetup2Loading(bool setup2Loading) {
    _setup2Loading = setup2Loading;
    notifyListeners();
  }

  void changeHasWebView2(bool hasWebView2) {
    _hasWebView2 = hasWebView2;
    notifyListeners();
  }

  void setCheckedWebView2() {
    _checkedWebView2 = true;
    notifyListeners();
  }
}

final setupPageRiverpod = ChangeNotifierProvider((ref) => SetupPageRiverpod());
