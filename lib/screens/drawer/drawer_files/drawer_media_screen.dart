import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:gallery_image_viewer/gallery_image_viewer.dart';
import 'package:yourteam/methods/info_storage_methods.dart';
import 'package:yourteam/models/file_link_docs_model.dart';
import 'package:flutter_staggered_grid_view/flutter_staggered_grid_view.dart';

class MediaScreen extends StatefulWidget {
  final String? id;
  const MediaScreen({this.id, super.key});

  @override
  State<MediaScreen> createState() => _MediaScreenState();
}

class _MediaScreenState extends State<MediaScreen> {
  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(top: 20.0),
      child: FutureBuilder<List<MediaModel>>(
          future: InfoStorage().getMedia(widget.id),
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
            // if (widget.id == null) {
            //   for (var element in snapshot.data!) {
            //     if (element.senderId == widget.id) {
            //       temp.add(element);
            //     }
            //   }
            // } else
            {
              temp = snapshot.data!;
            }

            return Container(
              margin: const EdgeInsets.all(12),
              child: StaggeredGridView.countBuilder(
                  crossAxisCount: 2,
                  crossAxisSpacing: 10,
                  mainAxisSpacing: 12,
                  itemCount: temp.length,
                  itemBuilder: (context, index) {
                    final imageProvider =
                        CachedNetworkImageProvider(temp[index].photoUrl);

                    return InkWell(
                      onTap: () {
                        showImageViewer(context, imageProvider,
                            onViewerDismissed: () {
                          print("dismissed");
                        });
                      },
                      child: Container(
                        decoration: const BoxDecoration(
                            color: Colors.transparent,
                            borderRadius:
                                BorderRadius.all(Radius.circular(15))),
                        child: ClipRRect(
                          borderRadius:
                              const BorderRadius.all(Radius.circular(15)),
                          child: CachedNetworkImage(
                            // placeholder: kTransparentImage,
                            imageUrl: temp[index].photoUrl,
                            fit: BoxFit.cover,
                          ),
                        ),
                      ),
                    );
                  },
                  staggeredTileBuilder: (index) {
                    return StaggeredTile.count(1, index.isEven ? 1.2 : 1.8);
                  }),
            );
          }),
    );
  }
  //getting the stuff from other users media

}
