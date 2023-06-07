/// ===========================================================================
/// Copyright (c) 2020-2023, BoxCat. All rights reserved.
/// Date: 2023-05-24 11:31:38
/// LastEditTime: 2023-06-07 21:30:08
/// FilePath: /lib/components/pages/app/root/user.dart
/// ===========================================================================

import 'package:fluent_ui/fluent_ui.dart';
import 'package:srcat/application.dart';
import 'package:srcat/libs/user/main.dart';
import 'package:srcat/components/global/card/item.dart';
import 'package:srcat/components/global/icon/main.dart';

import 'components/user_box.dart';

class AppUserWidget extends PaneItem {
  AppUserWidget({
    Key? key,
    required this.icon,
    required this.body,
    required this.nickname,
    required this.roleUid,
    required this.avatar
  }) : super(
    key: key,
    icon: icon,
    body: body
  );

  @override
  // ignore: overridden_fields
  final Widget icon;

  @override
  // ignore: overridden_fields
  final Widget body;

  final String nickname;
  final String roleUid;
  final String avatar;

  final contextAttachKey = GlobalKey();
  final contextController = FlyoutController();

  /// 头像
  Widget _avatar({ bool isMini = false }) {
    DecorationImage image;
    if (avatar != "") {
      image = DecorationImage(
        image: NetworkImage(avatar),
        fit: BoxFit.contain
      );
    } else {
      image = const DecorationImage(
        image: AssetImage("assets/images/srcat/wuwu.png"),
        fit: BoxFit.contain
      );
    }

    return Container(
      width: isMini ? 40 : 40,
      height: isMini ? 40 : 40,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(100.0),
        image: image
      )
    );
  }

  /// 昵称与 UID
  Widget _nicknameAndUid() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: <Widget>[
        Text(nickname,
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
        ),
        Text(roleUid,
          style: const TextStyle(fontSize: 12),
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
        )
      ],
    );
  }

  /// 账号切换面板
  Widget _userPanel(BuildContext context) {
    Widget users = Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        const Padding(
          padding: EdgeInsets.symmetric(horizontal: 10, vertical: 10),
          child: Text("用户"),
        ),
        ConstrainedBox(
          constraints: const BoxConstraints(
            maxHeight: 200,
          ),
          child: const AppUserBoxWidget(),
        ),
        Container(padding: const EdgeInsets.only(top: 10))
      ]
    );

    Widget login = Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        const Padding(
          padding: EdgeInsets.symmetric(horizontal: 10, vertical: 5),
          child: Text("登录"),
        ),
        SRCatCard(
          small: true,
          backgroundClear: true,
          icon: FluentIcons.globe,
          iconSize: 15,
          title: "网页登录",
          onTap: () async {
            Application.router.push("/webview/hoyolab/login");
            await Future.delayed(const Duration(milliseconds: 1));
            Application.router.pop();
          },
          rightChild: const SRCatIcon(FluentIcons.chevron_right_small, size: 10),
        ),
        SRCatCard(
          small: true,
          backgroundClear: true,
          icon: FluentIcons.edit,
          iconSize: 15,
          title: "Cookie 登录",
          onTap: () => SRCatMHYUserLib.cookieLogin(),
          rightChild: const SRCatIcon(FluentIcons.chevron_right_small, size: 10),
        ),
        SRCatCard(
          small: true,
          backgroundClear: true,
          icon: FluentIcons.refresh,
          iconSize: 15,
          title: "刷新当前账号",
          onTap: () => SRCatMHYUserLib.refreshCurrentAcc(),
          rightChild: const SRCatIcon(FluentIcons.chevron_right_small, size: 10),
        ),
      ],
    );
    
    Widget panel = Container(
      width: 300,
      decoration: const BoxDecoration(
        borderRadius: BorderRadius.all(Radius.circular(6))
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          users,
          const Divider(),
          login
        ],
      )
    );

    return Mica(
      borderRadius: const BorderRadius.all(Radius.circular(6)),
      child: panel
    );
  }

  @override
  Widget build(
    BuildContext context,
    bool selected,
    VoidCallback? onPressed, {
    PaneDisplayMode? displayMode,
    bool showTextOnTop = true,
    int? itemIndex,
    bool? autofocus
  }) {
    

    final maybeBody = InheritedNavigationView.maybeOf(context);
    final mode = displayMode ??
        maybeBody?.displayMode ??
        maybeBody?.pane?.displayMode ??
        PaneDisplayMode.minimal;
    
    Widget user = Container(
      padding: const EdgeInsets.symmetric(horizontal: 5),
      child: Row(
        children: <Widget>[
          _avatar(),
          const SizedBox(width: 8),
          Expanded(child: _nicknameAndUid()),
          const SizedBox(width: 4),
          const SRCatIcon(FluentIcons.chevron_up_small, size: 12),
          const SizedBox(width: 4),
        ],
      ),
    );

    Widget userMini = Center(
      child: _avatar(isMini: true)
    );
    
    return HoverButton(
      onPressed: () {},
      cursor: SystemMouseCursors.click,
      builder: (context, states) {
        Widget child = FocusBorder(
          focused: states.isFocused,
          renderOutside: false,
          child: RepaintBoundary(
            child: AnimatedContainer(
              height: mode == PaneDisplayMode.compact ? 40 : 50,
              width: double.infinity,
              margin: EdgeInsets.symmetric(
                horizontal: mode == PaneDisplayMode.compact ? 0 : 7
              ),
              duration: FluentTheme.of(context).fasterAnimationDuration,
              decoration: BoxDecoration(
                color: ButtonThemeData.uncheckedInputColor(
                  FluentTheme.of(context),
                  states,
                  transparentWhenNone: true,
                ),
                borderRadius: BorderRadius.circular(4.0),
              ),
              child: mode == PaneDisplayMode.compact ? userMini : user,
            )
          )
        );

        return GestureDetector(
          onTapDown: (TapDownDetails details) {
            contextController.showFlyout(
              navigatorKey: Application.rootNavigatorKey.currentState,
              builder: (context) {
                return _userPanel(context);
              }
            );
          },
          child: FlyoutTarget(
            key: contextAttachKey,
            controller: contextController,
            child: child,
          )
        );
      }
    );
  }
}
