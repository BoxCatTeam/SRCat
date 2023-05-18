/// ===========================================================================
/// Copyright (c) 2020-2023, BoxCat. All rights reserved.
/// Date: 2023-05-07 03:31:28
/// LastEditTime: 2023-05-18 07:18:33
/// FilePath: /lib/components/global/card/item.dart
/// ===========================================================================

import 'package:fluent_ui/fluent_ui.dart';
import 'package:srcat/components/global/icon/main.dart';

/// 卡片组件
class SRCatCard extends StatefulWidget {
  const SRCatCard({
    Key? key,
    this.icon,
    this.iconSize = 20,
    this.iconWeight = FontWeight.w600,
    required this.title,
    this.description,
    this.rightChild,
    this.margin,
    this.onTap,
  }) : super(key: key);

  /// 图标
  final IconData? icon;

  /// 图标大小
  final double iconSize;

  /// 图标字号
  final FontWeight iconWeight;

  /// 标题
  final String title;

  /// 介绍/简介
  final String? description;

  /// 右侧组件
  final Widget? rightChild;

  /// 外边距
  final EdgeInsets? margin;

  /// 点击回调
  final void Function()? onTap;

  @override
  State<SRCatCard> createState() => _SRCatCardState();
}

class _SRCatCardState extends State<SRCatCard> {
  Widget _icon() {
    return SRCatIcon(
      widget.icon!,
      size: widget.iconSize,
      weight: widget.iconWeight,
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
    ) : Container();

    return Expanded(child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: <Widget>[title, description],
    ));
  }

  @override
  Widget build(BuildContext context) {
    Widget child = Row(
      children: <Widget>[
        if (widget.icon != null) _icon(),
        if (widget.icon != null) const SizedBox(width: 18),
        _text(),
        if (widget.rightChild != null) const SizedBox(width: 5),
        if (widget.rightChild != null) widget.rightChild!
      ],
    );

    return HoverButton(
      onPressed: widget.onTap,
      cursor: widget.onTap != null ? SystemMouseCursors.click : SystemMouseCursors.disappearing,
      builder: (context, states) {
        Widget ac = AnimatedContainer(
          duration: FluentTheme.of(context).fasterAnimationDuration,
          padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 15),
          decoration: BoxDecoration(
            color: ButtonThemeData.uncheckedInputColor(
              FluentTheme.of(context),
              states,
              transparentWhenNone: true,
            ),
            borderRadius: BorderRadius.circular(4.0),
          ),
          child: child,
        );

        return FocusBorder(
          focused: states.isFocused,
          renderOutside: false,
          child: RepaintBoundary(
            child: Card(
              padding: EdgeInsets.zero,
              margin: widget.margin,
              child: ac
            )
          )
        );
      },
    );
  }
}
