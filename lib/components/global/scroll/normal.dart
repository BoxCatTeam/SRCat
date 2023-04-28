/// 普通的滚动容器
/// ===========================================================================
/// Copyright (c) 2020-2023, BoxCat. All rights reserved.
/// Date: 2023-04-28 23:46:19
/// LastEditTime: 2023-04-28 23:51:40
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
  }) : super(key: key);

  /// 子容器
  final Widget child;

  /// 滚动效果
  final ScrollPhysics? physics;

  /// 滑动控制器
  final ScrollController? controller;

  /// 是否使用默认的滚动效果
  final bool defaultPhysics;

  @override
  State<SCNormalScroll> createState() => _SCNormalScrollState();
}

class _SCNormalScrollState extends State<SCNormalScroll> {
  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      key: widget.key,
      physics: widget.physics ??
            (widget.defaultPhysics == true
                ? const BouncingScrollPhysics(
                    parent: AlwaysScrollableScrollPhysics())
                : null),
      child: widget.child,
    );
  }
}
