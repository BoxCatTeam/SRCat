/// 全局弹窗管理
/// ===========================================================================
/// Copyright (c) 2020-2023, BoxCat. All rights reserved.
/// Date: 2023-05-05 08:14:18
/// LastEditTime: 2023-05-06 00:44:20
/// FilePath: /lib/riverpod/global/dialog.dart
/// ===========================================================================

import 'package:fluent_ui/fluent_ui.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class GlobalDialogRiverpod extends ChangeNotifier {
  bool _isShow = false;
  bool get isShow => _isShow;

  String _title = "提示";
  String get title => _title;

  double _titleSize = 20;
  double get titleSize => _titleSize;

  Widget? _child;
  Widget? get child => _child;

  List<Widget>? _actions;
  List<Widget>? get actions => _actions;

  GlobalDialogRiverpod show() {
    _isShow = true;
    notifyListeners();
    return this;
  }

  GlobalDialogRiverpod set(String title, {
    double? titleSize,
    Widget? child,
    List<Widget>? actions,
    bool cacheActions = true
  }) {
    _title = title;
    _child = child ?? _child;
    _titleSize = titleSize ?? 20;
    _actions = cacheActions ? actions ?? _actions : null;
    
    notifyListeners();
    return this;
  }

  GlobalDialogRiverpod hidden() {
    _isShow = false;

    notifyListeners();
    return this;
  }

  GlobalDialogRiverpod clean() {
    _isShow = false;
    _title = "";
    _child = null;
    _actions = [];

    notifyListeners();
    return this;
  }
}

final globalDialogRiverpod = ChangeNotifierProvider((ref) =>GlobalDialogRiverpod());
