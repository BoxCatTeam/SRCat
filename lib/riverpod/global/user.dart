/// ===========================================================================
/// Copyright (c) 2020-2023, BoxCat. All rights reserved.
/// Date: 2023-05-25 01:20:32
/// LastEditTime: 2023-05-27 20:22:45
/// FilePath: /lib/riverpod/global/user.dart
/// ===========================================================================

import 'package:fluent_ui/fluent_ui.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class GlobalUserManagerRiverpod extends ChangeNotifier {
  String _nowSelectUser = "";
  String get nowSelectUser => _nowSelectUser;

  int _nowRoleUid = 0;
  int get nowRoleUid => _nowRoleUid;

  // ignore: prefer_final_fields
  List<Map<String, dynamic>> _userList = [];
  List<Map<String, dynamic>> get userList => _userList;

  bool _load = true;
  bool get load => _load;

  void setLoadStatus(bool status) {
    _load = status;
    notifyListeners();
  }

  void changeUser(String user) {
    _nowSelectUser = user;
    notifyListeners();
  }

  void userListInit(List<Map<String, dynamic>> list) {
    for (Map<String, dynamic> item in list) {
      _userList.add({
        "id": item["id"],
        "aid": item["aid"],
        "mid": item["mid"],
        "uid": item["uid"],
        "ltoken": item["ltoken"],
        "stoken": item["stoken"],
        "cookie_token": item["cookie_token"],
        "avatar": (item["avatar"] ?? "").toString(),
        "isExpired": false,
        "nickname": (item["nickname"] ?? "").toString(),
        "role": (item["role"] ?? [])
      });
    }
    notifyListeners();
  }

  void addUser({
    required String id,
    required String aid,
    required String uid,
    required String mid,
    required String ltoken,
    required String stoken,
    required String cookieToken,
    required String avatar,
    required bool isExpired,
    required String nickname,
    required List<Map<String, dynamic>> role
  }) {
    _userList.add({
      "id": id,
      "aid": aid,
      "mid": mid,
      "uid": uid,
      "ltoken": ltoken,
      "stoken": stoken,
      "cookie_token": cookieToken,
      "avatar": "",
      "isExpired": false,
      "nickname": "",
      "role": []
    });
    notifyListeners();
  }

  void deleteUser(String id) {
    for (int index = 0; index < _userList.length; index++) {
      if (_userList[index]["id"] == id) {
        _userList.remove(_userList[index]);
      }
    }
    notifyListeners();
  }

  void editUser(String id, {
    String? aid,
    String? uid,
    String? mid,
    String? ltoken,
    String? stoken,
    String? cookieToken,
    String? avatar,
    bool? isExpired = false,
    String? nickname,
    List<Map<String, dynamic>>? role
  }) {
    for (int index = 0; index < _userList.length; index++) {
      if (_userList[index]["id"] == id) {
        if (aid != null) {
          _userList[index]["aid"] = aid;
        }
        if (uid != null) {
          _userList[index]["uid"] = uid;
        }
        if (mid != null) {
          _userList[index]["mid"] = mid;
        }
        if (ltoken != null) {
          _userList[index]["ltoken"] = ltoken;
        }
        if (stoken != null) {
          _userList[index]["stoken"] = stoken;
        }
        if (cookieToken != null) {
          _userList[index]["cookie_token"] = cookieToken;
        }
        if (avatar != null) {
          _userList[index]["avatar"] = avatar;
        }
        if (isExpired != null) {
          _userList[index]["isExpired"] = isExpired;
        }
        if (nickname != null) {
          _userList[index]["nickname"] = nickname;
        }
        if (role != null) {
          _userList[index]["role"] = role;
        }
      }
    }
    notifyListeners();
  }

  void changeRole(int uid) {
    _nowRoleUid = uid;
    notifyListeners();
  }
}

final globalUserManagerRiverpod = ChangeNotifierProvider((ref) => GlobalUserManagerRiverpod());
