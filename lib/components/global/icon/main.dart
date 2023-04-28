/// 自定义图标组件
/// ===========================================================================
/// Copyright (c) 2020-2023, BoxCat. All rights reserved.
/// Date: 2023-04-28 22:28:11
/// LastEditTime: 2023-04-29 01:41:26
/// FilePath: /lib/components/global/icon/main.dart
/// ===========================================================================

import 'package:fluent_ui/fluent_ui.dart';

class SCIcon extends StatefulWidget {
  const SCIcon(this.icon, {
    Key? key,
    this.size,
    this.color,
    this.weight,
  }) : super(key: key);

  /// 图标
  final IconData icon;

  /// 图标大小
  final double? size;

  /// 图标颜色
  final Color? color;

  /// 图标粗细
  final FontWeight? weight;

  @override
  State<SCIcon> createState() => _SCIconState();
}

class _SCIconState extends State<SCIcon> {
  @override
  Widget build(BuildContext context) {
    return Text(
      String.fromCharCode(widget.icon.codePoint),
      style: TextStyle(
        fontSize: widget.size ?? 19,
        fontWeight: widget.weight ?? FontWeight.w500,
        fontFamily: widget.icon.fontFamily,
        package: widget.icon.fontPackage,
        color: widget.color
      )
    );
  }
}
