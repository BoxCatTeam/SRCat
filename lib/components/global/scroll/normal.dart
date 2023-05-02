/// 普通的滚动容器
/// ===========================================================================
/// Copyright (c) 2020-2023, BoxCat. All rights reserved.
/// Date: 2023-04-28 23:46:19
/// LastEditTime: 2023-05-02 19:37:08
/// FilePath: /lib/components/global/scroll/normal.dart
/// ===========================================================================

import 'package:fluent_ui/fluent_ui.dart';

class SCNormalScroll extends StatefulWidget {
  const SCNormalScroll({
    Key? key,
    required this.child,
    this.physics,
    this.controller,
    this.defaultPhysics = true,
    this.hiddenBar = false,
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

  @override
  State<SCNormalScroll> createState() => _SCNormalScrollState();
}

class _SCNormalScrollState extends State<SCNormalScroll> {
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

    return widget.hiddenBar ? ScrollConfiguration(
      behavior: ScrollConfiguration.of(context).copyWith(scrollbars: false),
      child: scroll
    ) : scroll;
  }
}
