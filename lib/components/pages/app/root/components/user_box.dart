/// ===========================================================================
/// Copyright (c) 2020-2023, BoxCat. All rights reserved.
/// Date: 2023-05-25 01:03:35
/// LastEditTime: 2023-05-28 00:40:26
/// FilePath: /lib/components/pages/app/root/components/user_box.dart
/// ===========================================================================

import 'package:fluent_ui/fluent_ui.dart';
import 'package:srcat/libs/hoyolab/db.dart';
import 'package:srcat/riverpod/global/user.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:srcat/components/global/scroll/normal.dart';

import 'user_item.dart';

class AppUserBoxWidget extends ConsumerStatefulWidget {
  const AppUserBoxWidget({
    Key? key
  }) : super(key: key);

  @override
  ConsumerState<AppUserBoxWidget> createState() => _AppUserBoxWidgetState();
}

class _AppUserBoxWidgetState extends ConsumerState<AppUserBoxWidget> {
  /// 加载组件
  Widget _loadWidget() {
    return Container(
      width: double.infinity,
      margin: const EdgeInsets.only(bottom: 10, left: 12, right: 12),
      child: const ProgressBar(),
    );
  }

  /// 用户列表
  Widget _userListWidget() {
    List<Widget> widget = [];
    String select = ref.watch(globalUserManagerRiverpod).nowSelectUser;
    List<Map<String, dynamic>> list = ref.watch(globalUserManagerRiverpod).userList;

    for (Map<String, dynamic> user in list) {
      widget.add(
        AppUserItemWidget(
          id: user["id"],
          nickname: user["nickname"],
          avatar: user["avatar"],
          roleList: user["role"].cast<Map<String, dynamic>>(),
          isSelect: user["id"] == select ? true : false,
          onPressed: (String id) {
            if ((user["role"].cast<Map<String, dynamic>>() as List<Map<String, dynamic>>).isEmpty) {
              return;
            }
            if (ref.read(globalUserManagerRiverpod).nowRoleUid != 0 && ref.read(globalUserManagerRiverpod).nowSelectUser != id) {
              ref.read(globalUserManagerRiverpod).changeRole(int.parse(user["role"][0]["game_uid"].toString()));
            }
            HoYoLabDatabaseLib.selectUser(id);
            ref.read(globalUserManagerRiverpod).changeUser(id);
          },
          onDelete: (String id) {
            HoYoLabDatabaseLib.deleteUser(id);
            ref.read(globalUserManagerRiverpod).deleteUser(id);
          },
          onCopyCookie: (cookie) async {},
        )
      );
    }

    return list.isEmpty ? const Text("暂无用户") : Padding(
      padding: const EdgeInsets.symmetric(horizontal: 10),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: widget,
      )
    );
  }

  @override
  Widget build(BuildContext context) {
    bool status = ref.watch(globalUserManagerRiverpod).load;

    return LayoutBuilder(
      builder: (BuildContext context, BoxConstraints constraints) {
        if (constraints.maxHeight <= 200) {
          return status ? _loadWidget() : _userListWidget();
        }

        return SRCatNormalScroll(
          child: status ? _loadWidget() : _userListWidget()
        );
      }
    );
  }
}
