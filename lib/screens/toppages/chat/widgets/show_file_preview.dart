import 'dart:developer';
import 'dart:io';

import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:flutter_cache_manager_dio/flutter_cache_manager_dio.dart';
import 'package:open_filex/open_filex.dart';

class ShowFilePreview extends StatefulWidget {
  final String url;
  final bool isSender;

  const ShowFilePreview({required this.url, required this.isSender, super.key});

  @override
  State<ShowFilePreview> createState() => _ShowFilePreviewState();
}

class _ShowFilePreviewState extends State<ShowFilePreview> {
  String fileName = "";
  String url = "";
  File? file;
  var dio = Dio();

  @override
  void initState() {
    super.initState();
    fileName = widget.url.substring(0, widget.url.indexOf("@@@"));
    url =
        widget.url.substring(widget.url.indexOf("@@@") + 3, widget.url.length);
    initialize();
  }

  initialize() {
    try {
      // dio.close();
      // DioCacheManager.instance.dispose();
      dio = Dio();
      dio.interceptors.add(LogInterceptor(responseBody: false));
      DioCacheManager.initialize(dio);
      // getFile();
    } catch (e) {}
  }

  // getFile() async {
  //   file = await DioCacheManager.instance.getSingleFile(url);
  // }
  Future<File> changeFileNameOnly(File file, String newFileName) {
    var path = file.path;
    var lastSeparator = path.lastIndexOf(Platform.pathSeparator);
    var newPath = path.substring(0, lastSeparator + 1) + newFileName;
    return file.rename(newPath);
  }

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: () async {
        var file = await DioCacheManager.instance.getSingleFile(url);
        // file = changeFileNameOnly(file,fileName)
        OpenFilex.open(file.path);
      },
      child: SizedBox(
          height: 50,
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              Icon(
                Icons.file_open,
                color: widget.isSender ? Colors.white : Colors.black,
              ),
              Text(
                fileName,
                style: TextStyle(
                    color: widget.isSender ? Colors.white : Colors.black,
                    fontWeight: FontWeight.bold),
              )
            ],
          )),
    );
  }
}
