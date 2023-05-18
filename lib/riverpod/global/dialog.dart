/// ===========================================================================
/// Copyright (c) 2020-2023, BoxCat. All rights reserved.
/// Date: 2023-05-07 02:44:33
/// LastEditTime: 2023-05-07 03:18:50
/// FilePath: /lib/riverpod/global/dialog.dart
/// ===========================================================================

import 'package:srcat/application.dart';
import 'package:fluent_ui/fluent_ui.dart';
import 'package:flutter_i18n/flutter_i18n.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

/// 全局弹窗管理
class GlobalDialogRiverpod extends ChangeNotifier {
  /// 是否显示弹窗
  bool _isShow = false;
  bool get isShow => _isShow;

  /// 弹窗标题
  String _title = FlutterI18n.translate(Application.rootNavigatorKey.currentContext!, "global.dialog.defaultTitle");
  String get title => _title;

  /// 弹窗标题大小
  double _titleSize = 20;
  double get titleSize => _titleSize;

  /// 子组件
  Widget? _child;
  Widget? get child => _child;

  /// 操作按钮
  List<Widget>? _actions;
  List<Widget>? get actions => _actions;

  /// 显示弹窗
  GlobalDialogRiverpod show() {
    _isShow = true;
    
    notifyListeners();
    return this;
  }

  /// 设置弹窗
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

  /// 隐藏弹窗
  GlobalDialogRiverpod hidden() {
    _isShow = false;

    notifyListeners();
    return this;
  }

  /// 清空弹窗
  GlobalDialogRiverpod clean() {
    _isShow = false;
    _title = "";
    _child = null;
    _actions = [];

    notifyListeners();
    return this;
  }
}

final globalDialogRiverpod = ChangeNotifierProvider((ref) => GlobalDialogRiverpod());
