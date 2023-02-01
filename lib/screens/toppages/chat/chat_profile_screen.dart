import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:yourteam/constants/colors.dart';
import 'package:yourteam/constants/constants.dart';
import 'package:yourteam/models/user_model.dart';
import 'package:yourteam/screens/drawer/drawer_files/drawer_file_screen.dart';
import 'package:yourteam/screens/drawer/drawer_files/drawer_media_screen.dart';

class ChatProfileScreen extends StatefulWidget {
  final String id;
  const ChatProfileScreen({required this.id, super.key});

  @override
  State<ChatProfileScreen> createState() => _ChatProfileScreenState();
}

class _ChatProfileScreenState extends State<ChatProfileScreen> {
  @override
  Widget build(BuildContext context) {
    var size = MediaQuery.of(context).size;

    return Scaffold(
      backgroundColor: scaffoldBackgroundColor,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        foregroundColor: Colors.black,
        elevation: 0,
        title: const Text(
          "User Profile",
          style: TextStyle(color: mainTextColor, fontWeight: FontWeight.bold),
        ),
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        child: FutureBuilder<UserModel>(
            future: firebaseFirestore
                .collection('users')
                .doc(widget.id)
                .get()
                .then((value) {
              return UserModel.getValuesFromSnap(value);
            }),
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                return const Center(
                  child: CircularProgressIndicator(),
                );
              }
              if (snapshot.data == null) {
                return const Center(
                  child: Text("Nothing to show you"),
                );
              }
              var data = snapshot.data!;

              return Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  Center(
                    child: Container(
                      width: size.width / 1.2,
                      height: 250,
                      decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(15)),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                        children: [
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.center,
                            children: [
                              CircleAvatar(
                                radius: 50,
                                backgroundImage: userInfo.photoUrl != ""
                                    ? CachedNetworkImageProvider(data.photoUrl)
                                    : const AssetImage("assets/user.png")
                                        as ImageProvider,
                              ),
                            ],
                          ),
                          Center(
                            child: Text(
                              data.bio == "" ? "Nothing to show" : data.bio,
                              textAlign: TextAlign.center,
                              overflow: TextOverflow.visible,
                              style:
                                  const TextStyle(fontWeight: FontWeight.w500),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(
                    height: 10,
                  ),
                  Center(
                    child: Container(
                      width: size.width / 1.2,
                      height: 130,
                      decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(15)),
                      child: Padding(
                        padding: const EdgeInsets.all(10),
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Padding(
                              padding: const EdgeInsets.all(8.0),
                              child: Row(
                                children: const [
                                  Text(
                                    "Contact Info",
                                    style:
                                        TextStyle(fontWeight: FontWeight.bold),
                                  ),
                                ],
                              ),
                            ),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.start,
                              children: [
                                const Icon(
                                  Icons.phone,
                                  color: mainColor,
                                ),
                                Text(
                                  data.contact == ""
                                      ? "Nothing to show"
                                      : data.contact,
                                  style: const TextStyle(
                                      fontWeight: FontWeight.bold),
                                ),
                              ],
                            ),
                            // if (data.contactEmail != "")
                            //   Row(
                            //     mainAxisAlignment: MainAxisAlignment.start,
                            //     children: [
                            //       const Icon(
                            //         Icons.phone,
                            //         color: mainColor,
                            //       ),
                            //       Text(
                            //         data.contactEmail,
                            //         style: const TextStyle(
                            //             fontWeight: FontWeight.bold),
                            //       ),
                            //     ],
                            //   ),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.start,
                              children: [
                                const Icon(
                                  Icons.location_on,
                                  color: mainColor,
                                ),
                                Text(
                                  data.location == ""
                                      ? "Nothing to show"
                                      : data.location,
                                  style: const TextStyle(
                                      fontWeight: FontWeight.bold),
                                ),
                              ],
                            )
                          ],
                        ),
                      ),
                    ),
                  ),
                  // Center(
                  //   child: Container(
                  //     width: size.width / 1.2,
                  //     height: 100,
                  //     decoration: BoxDecoration(
                  //         color: Colors.white,
                  //         borderRadius: BorderRadius.circular(15)),
                  //     child: Padding(
                  //       padding: const EdgeInsets.only(left: 20),
                  //       child: Column(
                  //         mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  //         children: [
                  //           Row(
                  //             children: const [
                  //               Text(
                  //                 "Contact Info",
                  //                 style: TextStyle(fontWeight: FontWeight.bold),
                  //               ),
                  //             ],
                  //           ),
                  //           if (data.contact != "")
                  //             Row(
                  //               mainAxisAlignment: MainAxisAlignment.start,
                  //               children: [
                  //                 const Icon(
                  //                   Icons.phone,
                  //                   color: mainColor,
                  //                 ),
                  //                 Text(
                  //                   data.contact,
                  //                   style: const TextStyle(
                  //                       fontWeight: FontWeight.bold),
                  //                 ),
                  //               ],
                  //             ),
                  //           // if (data.contactEmail != "")
                  //           //   Row(
                  //           //     mainAxisAlignment: MainAxisAlignment.start,
                  //           //     children: [
                  //           //       const Icon(
                  //           //         Icons.phone,
                  //           //         color: mainColor,
                  //           //       ),
                  //           //       Text(
                  //           //         data.contactEmail,
                  //           //         style: const TextStyle(
                  //           //             fontWeight: FontWeight.bold),
                  //           //       ),
                  //           //     ],
                  //           //   ),
                  //           if (data.location != "")
                  //             Row(
                  //               mainAxisAlignment: MainAxisAlignment.start,
                  //               children: [
                  //                 const Icon(
                  //                   Icons.location_on,
                  //                   color: mainColor,
                  //                 ),
                  //                 Text(
                  //                   data.location,
                  //                   style: const TextStyle(
                  //                       fontWeight: FontWeight.bold),
                  //                 ),
                  //               ],
                  //             )
                  //         ],
                  //       ),
                  //     ),
                  //   ),
                  // ),
                  const SizedBox(
                    height: 20,
                  ),
                  Center(
                    child: Container(
                        constraints: BoxConstraints(
                          maxHeight: 350,
                          minHeight: 150,
                          maxWidth: size.width / 1.2,
                          minWidth: size.width / 1.2,
                        ),
                        decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(15)),
                        child: Padding(
                          padding: const EdgeInsets.all(10),
                          child: Column(
                            mainAxisSize: MainAxisSize.min,
                            mainAxisAlignment: MainAxisAlignment.start,
                            children: [
                              Row(
                                children: const [
                                  Padding(
                                    padding: EdgeInsets.all(8.0),
                                    child: Text(
                                      "Shared Documents",
                                      style: TextStyle(
                                          fontWeight: FontWeight.bold),
                                    ),
                                  ),
                                ],
                              ),
                              const SizedBox(
                                height: 5,
                              ),
                              Flexible(child: FileScreen(id: widget.id)),
                            ],
                          ),
                        )),
                  ),
                  const SizedBox(
                    height: 20,
                  ),
                  Center(
                    child: Container(
                        constraints: BoxConstraints(
                          maxHeight: 600,
                          minHeight: 150,
                          maxWidth: size.width / 1.2,
                          minWidth: size.width / 1.2,
                        ),
                        decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(15)),
                        child: Padding(
                          padding: const EdgeInsets.all(10),
                          child: Column(
                            mainAxisSize: MainAxisSize.min,
                            mainAxisAlignment: MainAxisAlignment.start,
                            children: [
                              Row(
                                children: const [
                                  Padding(
                                    padding: EdgeInsets.all(8.0),
                                    child: Text(
                                      "Shared Media",
                                      style: TextStyle(
                                          fontWeight: FontWeight.bold),
                                    ),
                                  ),
                                ],
                              ),
                              const SizedBox(
                                height: 5,
                              ),
                              Flexible(child: MediaScreen(id: widget.id)),
                            ],
                          ),
                        )),
                  )
                ],
              );
            }),
      ),
    );
  }
}
