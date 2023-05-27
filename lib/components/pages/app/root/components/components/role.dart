/// ===========================================================================
/// Copyright (c) 2020-2023, BoxCat. All rights reserved.
/// Date: 2023-05-27 22:33:07
/// LastEditTime: 2023-05-28 00:46:36
/// FilePath: /lib/components/pages/app/root/components/components/role.dart
/// ===========================================================================

import 'package:fluent_ui/fluent_ui.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:srcat/application.dart';
import 'package:srcat/components/global/scroll/normal.dart';
import 'package:srcat/riverpod/global/user.dart';

class AppUserItemRoleWidget extends ConsumerStatefulWidget {
  const AppUserItemRoleWidget({
    Key? key,
    required this.roleList,
  }) : super(key: key);

  /// 角色信息
  final List<Map<String, dynamic>> roleList;

  @override
  ConsumerState<AppUserItemRoleWidget> createState() => _AppUserItemRoleWidgetState();
}

class _AppUserItemRoleWidgetState extends ConsumerState<AppUserItemRoleWidget> {
  Widget _roleItem({
    required bool selected,
    required String nickname,
    required String region,
    required int uid,
    required int level,
  }) {
    Widget itemBox() {
      return AnimatedContainer(
        height: 50,
        duration: FluentTheme.of(context).fasterAnimationDuration,
        color: selected ? FluentTheme.of(context).resources.subtleFillColorTertiary : Colors.transparent,
        child: Row(
          children: <Widget> [
            SizedBox(
              height: 15,
              width: 3,
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  AnimatedContainer(
                    height: selected ? 15 : 0,
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
            const SizedBox(width: 5),
            Expanded(child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: <Widget>[
                Text(nickname),
                Text("$region | Lv.${level.toString()} | ${uid.toString()}", style: const TextStyle(fontSize: 12))
              ]
            )),
          ]
        )
      );
    }

    return HoverButton(
      onPressed: () {
        ref.read(globalUserManagerRiverpod).changeRole(uid);
        Application.router.pop();
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
            child: itemBox(),
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
  }

  Widget _roleListWidget({ required int uid }) {
    List<Widget> widgets = [];

    for (Map<String, dynamic> role in widget.roleList) {
      widgets.add(_roleItem(
        uid: int.parse(role["game_uid"].toString()),
        nickname: role["nickname"].toString(),
        region: role["region_name"].toString(),
        selected: int.parse(role["game_uid"].toString()) == uid ? true : false,
        level: int.parse(role["level"].toString()),
      ));
    }

    return widget.roleList.isEmpty ?const Padding(
      padding: EdgeInsets.symmetric(horizontal: 10),
      child: Text("暂无角色")
    ) : Padding(
      padding: const EdgeInsets.symmetric(horizontal: 5),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: widgets,
      )
    );
  }

  @override
  Widget build(BuildContext context) {
    int roleUid = ref.watch(globalUserManagerRiverpod).nowRoleUid;

    return LayoutBuilder(
      builder: (BuildContext context, BoxConstraints constraints) {
        if (constraints.maxHeight <= 200) {
          return _roleListWidget(uid: roleUid);
        }

        return ConstrainedBox(
          constraints: const BoxConstraints(
            maxHeight: 200,
          ),
          child: SRCatNormalScroll(
            child: _roleListWidget(uid: roleUid)
          )
        );
      }
    );
  }
}
