/// ===========================================================================
/// Copyright (c) 2020-2023, BoxCat. All rights reserved.
/// Date: 2023-05-09 04:37:39
/// LastEditTime: 2023-05-16 04:22:30
/// FilePath: /lib/components/pages/app/tools/game/launch/accounts_selector.dart
/// ===========================================================================

import 'package:fluent_ui/fluent_ui.dart';

class GameLaunchAccountsSelector extends StatefulWidget {
  const GameLaunchAccountsSelector({
    Key? key,
    required this.selectedIndex,
    required this.items,
    required this.onChanged,
    required this.renameAction,
    required this.deleteAction,
  }) : super(key: key);

  /// 当前选中的索引
  final int? selectedIndex;

  /// 子项
  final List<GameLaunchAccountsSelectorItem> items;

  /// 点击事件
  final Function(int index) onChanged;

  /// 重命名事件
  final Function(int index) renameAction;

  /// 删除事件
  final Function(int index) deleteAction;

  @override
  State<GameLaunchAccountsSelector> createState() => _GameLaunchAccountsSelectorState();
}

class _GameLaunchAccountsSelectorState extends State<GameLaunchAccountsSelector> {
  int? _selectedIndex;

  @override
  void initState() {
    super.initState();
  }

  @override
  void didUpdateWidget(GameLaunchAccountsSelector oldWidget) {
    super.didUpdateWidget(oldWidget);
    
    if (_selectedIndex != widget.selectedIndex) {
      _selectedIndex = widget.selectedIndex;
    }
  }

  @override
  Widget build(BuildContext context) {
    List<Widget> list = [];

    for (var key = 0; key < widget.items.length; key++) {
      onPressed() {
        setState(() {
          _selectedIndex = key;
        });
        widget.onChanged(key);
      }

      Widget actions = Row(
        children: [
          IconButton(
            icon: const Icon(FluentIcons.rename),
            onPressed: () => widget.renameAction(key),
          ),
          const SizedBox(width: 5),
          IconButton(
            icon: const Icon(FluentIcons.delete, color: Color(0xffef5350)),
            onPressed: () => widget.deleteAction(key),
          ),
        ],
      );

      Widget itemBox = Row(
        children: <Widget> [
          SizedBox(
            height: 15,
            width: 3,
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                AnimatedContainer(
                  height: key == _selectedIndex ? 15 : 0,
                  width: double.infinity,
                  duration: FluentTheme.of(context).fasterAnimationDuration,
                  decoration: BoxDecoration(
                    color: FluentTheme.of(context).accentColor,
                    borderRadius: BorderRadius.circular(3.0),
                  ),
                )
              ]
            ),
          ),
          Expanded(child: widget.items[key])
        ]
      );
      
      list.add(HoverButton(
        onPressed: onPressed,
        cursor: SystemMouseCursors.click,
        builder: (context, states) {
          Widget child = AnimatedContainer(
            width: double.infinity,
            duration: FluentTheme.of(context).fasterAnimationDuration,
            decoration: BoxDecoration(
              color: ButtonThemeData.uncheckedInputColor(
                FluentTheme.of(context),
                states,
                transparentWhenNone: true,
              ),
              borderRadius: BorderRadius.circular(4.0),
            ),
            child: AnimatedContainer(
              duration: FluentTheme.of(context).fasterAnimationDuration,
              color: key == _selectedIndex ?
                FluentTheme.of(context).resources.subtleFillColorTertiary
                : Colors.transparent,
              child: Stack(
                children: [
                  itemBox,
                  Positioned(
                    right: 15,
                    top: 0,
                    bottom: 0,
                    child: AnimatedOpacity(
                      opacity: states.isHovering ? 1.0 : 0.0,
                      duration: FluentTheme.of(context).fasterAnimationDuration,
                      child: actions,
                    ),
                  )
                ]
              ),
            ),
          );
          return FocusBorder(
            focused: states.isFocused,
            renderOutside: false,
            child: RepaintBoundary(
              child: child
            )
          );
        }
      ));
    }

    Widget card = Card(
      padding: EdgeInsets.zero,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: list,
      ),
    );

    return SizedBox(width: double.infinity, child: card);
  }
}

class GameLaunchAccountsSelectorItem extends StatefulWidget {
  const GameLaunchAccountsSelectorItem({
    Key? key,
    required this.uid,
    required this.uuid,
    required this.nickname,
    required this.sdkey,
  }) : super(key: key);

  /// UID
  final int? uid;

  /// UUID
  final String uuid;

  /// 昵称
  final String nickname;

  /// MiHoYo SDKey
  final String sdkey;

  @override
  State<GameLaunchAccountsSelectorItem> createState() => _GameLaunchAccountsSelectorItemState();
}

class _GameLaunchAccountsSelectorItemState extends State<GameLaunchAccountsSelectorItem> {
  Widget _nickname() {
    return Text(widget.nickname, style: const TextStyle(fontSize: 14));
  }

  @override
  Widget build(BuildContext context) {
    Widget title = Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[_nickname()],
    );


    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 15, vertical: 15),
      child: title
    );
  }
}
