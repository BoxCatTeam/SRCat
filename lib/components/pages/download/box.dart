/// ===========================================================================
/// Copyright (c) 2020-2023, BoxCat. All rights reserved.
/// Date: 2023-05-15 00:36:05
/// LastEditTime: 2023-05-15 01:08:28
/// FilePath: /lib/components/pages/download/box.dart
/// ===========================================================================

import 'package:fluent_ui/fluent_ui.dart';
import 'package:srcat/components/global/scroll/normal.dart';

import 'item.dart';

class DownloadListBox extends StatefulWidget {
  const DownloadListBox({
    Key? key,
    required this.items
  }) : super(key: key);

  /// 下载列表
  final List<DownloadListItem>? items;

  @override
  State<DownloadListBox> createState() => _DownloadListBoxState();
}

class _DownloadListBoxState extends State<DownloadListBox> {
  @override
  Widget build(BuildContext context) {
    return ConstrainedBox(
      constraints: const BoxConstraints(
        maxHeight: 300,
        minHeight: 80
      ),
      child: SRCatNormalScroll(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: widget.items ?? [],
        ),
      )
    );
  }
}
