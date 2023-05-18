/// ===========================================================================
/// Copyright (c) 2020-2023, BoxCat. All rights reserved.
/// Date: 2023-05-07 03:30:09
/// LastEditTime: 2023-05-07 03:30:17
/// FilePath: /lib/components/global/icon/main.dart
/// ===========================================================================

import 'package:fluent_ui/fluent_ui.dart';

/// 自定义图标组件
class SRCatIcon extends StatefulWidget {
  const SRCatIcon(this.icon, {
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
  State<SRCatIcon> createState() => _SRCatIconState();
}

class _SRCatIconState extends State<SRCatIcon> {
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