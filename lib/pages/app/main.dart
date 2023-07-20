/// ===========================================================================
/// Copyright (c) 2020-2023, BoxCat. All rights reserved.
/// Date: 2023-05-07 00:24:49
/// LastEditTime: 2023-07-21 02:20:26
/// FilePath: /lib/pages/app/main.dart
/// ===========================================================================

import 'package:srcat/application.dart';

import 'package:fluent_ui/fluent_ui.dart';
import 'package:go_router/go_router.dart';
import 'package:srcat/components/pages/app/root/user.dart';
import 'package:srcat/riverpod/global/user.dart';
import 'package:srcat/utils/storage/main.dart';
import 'package:window_manager/window_manager.dart';

import 'package:srcat/riverpod/global/theme.dart';
import 'package:flutter_acrylic/flutter_acrylic.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:flutter_i18n/flutter_i18n.dart';

/// App Base Page
class AppPage extends ConsumerStatefulWidget {
  const AppPage({
    Key? key,
    required this.child,
    required this.shellContext,
    required this.state,
  }) : super(key: key);

  /// 子组件
  final Widget child;

  /// Shell 上下文
  final BuildContext? shellContext;

  /// Shell 状态
  final GoRouterState state;

  @override
  ConsumerState<AppPage> createState() => _AppPageState();
}

class _AppPageState extends ConsumerState<AppPage> with WindowListener {
  @override
  void initState() {
    windowManager.addListener(this);
    super.initState();
  }

  @override
  void dispose() {
    windowManager.removeListener(this);
    super.dispose();
  }

  /// 当前 Index
  int _selectedIndex() {
    final location = Application.router.location.split("?")[0];
    
    int index = _navItems()
      .where((element) => element.key != null)
      .toList()
      .indexWhere((element) => element.key == Key(location));

    if (index == -1) {
      int footerIndex = _footerNavItems()
        .where((element) => element.key != null)
        .toList()
        .indexWhere((element) => element.key == Key(location));
      if (footerIndex == -1) return 0;

      return _navItems()
        .where((element) => element.key != null)
        .toList()
        .length + footerIndex;
    }

    return index;
  }

  /// 标题栏
  Widget _title() {
    return const DragToMoveArea(
      child: Align(
        alignment: AlignmentDirectional.centerStart,
        child: Text.rich(TextSpan(
          style: TextStyle(fontSize: 14),
          children: <InlineSpan>[
            TextSpan(text: "S"),
            TextSpan(text: "R"),
            TextSpan(text: "C", style: TextStyle(fontSize: 16, fontFamily: "Cattie", fontWeight: FontWeight.w600)),
            TextSpan(text: "a"),
            TextSpan(text: "t"),
          ]
        ),
      ))
    );
  }

  /// 顶栏右侧操作区
  Widget _actions() {
    final FluentThemeData theme = FluentTheme.of(context);

    return Row(
      mainAxisAlignment: MainAxisAlignment.end,
      children: [
        SizedBox(
          width: 138,
          height: 50,
          child: WindowCaption(
            brightness: theme.brightness,
            backgroundColor: Colors.transparent,
          )
        )
      ]
    );
  }

  /// 导航栏列表
  List<NavigationPaneItem> _navItems() {
    return [
      PaneItem(
        key: const Key('/home'),
        icon: const Icon(FluentIcons.home),
        title: Text(
          FlutterI18n.translate(
            Application.rootNavigatorKey.currentContext!,
            "app.root.nav.title.home"
          )
        ),
        body: const SizedBox.shrink(),
        onTap: () {
          if (Application.router.location != "/home") {
            Application.router.push("/home");
          }
        }
      ),
      PaneItem(
        key: const Key('/tools/game/launch'),
        icon: const Icon(FluentIcons.game),
        title: Text(
          FlutterI18n.translate(
            Application.rootNavigatorKey.currentContext!,
            "app.root.nav.title.gameLaunch"
          )
        ),
        body: const SizedBox.shrink(),
        onTap: () {
          if (Application.router.location != "/tools/game/launch") {
            Application.router.push("/tools/game/launch");
          }
        }
      ),
      /*PaneItem(
        key: const Key('/tools/game/photo'),
        icon: const Icon(FluentIcons.photo_collection),
        title: Text(
          FlutterI18n.translate(
            Application.rootNavigatorKey.currentContext!,
            "app.root.nav.title.gamePhoto"
          )
        ),
        body: const SizedBox.shrink(),
        onTap: () {
          if (Application.router.location != "/tools/game/photo") {
            Application.router.push("/tools/game/photo");
          }
        }
      ),*/
      PaneItem(
        key: const Key('/tools/warp'),
        icon: const Icon(FluentIcons.six_point_star),
        title: Text(
          FlutterI18n.translate(
            Application.rootNavigatorKey.currentContext!,
            "app.root.nav.title.warp"
          )
        ),
        body: const SizedBox.shrink(),
        onTap: () {
          if (Application.router.location.split("?")[0] != "/tools/warp") {
            Application.router.push("/tools/warp");
          }
        }
      ),
    ];
  }

  /// 导航栏底部列表
  List<NavigationPaneItem> _footerNavItems() {
    String nickname = "";
    String roleUid = "";
    String avatar = "";
    String nowSelectUser = ref.watch(globalUserManagerRiverpod).nowSelectUser;
    List<Map<String, dynamic>> userList =ref.watch(globalUserManagerRiverpod).userList;
    int nowRoleUid = ref.watch(globalUserManagerRiverpod).nowRoleUid;
    if (userList.isNotEmpty) {
      for (Map<String, dynamic> user in userList) {
        if(user["id"] == nowSelectUser) {
          nickname = user["nickname"].toString();
          if (user["avatar"] != null) {
            avatar = user["avatar"].toString();
          }
          if (user["role"] != null) {
            for (Map<String, dynamic> role in user["role"].cast<Map<String, dynamic>>()) {
              if (nowRoleUid.toString() == role["game_uid"].toString()) {
                roleUid = role["game_uid"].toString();
                break;
              }
            }
          }
          break;
        }
      }
    } else {
      nickname = "暂无用户";
      roleUid = "(´･ω･`)?";
    }

    List<NavigationPaneItem> webviewItem = [];
    final location = Application.router.location.split("?")[0];
    if (location == "/webview/hoyolab/login") {
      webviewItem = [
        PaneItemSeparator(),
        PaneItem(
          key: const Key('/webview/hoyolab/login'),
          icon: const Icon(FluentIcons.globe),
          title: const Text("米游社登录"),
          body: const SizedBox.shrink(),
          onTap: () {}
        )
      ];
    }

    return [
      ...webviewItem,
      PaneItemSeparator(),
      AppUserWidget(
        key: const Key('users'),
        icon: const SizedBox.shrink(),
        body: const SizedBox.shrink(),
        nickname: nickname,
        roleUid: roleUid,
        avatar: avatar,
      ),
      PaneItemSeparator(),
      PaneItem(
        key: const Key('/settings'),
        icon: const Icon(FluentIcons.settings),
        title: Text(
          FlutterI18n.translate(
            Application.rootNavigatorKey.currentContext!,
            "app.root.nav.title.settings"
          )
        ),
        body: const SizedBox.shrink(),
        onTap: () {
          if (Application.router.location != "/settings") {
            Application.router.push("/settings");
          }
        }
      )
    ];
  }

  /// 左侧导航栏
  NavigationPane _navs() {
    return NavigationPane(
      selected: _selectedIndex(),
      items: _navItems(),
      footerItems: _footerNavItems(),
      size: const NavigationPaneSize(
        openMaxWidth: 200
      )
    );
  }

  @override
  Widget build(BuildContext context) {
    WindowEffect effect = WindowEffect.disabled;
    bool isDark = false;
    final String material = ref.watch(themeRiverpod)["material"];
    final String theme = ref.watch(themeRiverpod)["theme"];
    if (material == "mica") {
      effect = WindowEffect.mica;
    } else if (material == "acrylic") {
      effect = WindowEffect.acrylic;
    } else if (material == "tabbed") {
      effect = WindowEffect.tabbed;
    } else {
      effect = WindowEffect.disabled;
    }
    if (Application.buildNumber < 22000) {
      effect = WindowEffect.disabled;
    }
    if (theme == "auto") {
      isDark = MediaQuery.of(context).platformBrightness == Brightness.dark;
    } else if (theme == "dark") {
      isDark = true;
    } else {
      isDark = false;
    }
    Window.setEffect(
      effect: effect,
      dark: isDark,
    );
    
    return NavigationView(
      key: widget.key,
      appBar: NavigationAppBar(
        leading: null,
        title: _title(),
        actions: _actions(),
        automaticallyImplyLeading: false,
      ),
      pane: _navs(),
      paneBodyBuilder: (item, child) {
        final name = item?.key is ValueKey ? (item!.key as ValueKey).value : null;
        return FocusTraversalGroup(
          key: ValueKey('body$name'),
          child: widget.child,
        );
      }
    ); 
  }

  @override
  void onWindowClose() async {
    bool isPreventClose = await windowManager.isPreventClose();
    if (isPreventClose) windowManager.destroy();
  }

  @override
  void onWindowResized() async {
    Size windowSize = await WindowManager.instance.getSize();
    SRCatStorageUtils.write("window_size", [windowSize.width, windowSize.height]);
  }

  @override
  void onWindowMoved() async {
    Offset windowPosition = await WindowManager.instance.getPosition();
    SRCatStorageUtils.write("window_position", [windowPosition.dx, windowPosition.dy]);
  }
}
