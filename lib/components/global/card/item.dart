/// Card
/// ===========================================================================
/// Copyright (c) 2020-2023, BoxCat. All rights reserved.
/// Date: 2023-04-29 00:25:27
/// LastEditTime: 2023-04-29 01:30:04
/// FilePath: /lib/components/global/card/item.dart
/// ===========================================================================

import 'package:fluent_ui/fluent_ui.dart';
import 'package:srcat/components/global/icon/main.dart';

class SCItemCard extends StatefulWidget {
  const SCItemCard({
    Key? key,
    this.icon,
    required this.title,
    this.description,
    this.rightChild,
    this.margin,
  }) : super(key: key);

  /// 图标
  final IconData? icon;

  /// 标题
  final String title;

  /// 介绍/简介
  final String? description;

  /// 右侧组件
  final Widget? rightChild;

  /// 外边距
  final EdgeInsets? margin;

  @override
  State<SCItemCard> createState() => _SCItemCardState();
}

class _SCItemCardState extends State<SCItemCard> {
  Widget _icon() {
    return SCIcon(
      widget.icon!,
      size: 20,
      weight: FontWeight.w600,
    );
  }

  Widget _text() {
    Widget title = Text(
      widget.title,
      style: const TextStyle(
        fontSize: 15,
      ),
      overflow: TextOverflow.ellipsis,
      maxLines: 1,
    );

    Widget description = widget.description != null ? Text(
      widget.description!,
      style: const TextStyle(
        fontSize: 12,
      ),
      overflow: TextOverflow.ellipsis,
      maxLines: 1,
    ) : Container();

    return Expanded(child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: <Widget>[title, description],
    ));
  }

  @override
  Widget build(BuildContext context) {
    return Card(
      padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 15),
      margin: widget.margin ?? const EdgeInsets.only(bottom: 3),
      child: Row(
        children: <Widget>[
          if (widget.icon != null) _icon(),
          if (widget.icon != null) const SizedBox(width: 18),
          _text(),
          if (widget.rightChild != null) widget.rightChild!
        ],
      )
    );
  }
}
