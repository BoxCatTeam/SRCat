/// ===========================================================================
/// Copyright (c) 2020-2023, BoxCat. All rights reserved.
/// Date: 2023-05-07 03:55:45
/// LastEditTime: 2023-05-07 04:01:11
/// FilePath: /lib/components/global/scroll/page.dart
/// ===========================================================================

import 'package:fluent_ui/fluent_ui.dart';
import 'package:srcat/components/global/scroll/normal.dart';

class SRCatPageScroll extends StatefulWidget {
  const SRCatPageScroll({
    Key? key,
    this.header,
    required this.child,
    this.scrollController,
    this.padding,
  }) : super(key: key);

  /// Header
  final Widget? header;

  /// 子组件
  final Widget child;

  /// 滚动控制器
  final ScrollController? scrollController;

  /// 内边距
  final EdgeInsets? padding;

  @override
  State<SRCatPageScroll> createState() => _SRCatPageScrollState();
}

class _SRCatPageScrollState extends State<SRCatPageScroll> {
  final scrollController = ScrollController();
  
  @override
  Widget build(BuildContext context) {
    return ScaffoldPage(
      key: const PageStorageKey(-1),
      padding: widget.padding,
      header: widget.header,
      content: SizedBox.expand(child: SRCatNormalScroll(
        controller: widget.scrollController ?? scrollController,
        child: widget.child,
      )),
    );
  }
}
