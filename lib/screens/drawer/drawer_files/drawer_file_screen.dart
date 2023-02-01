import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:flutter_cache_manager_dio/flutter_cache_manager_dio.dart';
import 'package:open_filex/open_filex.dart';
import 'package:yourteam/constants/colors.dart';
import 'package:yourteam/methods/info_storage_methods.dart';
import 'package:yourteam/models/file_link_docs_model.dart';
import 'package:timeago/timeago.dart' as timeago;

class FileScreen extends StatefulWidget {
  final String? id;
  const FileScreen({this.id, super.key});

  @override
  State<FileScreen> createState() => _FileScreenState();
}

class _FileScreenState extends State<FileScreen> {
  var dio = Dio();
  initialize() {
    try {
      dio = Dio();
      dio.interceptors.add(LogInterceptor(responseBody: false));
      DioCacheManager.initialize(dio);
      // getFile();
    } catch (e) {}
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(top: 20.0),
      child: FutureBuilder<List<DocsModel>>(
          future: InfoStorage().getFile(),
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return const Center(
                child: CircularProgressIndicator(),
              );
            }
            if (snapshot.data == null) {
              return const Center(
                child: Text("Nothing to show"),
              );
            }
            if (snapshot.data!.isEmpty) {
              return const Center(
                child: Text("Nothing to show"),
              );
            }
            List temp = [];
            if (widget.id != null) {
              for (var element in snapshot.data!) {
                if (element.senderId == widget.id) {
                  temp.add(element);
                }
              }
            } else {
              temp = snapshot.data!;
            }

            return ListView.builder(
                itemCount: temp.length,
                shrinkWrap: true,
                itemBuilder: ((context, index) {
                  var data = temp[index];

                  return _fileCard(data);
                }));
          }),
    );
  }

  _getFileIcon(String name) {
    if (name.endsWith(".pdf")) {
      return Icons.picture_as_pdf;
    } else if (name.endsWith(".html")) {
      return Icons.html;
    } else if (name.endsWith(".xlsx") ||
        name.endsWith(".doc") ||
        name.endsWith(".docx")) {
      return Icons.wysiwyg_rounded;
    } else if (name.endsWith(".xlsx")) {
      return Icons.file_copy_rounded;
    }
  }

  _fileCard(DocsModel model) {
    return Card(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(15.0),
        ),
        child: ListTile(
          onTap: () async {
            var file =
                await DioCacheManager.instance.getSingleFile(model.fileUrl);
            // file = changeFileNameOnly(file,fileName)
            OpenFilex.open(file.path);
          },
          leading: Container(
            decoration: BoxDecoration(
                color: mainColor.withOpacity(0.1),
                borderRadius: BorderRadius.circular(15)),
            width: 45,
            height: 45,
            child: Icon(
              _getFileIcon(model.fileName),
              color: mainColor,
            ),
          ),
          title: Text(
            model.fileName,
            style: const TextStyle(fontWeight: FontWeight.bold),
          ),
          subtitle: Text(
            timeago.format(
              model.timeSent,
            ),
            style: const TextStyle(color: Colors.grey),
          ),
        ));
  }
}
