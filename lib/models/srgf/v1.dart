/// ===========================================================================
/// Copyright (c) 2020-2023, BoxCat. All rights reserved.
/// Date: 2023-05-22 15:36:07
/// LastEditTime: 2023-05-22 17:33:48
/// FilePath: /lib/models/srgf/v1.dart
/// ===========================================================================

import 'package:srcat/application.dart';
import 'package:srcat/utils/main.dart';
import 'package:json_schema2/json_schema2.dart';

import 'package:srcat/libs/srcat/warp/main.dart';
export 'package:srcat/libs/srcat/warp/main.dart';

/// 星穹铁道抽卡记录标准 v1.0
class SRGFVer1Model {
  static Map schemaMap = {
    "\$schema": "http://json-schema.org/draft-04/schema#",
    "type": "object",
    "properties": {
      "info": {
        "type": "object",
        "properties": {
          "uid": {"type": "string"},
          "lang": {
            "type": "string",
            "description": "语言 languagecode2-country/regioncode2"
          },
          "region_time_zone": {"type": "number", "description": "时区"},
          "export_timestamp": {"type": "number", "description": "导出 UNIX 时间戳"},
          "export_app": {"type": "string", "description": "导出的 App 名称"},
          "export_app_version": {
            "type": "string",
            "description": "导出此份记录的 App 版本号"
          },
          "srgf_version": {
            "type": "string",
            "description": "所应用的 SRGF 的版本,包含此字段以防 SRGF 出现中断性变更时，App 无法处理"
          }
        },
        "description": "包含导出方定义的基本信息",
        "required": ["srgf_version", "uid", "lang", "region_time_zone"]
      },
      "list": {
        "type": "array",
        "items": {
          "type": "object",
          "properties": {
            "gacha_id": {"type": "string", "description": "卡池 Id"},
            "gacha_type": {
              "type": "string",
              "description": "卡池类型",
              "enum": ["1", "2", "11", "12"]
            },
            "item_id": {"type": "string", "description": "物品 Id"},
            "count": {"type": "string", "description": "数量，通常为1"},
            "time": {"type": "string", "description": "获取物品的时间"},
            "name": {"type": "string", "description": "物品名称"},
            "item_type": {"type": "string", "description": "物品类型"},
            "rank_type": {"type": "string", "description": "物品星级"},
            "id": {"type": "string", "description": "内部 Id"}
          },
          "required": ["gacha_id", "gacha_type", "item_id", "time", "id"]
        },
        "description": "包含卡池记录"
      }
    },
    "required": ["info", "list"]
  };

  static JsonSchema schema = JsonSchema.createSchema(schemaMap);

  /// 校验数据是否正确
  static bool validate(dynamic data) {
    return schema.validate(data);
  }

  /// 生成 SRGF Map
  static Map<String, dynamic> generateMap({
    required int uid,
    required int regionTimeZone,
    required List<Map<String, dynamic>> list,
  }) {
    return {
      "info": {
        "uid": uid.toString(),
        "lang": "zh-cn",
        "region_time_zone": regionTimeZone,
        "export_timestamp": SRCatUtils.getUnixTime(),
        "export_app": "SRCat",
        "export_app_version": Application.packageInfo.version.toString(),
        "srgf_version": "v1.0",
      },
      "list": list
    };
  }

  /// 生成 SRGF list Map
  static Map<String, dynamic> generateListDataMap({
    required int gachaId,
    required GachaWarpType gachaType,
    required int itemId,
    required int time,
    required String name,
    required String itemType,
    required int rankType,
    required int rawId
  }) {
    return {
      "gacha_id": gachaId.toString(),
      "gacha_type": gachaWarpTypeValue[gachaType].toString(),
      "item_id": itemId.toString(),
      "count": "1",
      "time": SRCatUtils.unixTimeToStr(time, format: "yyyy-MM-dd HH:mm:ss"),
      "name": name,
      "item_type": itemType,
      "rank_type": rankType.toString(),
      "id": rawId.toString(),
    };
  }
}
