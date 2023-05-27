/// ===========================================================================
/// Copyright (c) 2020-2023, BoxCat. All rights reserved.
/// Date: 2023-05-27 16:20:11
/// LastEditTime: 2023-05-28 00:45:45
/// FilePath: /lib/components/pages/app/root/components/user_item.dart
/// ===========================================================================

import 'package:fluent_ui/fluent_ui.dart';
import 'package:srcat/application.dart';

import 'components/role.dart';

class AppUserItemWidget extends StatefulWidget {
  const AppUserItemWidget({
    Key? key,
    required this.id,
    required this.nickname,
    required this.avatar,
    required this.roleList,
    required this.isSelect,
    required this.onPressed,
    required this.onDelete,
    required this.onCopyCookie,
  }) : super(key: key);

  /// ID
  final String id;

  /// 昵称
  final String nickname;

  /// 头像
  final String avatar;

  /// 角色信息
  final List<Map<String, dynamic>> roleList;

  /// 当前是否选中
  final bool isSelect;

  /// 点击事件
  final void Function(String id) onPressed;

  /// 删除回调函数
  final void Function(String id) onDelete;

  /// 复制 Cookie 回调函数
  final void Function(Future<String> cookie) onCopyCookie;

  @override
  State<AppUserItemWidget> createState() => _AppUserBoxWidgetState();
}

class _AppUserBoxWidgetState extends State<AppUserItemWidget> {
  final contextAttachKey = GlobalKey();
  final menuController = FlyoutController();
  
  @override
  void initState() {
    super.initState();
  }

  @override
  void dispose() {
    menuController.dispose();
    super.dispose();
  }

  Widget _actions() => Row(
    children: [
      IconButton(
        icon: const Icon(FluentIcons.delete, color: Color(0xffef5350)),
        onPressed: () => widget.onDelete(widget.id),
      ),
    ]
  );

  Widget _child() {
    String defaultAvatarPath = "assets/images/srcat/wuwu.png";
    Widget avatar = Container(
      width: 30,
      height: 30,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(100.0),
        image: widget.avatar != "" ? DecorationImage(
          image: NetworkImage(widget.avatar),
          fit: BoxFit.contain
        ) : DecorationImage(
          image: AssetImage(defaultAvatarPath),
          fit: BoxFit.contain
        )
      )
    );

    Widget nickname = Text(widget.nickname, maxLines: 1, overflow: TextOverflow.ellipsis);

    return Row(
      children: <Widget> [
        SizedBox(
          height: 15,
          width: 3,
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              AnimatedContainer(
                height: widget.isSelect ? 15 : 0,
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
        Expanded(child: Row(
          children: <Widget>[const SizedBox(width: 5), avatar, const SizedBox(width: 8), Expanded(child: nickname)],
        ))
      ]
    );
  }

  Widget _itemBox(Set<ButtonStates> states) => AnimatedContainer(
    height: 50,
    duration: FluentTheme.of(context).fasterAnimationDuration,
    color: widget.isSelect ? FluentTheme.of(context).resources.subtleFillColorTertiary : Colors.transparent,
    child: Stack(
      children: [
        SizedBox(
          height: double.infinity,
          child: _child(),
        ),
        Positioned(
          right: 5,
          top: 0,
          bottom: 0,
          child: AnimatedOpacity(
            opacity: states.isHovering ? 1.0 : 0.0,
            duration: FluentTheme.of(context).fasterAnimationDuration,
            child: _actions(),
          )
        )
      ]
    )
  );

  Widget _rolePanel() {
    Widget title = const Padding(
      padding: EdgeInsets.only(top: 10, left: 10, right: 10, bottom: 5),
      child: Text("角色"),
    );

    Widget panel = Container(
      width: 260,
      decoration: const BoxDecoration(
        borderRadius: BorderRadius.all(Radius.circular(6))
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          title,
          AppUserItemRoleWidget(roleList: widget.roleList),
          const SizedBox(height: 5)
        ]
      )
    );

    return Mica(
      borderRadius: const BorderRadius.all(Radius.circular(6)),
      child: panel
    );
  }

  @override
  Widget build(BuildContext context) {
    Widget hoverButton = HoverButton(
      onPressed: () {
        widget.onPressed(widget.id);
        menuController.showFlyout(
          navigatorKey: Application.rootNavigatorKey.currentState,
          placementMode: FlyoutPlacementMode.right,
          builder: (context) {
            return _rolePanel();
          }
        );
      },
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
          child: ClipRRect(
            borderRadius: BorderRadius.circular(4.0),
            child: _itemBox(states),
          )
        );

        return FocusBorder(
          focused: states.isFocused,
          renderOutside: false,
          child: RepaintBoundary(
            child: child
          )
        );
      }
    );

    return FlyoutTarget(
      key: contextAttachKey,
      controller: menuController,
      child: hoverButton,
    );
  }
}
