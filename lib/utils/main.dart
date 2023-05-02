/// ===========================================================================
/// Copyright (c) 2020-2023, BoxCat. All rights reserved.
/// Date: 2023-05-02 03:46:40
/// LastEditTime: 2023-05-02 17:43:08
/// FilePath: /lib/utils/main.dart
/// ===========================================================================

class SCUtils {
  static strToUnixTime(String time) {
    DateTime dateTime = DateTime.parse(time);
    return dateTime.millisecondsSinceEpoch ~/ 1000;
  }

  /// 10 位数 Unix 时间戳转换为时间
  static unixTimeToStr(int unixTime, { String format = "yyyy/MM/dd" }) {
    DateTime dateTime = DateTime.fromMillisecondsSinceEpoch(unixTime * 1000);
    /// 按照 format 格式化时间
    return format.replaceAll("yyyy", dateTime.year.toString())
      .replaceAll("MM", dateTime.month.toString().padLeft(2, "0"))
      .replaceAll("dd", dateTime.day.toString().padLeft(2, "0"))
      .replaceAll("HH", dateTime.hour.toString().padLeft(2, "0"))
      .replaceAll("mm", dateTime.minute.toString().padLeft(2, "0"))
      .replaceAll("ss", dateTime.second.toString().padLeft(2, "0"));
  }
}
