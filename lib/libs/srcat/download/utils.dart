/// ===========================================================================
/// Copyright (c) 2020-2023, BoxCat. All rights reserved.
/// Date: 2023-05-18 04:24:54
/// LastEditTime: 2023-05-18 04:30:30
/// FilePath: /lib/libs/srcat/download/utils.dart
/// ===========================================================================
// ignore_for_file: use_build_context_synchronously

import 'dart:math';

import 'package:flutter/widgets.dart';
import 'package:srcat/libs/metadata/db.dart';
import 'package:srcat/utils/http/dio.dart';
import 'package:srcat/utils/storage/main.dart';
import 'package:srcat/riverpod/pages/download.dart';
import 'package:srcat/libs/extensions/provider/context.dart';

class SRCatDownloadPageUtilsLib {
  static late String _baseUrl;

  /// 请求成功时解析数据
  static Future<void> successParse(
      BuildContext context, Map<String, dynamic> data) async {
    _baseUrl = data["base_url"].toString();

    /// 解析需下载的内容到列表
    Map<String, dynamic> downloadData = data["data"] as Map<String, dynamic>;
    Map<String, dynamic> parseResult = {};
    downloadData.forEach((title, item) {
      String downloadTitle = "";
      String progressText = "";

      // 判断标题内容是否附带 _
      if (title.contains("_")) {
        // 分割单词
        List<String> parts = title.split("_");
        // 分割结果
        String result = "";
        for (String part in parts) {
          result += part[0].toUpperCase() + part.substring(1).toLowerCase();
        }

        downloadTitle = result;
      } else {
        List<String> parts = title.split("");
        downloadTitle = parts[0].toUpperCase() +
            parts
                .sublist(1, parts.length)
                .map((str) => str.toString())
                .join('');
      }

      // 判断下载内容是否多个文件
      if (item["multi"] != null &&
          item["multi"] is bool &&
          item["multi"] == true) {
        List<dynamic> children =
            item["children"] is List<dynamic> ? item["children"] : [];
        progressText = "0/${children.length}";
      } else {
        progressText = "0%";
      }

      parseResult.addEntries({
        title: {
          "title": downloadTitle,
          "progress": 0.0,
          "progressText": progressText,
          "hidden": false,
        }
      }.entries);
    });

    /// 加入到下载列队中
    context.read(downloadRiverpod).initList(parseResult);

    await _downloadFile(context, downloadData, parseResult);
  }

  static Future<void> _downloadFile(BuildContext context,
      Map<String, dynamic> data, Map<String, dynamic> parseResult) async {
    /// 下载子元素内文件
    Future<void> downloadChildren(MapEntry item, List<dynamic> children) async {
      for (int index = 0; index < children.length; index++) {
        Map<String, dynamic> child = children[index];
        await SCDioUtils.download(
            uri: Uri.parse("$_baseUrl${child["download"]}"),
            savePath:
                "${SRCatStorageUtils.read("data_path")}/metadata${item.value["real_path"]}${child["uuid"]}",
            cancelToken: null,
            success: (response, data) {},
            fail: (code, message, failType, dioError) {},
            onReceiveProgress: (received, total) async {
              if (total != -1) {
                if ((received / total) >= 1.0) {
                  context.read(downloadRiverpod).changeList(item.key,
                      progress: ((index + 1) / children.length * 100),
                      progressText: "${index + 1}/${children.length}",
                      hidden: ((index + 1) / children.length).toDouble() >= 1.0
                          ? true
                          : false);
                }
              } else {
                context.read(downloadRiverpod).changeList(item.key,
                    progress: 100,
                    progressText: "${index + 1}/${children.length}",
                    hidden: true);
              }
            });

        if (item.value["type"] == "images") {
          SRCatMetadataDatabaseLib.saveImageInfo(
              id: children[index]["uuid"],
              name: children[index]["name"],
              parent: children[index]["parent"],
              hash: children[index]["hash"],
              path:
                  "${item.value["real_path"]}${children[index]["uuid"]}");
        } else if (item.value["type"] == "file") {
          SRCatMetadataDatabaseLib.saveFileInfo(
              id: children[index]["uuid"],
              name: children[index]["name"],
              parent: children[index]["parent"],
              hash: children[index]["hash"],
              path:
                  "${item.value["real_path"]}${children[index]["uuid"]}");
        }
      }
      context.read(downloadRiverpod).changeDownloadState(item.key, true);
    }

    /// 下载单独的文件
    Future<void> downloadSingle(MapEntry item) async {
      await SCDioUtils.download(
          uri: Uri.parse("$_baseUrl${item.value["download"]}"),
          savePath:
              "${SRCatStorageUtils.read("data_path")}/metadata${item.value["real_file"]}",
          cancelToken: null,
          success: (response, data) {},
          fail: (code, message, failType, dioError) {},
          onReceiveProgress: (received, total) async {
            if (total != -1) {
              context.read(downloadRiverpod).changeList(item.key,
                  progress:
                      int.parse((received / total * 100).toStringAsFixed(0))
                          .toDouble(),
                  progressText:
                      "${(received / total * 100).toStringAsFixed(0)}%",
                  hidden: (received / total) <= 0.0 ? false : true);
            } else {
              Random random = Random();
              await Future.delayed(
                  Duration(milliseconds: 100 + random.nextInt(1500 - 100)));
              context.read(downloadRiverpod).changeList(item.key,
                  progress: 100.0, progressText: "100%", hidden: true);
            }
          });
      SRCatMetadataDatabaseLib.saveFileInfo(
          id: item.value["uuid"],
          name: item.value["name"],
          parent: "",
          hash: item.value["hash"],
          path: item.value["real_file"]);
      context.read(downloadRiverpod).changeDownloadState(item.key, true);
    }

    for (MapEntry item in data.entries) {
      if (item.value["multi"] != null &&
          item.value["multi"] is bool &&
          item.value["multi"] == true) {
        if (item.value["type"] == "images" &&
            (item.value["children"] as List<dynamic>).isNotEmpty) {
          List<dynamic> children = item.value["children"] as List<dynamic>;
          downloadChildren(item, children);
        }
      } else {
        downloadSingle(item);
      }
    }
  }
}
