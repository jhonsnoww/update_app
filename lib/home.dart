import 'dart:developer';
import 'dart:io';

import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:path_provider/path_provider.dart';
import 'package:permission_handler/permission_handler.dart';

class Home extends StatefulWidget {
  const Home({Key? key}) : super(key: key);

  @override
  State<Home> createState() => _HomeState();
}

class _HomeState extends State<Home> {
  late String _localPath;
  late bool _permissionReady;
  late TargetPlatform? platform;

  @override
  void initState() {
    super.initState();
    if (Platform.isAndroid) {
      platform = TargetPlatform.android;
    } else {
      platform = TargetPlatform.iOS;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          title: const Text("Update"),
        ),
        body: InkWell(
            onTap: () async {
              _permissionReady = await _checkPermission();
              if (_permissionReady) {
                await _prepareSaveDir();
                log("Downloading");
                try {
                  await Dio().download(
                      "https://raw.githubusercontent.com/jhonsnoww/update_app/master/test_v1.0.1.apk", "$_localPath/test_v1.0.1.apk");
                  log("Download Completed.");
                } catch (e) {
                  log("Download Failed.\n\n$e");
                }
              }
            },
            child: Container(
              decoration: BoxDecoration(
                  shape: BoxShape.circle, color: Colors.grey.withOpacity(0.5)),
              padding: const EdgeInsets.all(8),
              child: const Icon(Icons.download, color: Colors.black),
            )));
  }

  Future<void> _prepareSaveDir() async {
    _localPath = (await _findLocalPath())!;

    log(_localPath);
    final savedDir = Directory(_localPath);
    bool hasExisted = await savedDir.exists();
    if (!hasExisted) {
      savedDir.create();
    }
  }

  Future<String?> _findLocalPath() async {
    if (platform == TargetPlatform.android) {
      return "/sdcard/download/";
    } else {
      var directory = await getApplicationDocumentsDirectory();
      return '${directory.path}${Platform.pathSeparator}Download';
    }
  }

  Future<bool> _checkPermission() async {
    if (platform == TargetPlatform.android) {
      final status = await Permission.storage.status;
      if (status != PermissionStatus.granted) {
        final result = await Permission.storage.request();
        if (result == PermissionStatus.granted) {
          return true;
        }
      } else {
        return true;
      }
    } else {
      return true;
    }
    return false;
  }
}
