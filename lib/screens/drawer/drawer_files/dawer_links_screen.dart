import 'package:any_link_preview/any_link_preview.dart';
import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:yourteam/constants/colors.dart';
import 'package:yourteam/methods/info_storage_methods.dart';
import 'package:yourteam/models/file_link_docs_model.dart';
import 'package:timeago/timeago.dart' as timeago;

class LinkScreen extends StatefulWidget {
  const LinkScreen({super.key});

  @override
  State<LinkScreen> createState() => _LinkScreenState();
}

class _LinkScreenState extends State<LinkScreen> {
  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(top: 20.0),
      child: FutureBuilder<List<LinkModel>>(
          future: InfoStorage().getLink(),
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
            return ListView.builder(
                itemCount: snapshot.data!.length,
                shrinkWrap: true,
                itemBuilder: ((context, index) {
                  var data = snapshot.data![index];
                  return _linkCard(data);
                }));
          }),
    );
  }

  _linkCard(LinkModel model) {
    return Card(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(15.0),
        ),
        child: Column(
          children: [
            AnyLinkPreview(
              link: model.fileUrl,

              displayDirection: UIDirection.uiDirectionHorizontal,
              showMultimedia: true,
              bodyMaxLines: 5,
              bodyTextOverflow: TextOverflow.ellipsis,
              titleStyle: const TextStyle(
                color: Colors.black,
                fontWeight: FontWeight.bold,
                fontSize: 15,
              ),
              placeholderWidget: Text(
                model.fileUrl,
                style: const TextStyle(
                    fontSize: 16, color: Color.fromARGB(255, 141, 181, 250)),
              ),
              errorWidget: TextButton(
                onPressed: () {
                  _launchUrl(model.fileUrl);
                },
                child: Text(
                  model.fileUrl,
                  style: const TextStyle(
                      fontSize: 16, color: Color.fromARGB(255, 141, 181, 250)),
                ),
              ),
              bodyStyle: const TextStyle(color: Colors.black, fontSize: 12),

              cache: const Duration(days: 7),
              backgroundColor: Colors.white,
              borderRadius: 12,
              removeElevation: true,
              // boxShadow: [const BoxShadow(blurRadius: 3, color: Colors.white)],
              onTap: () {
                _launchUrl(model.fileUrl);
              }, // This disables tap event
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                Padding(
                  padding: const EdgeInsets.only(right: 20, bottom: 20),
                  child: Text(
                    timeago.format(
                      model.timeSent,
                    ),
                    style: const TextStyle(color: Colors.grey),
                  ),
                ),
              ],
            ),
          ],
        ));
  }

  Future<void> _launchUrl(String link) async {
    final Uri url = Uri.parse(link);

    if (!await launchUrl(
      url,
      mode: LaunchMode.externalApplication,
    )) {
      throw 'Could not launch $url';
    }
  }
}
