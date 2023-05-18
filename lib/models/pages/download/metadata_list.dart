/// ===========================================================================
/// Copyright (c) 2020-2023, BoxCat. All rights reserved.
/// Date: 2023-05-15 06:05:55
/// LastEditTime: 2023-05-15 06:14:43
/// FilePath: /lib/models/pages/download/metadata.dart
/// ===========================================================================

/// 元数据下载页面列表模型
class DownloadMetadataListModel {
  /// 下载任务标题
  final String title;

  /// 下载进度
  final double progress;

  /// 下载进度提示文字
  final String progressText;

  /// 是否已经下载完成并且可以隐藏
  final bool hidden;

  DownloadMetadataListModel(
      {required this.title,
      required this.progress,
      required this.progressText,
      required this.hidden});

  DownloadMetadataListModel.fromJson(Map<String, dynamic> data)
      : title = data["title"] as String,
        progress = data["progress"] as double,
        progressText = data["progressText"] as String,
        hidden = data["hidden"] as bool;

  Map<String, dynamic> toJson() => <String, dynamic>{
        "title": title,
        "progress": progress,
        "progressText": progressText,
        "hidden": hidden
      };
}
