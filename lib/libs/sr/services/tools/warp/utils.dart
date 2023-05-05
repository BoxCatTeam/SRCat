/// ===========================================================================
/// Copyright (c) 2020-2023, BoxCat. All rights reserved.
/// Date: 2023-05-02 08:11:51
/// LastEditTime: 2023-05-04 23:26:47
/// FilePath: /lib/libs/sr/services/tools/warp/utils.dart
/// ===========================================================================

import 'dart:typed_data';
import 'main.dart';

class SrWrapToolServiceUtils {
  /// 计算平均值
  static int average(Uint8List bytes) {
    int sum = 0;
    int count = 0;
    for (int b in bytes) {
      sum += b;
      count++;
    }
    
    if (sum == 0 && count == 0) {
      return 0;
    }

    return (sum / count).floor();
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

  /// UP 平均抽数
  static int upAverage(List<int> times, List<int> upTimes) {
    int sum = 0;
    int count = 0;
    for (int time in times) {
      if (upTimes.contains(time)) {
        sum += time;
        count++;
      }
    }

    return (sum / count).floor();
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

  /// 计算是否为保底
  static List<Map<String, dynamic>> parseGuaranteed(
      List<Map<String, dynamic>> data,
      {required GachaWarpType type}) {
    /// 五星角色
    List<Map<String, dynamic>> star5 = [];

    /// 获取五星角色
    for (Map<String, dynamic> item in data) {
      if (item["rank_type"] == 5) {
        star5.add(item);
      }
    }

    return star5;
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

  /// 计算五星平均抽数
  static int star5Average(List<Map<String, dynamic>> data) {
    List<int> list = [];
    for (Map<String, dynamic> item in data) {
      if (item["rank_type"] == 5 && item["lastNum"] != null) {
        list.add(item["lastNum"]);
      }
    }

    return average(Uint8List.fromList(list));
  }
}
