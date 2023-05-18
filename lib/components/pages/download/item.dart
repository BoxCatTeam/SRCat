/// ===========================================================================
/// Copyright (c) 2020-2023, BoxCat. All rights reserved.
/// Date: 2023-05-15 00:39:26
/// LastEditTime: 2023-05-15 01:53:43
/// FilePath: /lib/components/pages/download/item.dart
/// ===========================================================================

import 'package:fluent_ui/fluent_ui.dart';

class DownloadListItem extends StatefulWidget {
  const DownloadListItem({
    Key? key,
    required this.title,
    required this.progress,
    required this.progressText,
    this.hidden = false
  }) : super(key: key);

  /// 标题
  final String title;

  /// 下载进度
  final double progress;

  /// 进度显示文字
  final String progressText;

  /// 是否隐藏
  final bool hidden;

  @override
  State<DownloadListItem> createState() => _DownloadListItemState();
}

class _DownloadListItemState extends State<DownloadListItem> with SingleTickerProviderStateMixin {
  Widget _title() {
    return Text(widget.title, style: const TextStyle(
      fontSize: 18
    ));
  }

  Widget _progress() {
    Widget progress = ProgressBar(value: widget.progress);
    Widget progressText = Text(widget.progressText);
    
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: <Widget>[
        SizedBox(width: double.infinity, child: Row(
          mainAxisAlignment: MainAxisAlignment.end,
          children: [progressText],
        )),
        SizedBox(width: double.infinity, child: progress)
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    Duration duration = const Duration(milliseconds: 200);
    
    Widget card = Card(
      padding: EdgeInsets.zero,
      child: Padding(
        padding: const EdgeInsets.only(left: 15, right: 15, top: 5, bottom: 15),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[_title(),_progress(),],
        )
      )
    );

    return AnimatedContainer(
      height: widget.hidden ? 0 : 80,
      duration: duration,
      width: double.infinity,
      constraints: const BoxConstraints(
        maxHeight: 80
      ),
      child: AnimatedOpacity(
        opacity: widget.hidden ? 0 : 1,
        duration: duration,
        child: SingleChildScrollView(
          physics: const NeverScrollableScrollPhysics(parent: AlwaysScrollableScrollPhysics()),
          child: card
        ),
      ),
    );
  }
}
