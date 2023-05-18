/// ===========================================================================
/// Copyright (c) 2020-2023, BoxCat. All rights reserved.
/// Date: 2023-05-07 03:29:02
/// LastEditTime: 2023-05-13 17:16:58
/// FilePath: /lib/components/global/scroll/normal.dart
/// ===========================================================================

import 'package:dyn_mouse_scroll/dyn_mouse_scroll.dart';
import 'package:fluent_ui/fluent_ui.dart';

/// 普通的滚动容器
class SRCatNormalScroll extends StatefulWidget {
  const SRCatNormalScroll({
    Key? key,
    required this.child,
    this.physics,
    this.controller,
    this.defaultPhysics = true,
    this.hiddenBar = false,
    this.useDynScroll = true,
  }) : super(key: key);

  /// 子容器
  final Widget child;

  /// 滚动效果
  final ScrollPhysics? physics;

  /// 滑动控制器
  final ScrollController? controller;

  /// 是否使用默认的滚动效果
  final bool defaultPhysics;

  /// 是否隐藏滚动条
  final bool hiddenBar;

  /// 是否启用平滑滚动
  final bool useDynScroll;

  @override
  State<SRCatNormalScroll> createState() => _SRCatNormalScrollState();
}

class _SRCatNormalScrollState extends State<SRCatNormalScroll> {
  final defaultScrollController = ScrollController();
  
  @override
  Widget build(BuildContext context) {
    Widget scroll = SingleChildScrollView(
      key: widget.key,
      controller: widget.controller ?? defaultScrollController,
      physics: widget.physics ??
            (widget.defaultPhysics == true
                ? const BouncingScrollPhysics(
                    parent: AlwaysScrollableScrollPhysics())
                : null),
      child: widget.child,
    );

    Widget dynScroll = DynMouseScroll(
      builder: (context, controller, physics) => SingleChildScrollView(
        physics: physics,
        controller: controller,
        child: widget.child,
      )
    );

    return widget.hiddenBar ? ScrollConfiguration(
      behavior: ScrollConfiguration.of(context).copyWith(scrollbars: false),
      child: widget.useDynScroll ? dynScroll :scroll
    ) : widget.useDynScroll ? dynScroll :scroll;
  }
}