/// ===========================================================================
/// Copyright (c) 2020-2023, BoxCat. All rights reserved.
/// Date: 2023-05-14 12:25:14
/// LastEditTime: 2023-05-15 09:06:47
/// FilePath: /lib/riverpod/pages/download.dart
/// ===========================================================================

import 'package:fluent_ui/fluent_ui.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:srcat/models/pages/download/metadata_list.dart';
export 'package:srcat/models/pages/download/metadata_list.dart';

/// 元数据下载页面 状态管理
class DownloadRiverpod extends ChangeNotifier {
  Map<String, DownloadMetadataListModel> _list = {};
  Map<String, DownloadMetadataListModel> get list => _list;

  Map<String, bool> _downloadState = {};
  Map<String, bool> get downloadState => _downloadState;

  /// 修改下载状态
  changeList(String item, {
    double? progress,
    String? progressText,
    bool? hidden,
  }) {
    if (_list[item] == null) return;

    _list[item] = DownloadMetadataListModel.fromJson({
      "title": _list[item]!.toJson()["title"],
      "progress": progress ?? _list["item"]!.toJson()["progress"],
      "progressText": progressText ?? _list["item"]!.toJson()["progressText"],
      "hidden": hidden ?? _list["item"]!.toJson()["hidden"]
    });
    notifyListeners();
  }

  /// 初始化下载列表
  initList(Map<String, dynamic> downloadList) {
    _list = {};
    _downloadState = {};
    downloadList.forEach((title, data) {
      _list[title] = DownloadMetadataListModel.fromJson({
        "title": data["title"],
        "progress": data["progress"],
        "progressText": data["progressText"],
        "hidden": data["hidden"]
      });
      _downloadState[title] = false;
    });
    notifyListeners();
  }

  /// 修改下载状态
  changeDownloadState(String name, bool isComplete) {
    _downloadState[name] = isComplete;
    notifyListeners();
  }
}

final downloadRiverpod = ChangeNotifierProvider((ref) => DownloadRiverpod());
