/// ===========================================================================
/// Copyright (c) 2020-2023, BoxCat. All rights reserved.
/// Date: 2023-05-07 03:31:28
/// LastEditTime: 2023-05-24 19:31:19
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
    this.small = false,
    this.backgroundClear = false,
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

  /// mini
  final bool small;

  /// 背景颜色是否透明
  final bool backgroundClear;

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
      style: TextStyle(
        fontSize: widget.small ? 13 : 15,
      ),
      overflow: TextOverflow.ellipsis,
      maxLines: 1,
    );

    Widget description = widget.description != null ? Text(
      widget.description!,
      style: TextStyle(
        fontSize: widget.small ? 10 : 12,
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
        if (widget.icon != null) SizedBox(width: widget.small ? 10 : 18),
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
          padding: EdgeInsets.symmetric(
            vertical: widget.small ? 8 : 10,
            horizontal: widget.small ? 10 : 15
          ),
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
              backgroundColor: widget.backgroundClear ? Colors.transparent : null,
              borderColor: widget.backgroundClear ? Colors.transparent : null,
              margin: widget.margin,
              child: ac
            )
          )
        );
      },
    );
  }
}
