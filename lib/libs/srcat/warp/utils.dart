/// ===========================================================================
/// Copyright (c) 2020-2023, BoxCat. All rights reserved.
/// Date: 2023-05-09 10:23:21
/// LastEditTime: 2023-05-18 12:37:40
/// FilePath: /lib/libs/srcat/warp/utils.dart
/// ===========================================================================

import 'dart:typed_data';

import 'main.dart';

class SRCatWarpUtilsLib {
  /// 计算平均值
  static num average(Uint8List bytes, { bool isFloor = true }) {
    num sum = 0;
    num count = 0;
    for (int b in bytes) {
      sum += b;
      count++;
    }
    
    if (sum == 0 && count == 0) {
      return 0;
    }

    return isFloor ? (sum / count).floor() : (sum / count);
  }

  /// 计算抽卡最早的时间与最晚的时间
  static List<int> timeRange(List<int> times) {
    if (times.isEmpty) {
      return [0, 0];
    }
    int min = times[0];
    int max = times[0];
    for (int time in times) {
      if (time < min) {
        min = time;
      }
      if (time > max) {
        max = time;
      }
    }

    return [min, max];
  }

  /// 计算最欧与最啡抽数
  static List<int> upAndDownRange(List<Map<String, dynamic>> data) {
    List<int> list = [];
    for (Map<String, dynamic> item in data) {
      if (item["rank_type"] == 5 && item["lastNum"] != null) {
        list.add(item["lastNum"]);
      }
    }

    if (list.isEmpty) {
      return [0, 0];
    }

    /// 计算 List 的最大值与最小值
    int min = list[0];
    int max = list[0];

    for (int item in list) {
      if (item < min) {
        min = item;
      }
      if (item > max) {
        max = item;
      }
    }

    return [min, max];
  }

  /// 计算每个五星距离上一个五星的抽数
  static List<Map<String, dynamic>> parseStar5(List<Map<String, dynamic>> data) {
    List<Map<String, dynamic>> list = List<Map<String, dynamic>>.from(data);
    List<Map<String, dynamic>> result = [];

    for (int index = 0; index < list.length; index++) {
      Map<String, dynamic> temp = {
        ...list[index],
        "lastNum": 0,
      };

      if (list[index]["rank_type"] == 5) {
        /// 距离上次五星的抽数
        int count = 1; /// 哪有人是第 0 抽出的啊？
        /// 从当前位置向前遍历
        for (int inIndex = index + 1; inIndex < list.length; inIndex++) {
          /// 如果是五星或者到了最后一抽
          if (list[inIndex]["rank_type"] == 5 || inIndex - 1 == list.length) {
            break;
          }
          count = count + 1;
        }
        temp["lastNum"] = count;
      }
      result.add(temp);
    }

    return result;
  }

  /// 计算是否为保底
  static List<Map<String, dynamic>> parseGuaranteed(
      List<Map<String, dynamic>> data,
      List<Map<String, dynamic>> gachaPool,
      {required GachaWarpType type}) {
    /// 五星角色
    List<Map<String, dynamic>> star5 = [];
    /// 预筛选卡池
    List<Map<String, dynamic>> pool() {
      if (gachaWarpTypeValue[type] == 1 || gachaWarpTypeValue[type] == 2) {
        return [];
      }

      List<Map<String, dynamic>> result = [];
      for (Map<String, dynamic> pool in gachaPool) {
        if (gachaWarpTypeValue[type] == pool["gacha_type"]) {
          result.add(pool);
        }
      }
      return result;
    }
    pool().sort((a, b) => a["start_time"].compareTo(b["start_time"]));
    data.sort((a, b) => a["raw_id"].compareTo(b["raw_id"]));

    int nowItemCount = 0;

    /// 获取五星角色
    for (Map<String, dynamic> item in data) {
      if (item["rank_type"] == 5) {
        Map<String, dynamic> temp = {
          ...item,
          "isUP": false,
          "isGuaranteed": false
        };
        nowItemCount = nowItemCount + 1;
        /// 计算每个池子中抽中的五星是否保底
        if (pool().isNotEmpty) {
          for (var gacha in pool()) {
            if (nowItemCount == 1) {
              if (gacha["start5_up_items"].contains(item["item_id"])) {
                temp["isUP"] = true;
              }
            } else {
              if (gacha["start5_up_items"].contains(item["item_id"])) {
                temp["isUP"] = true;
                if (star5[star5.length - 1]["isUP"] is bool && star5[star5.length - 1]["isUP"] == true) {
                  temp["isGuaranteed"] = false;
                } else {
                  temp["isGuaranteed"] = true;
                }
              }
            }
          }
        }
        star5.insert(0, temp);
      }
    }

    return star5;
  }

  /// 计算五星平均抽数
  static int star5Average(List<Map<String, dynamic>> data) {
    List<int> list = [];
    for (Map<String, dynamic> item in data) {
      if (item["rank_type"] == 5 && item["lastNum"] != null) {
        list.add(item["lastNum"]);
      }
    }

    return average(Uint8List.fromList(list), isFloor: true).toInt();
  }

  /// 计算 UP 平均抽数
  static num upAverage(List<Map<String, dynamic>> data, int star) {
    List<int> list = [];
    int count = 0;
    int countAdd = 0;
    for (Map<String, dynamic> item in data) {
      if (item["rank_type"] == star) {
        countAdd = countAdd + 1;

        if (item["isUP"] != null && item["isUP"] is bool && item["isUP"] == true) {
          if (countAdd == 1) {
            list.add(item["lastNum"] as int);
          } else {
            list.add(count + item["lastNum"] as int);
          }
          count = 0;
        } else {
          count = count + item["lastNum"] as int;
        }
      }
    }

    return double.parse(average(Uint8List.fromList(list), isFloor: false).toStringAsFixed(3));
  }
}
