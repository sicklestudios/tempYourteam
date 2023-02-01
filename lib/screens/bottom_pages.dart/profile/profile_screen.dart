import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:yourteam/constants/colors.dart';
import 'package:yourteam/constants/constants.dart';
import 'package:yourteam/models/user_model.dart';
import 'package:yourteam/screens/bottom_pages.dart/profile/profile_update_screen.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen>
    with WidgetsBindingObserver {
  @override
  void initState() {
    WidgetsBinding.instance.addObserver(this);
    super.initState();
    fetchUserInfo();
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);

    fetchUserInfo();
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.resumed) {
      //do your stuff
      fetchUserInfo();
      setState(() {});
    }
  }

  //getting the userInfo
  fetchUserInfo() async {
    {
      await firebaseFirestore
          .collection("users")
          .doc(firebaseAuth.currentUser?.uid)
          .get()
          .then((value) {
        userInfo = UserModel.getValuesFromSnap(value);
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    var size = MediaQuery.of(context).size;
    return SingleChildScrollView(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: [
          // Center(
          //   child: Container(
          //     width: size.width / 1.2,
          //     height: 200,
          //     decoration: BoxDecoration(
          //         color: Colors.white, borderRadius: BorderRadius.circular(15)),
          //     child: Column(
          //       mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          //       children: [
          //         Column(
          //           children: [
          //             CircleAvatar(
          //               radius: 50,
          //               backgroundImage: userInfo.photoUrl != ""
          //                   ? CachedNetworkImageProvider(userInfo.photoUrl)
          //                   : const AssetImage("assets/user.png")
          //                       as ImageProvider,
          //             ),
          //           ],
          //         ),
          //         Text(
          //           userInfo.bio == "" ? "Nothing to show" : userInfo.bio,
          //           style: const TextStyle(fontWeight: FontWeight.w500),
          //         ),
          //         Row(
          //           mainAxisAlignment: MainAxisAlignment.center,
          //           children: [
          //             const Icon(
          //               Icons.location_on,
          //               color: mainColor,
          //             ),
          //             Text(
          //               userInfo.location == ""
          //                   ? "Nothing to show"
          //                   : userInfo.location,
          //               style: const TextStyle(fontWeight: FontWeight.bold),
          //             ),
          //           ],
          //         )
          //       ],
          //     ),
          //   ),
          // ),
          // const SizedBox(
          //   height: 50,
          // ),
          const ProfileUpdateScreen(),
          Center(
            child: Padding(
              padding: const EdgeInsets.symmetric(
                horizontal: 25.0,
              ),
              child: Container(
                  width: size.width,
                  height: 80,
                  decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(15)),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: [
                      // ListTile(
                      //   onTap: () {
                      //     Navigator.of(context).push(MaterialPageRoute(
                      //         builder: (context) =>
                      //             const ProfileUpdateScreen()));
                      //   },
                      //   leading: Container(
                      //     decoration: BoxDecoration(
                      //         color: mainColor.withOpacity(0.1),
                      //         borderRadius: BorderRadius.circular(15)),
                      //     width: 45,
                      //     height: 45,
                      //     child: const Icon(
                      //       Icons.person,
                      //       color: mainColor,
                      //     ),
                      //   ),
                      //   title: const Text(
                      //     "Account",
                      //     style: TextStyle(fontWeight: FontWeight.bold),
                      //   ),
                      //   subtitle: const Text(
                      //     "Update your account details",
                      //     style: TextStyle(fontWeight: FontWeight.normal),
                      //   ),
                      //   trailing: const Icon(
                      //     Icons.arrow_forward_ios,
                      //     color: mainColor,
                      //   ),
                      // ),
                      // const Padding(
                      //   padding: EdgeInsets.symmetric(horizontal: 20),
                      //   child: Divider(
                      //     color: Colors.black45,
                      //   ),
                      // ),
                      // Column(
                      //   children: [
                      //     ListTile(
                      //       leading: Container(
                      //         decoration: BoxDecoration(
                      //             color: mainColor.withOpacity(0.1),
                      //             borderRadius: BorderRadius.circular(15)),
                      //         width: 45,
                      //         height: 45,
                      //         child: const Icon(
                      //           Icons.chat,
                      //           color: mainColor,
                      //         ),
                      //       ),
                      //       title: const Text(
                      //         "Chat",
                      //         style: TextStyle(fontWeight: FontWeight.bold),
                      //       ),
                      //       subtitle: const Text(
                      //         "Control your chat backup",
                      //         style: TextStyle(fontWeight: FontWeight.normal),
                      //       ),
                      //       trailing: const Icon(
                      //         Icons.arrow_forward_ios,
                      //         color: mainColor,
                      //       ),
                      //     ),
                      //     const Padding(
                      //       padding: EdgeInsets.symmetric(horizontal: 20),
                      //       child: Divider(
                      //         color: Colors.black45,
                      //       ),
                      //     ),
                      //   ],
                      // ),
                      // Column(
                      //   children: [
                      //     ListTile(
                      //       leading: Container(
                      //         decoration: BoxDecoration(
                      //             color: mainColor.withOpacity(0.1),
                      //             borderRadius: BorderRadius.circular(15)),
                      //         width: 45,
                      //         height: 45,
                      //         child: const Icon(
                      //           Icons.send_rounded,
                      //           color: mainColor,
                      //         ),
                      //       ),
                      //       title: const Text(
                      //         "Integration",
                      //         style: TextStyle(fontWeight: FontWeight.bold),
                      //       ),
                      //       subtitle: const Text(
                      //         "Sync your other social account",
                      //         style: TextStyle(fontWeight: FontWeight.normal),
                      //       ),
                      //       trailing: const Icon(
                      //         Icons.arrow_forward_ios,
                      //         color: mainColor,
                      //       ),
                      //     ),
                      //     const Padding(
                      //       padding: EdgeInsets.symmetric(horizontal: 20),
                      //       child: Divider(
                      //         color: Colors.black45,
                      //       ),
                      //     ),
                      //   ],
                      // ),
                      ListTile(
                        onTap: _launchUrl,
                        leading: Container(
                          decoration: BoxDecoration(
                              color: mainColor.withOpacity(0.1),
                              borderRadius: BorderRadius.circular(15)),
                          width: 45,
                          height: 45,
                          child: const Icon(
                            Icons.help_rounded,
                            color: mainColor,
                          ),
                        ),
                        title: const Text(
                          "Help",
                          style: TextStyle(fontWeight: FontWeight.bold),
                        ),
                        subtitle: const Text(
                          "Have any confusion? Consult us",
                          style: TextStyle(fontWeight: FontWeight.normal),
                        ),
                        trailing: const Icon(
                          Icons.arrow_forward_ios,
                          color: mainColor,
                        ),
                      ),
                    ],
                  )),
            ),
          )
        ],
      ),
    );
  }
}

Future<void> _launchUrl() async {
  if (!await launchUrl(Uri.parse("https://yourteam.chat/"),
      mode: LaunchMode.externalApplication)) {
    throw Exception('Could not launch');
  }
}



// ///
// ///import 'package:cached_network_image/cached_network_image.dart';
// import 'package:flutter/material.dart';
// import 'package:yourteam/constants/colors.dart';
// import 'package:yourteam/constants/constants.dart';
// import 'package:yourteam/models/user_model.dart';
// import 'package:yourteam/screens/bottom_pages.dart/profile/profile_update_screen.dart';

// class ProfileScreen extends StatefulWidget {
//   const ProfileScreen({super.key});

//   @override
//   State<ProfileScreen> createState() => _ProfileScreenState();
// }

// class _ProfileScreenState extends State<ProfileScreen>
//     with WidgetsBindingObserver {
//   @override
//   void initState() {
//     WidgetsBinding.instance.addObserver(this);
//     super.initState();
//     fetchUserInfo();
//   }

//   @override
//   void dispose() {
//     WidgetsBinding.instance.removeObserver(this);

//     fetchUserInfo();
//     super.dispose();
//   }

//   @override
//   void didChangeAppLifecycleState(AppLifecycleState state) {
//     if (state == AppLifecycleState.resumed) {
//       //do your stuff
//       fetchUserInfo();
//       setState(() {});
//     }
//   }

//   //getting the userInfo
//   fetchUserInfo() async {
//     {
//       await firebaseFirestore
//           .collection("users")
//           .doc(firebaseAuth.currentUser?.uid)
//           .get()
//           .then((value) {
//         userInfo = UserModel.getValuesFromSnap(value);
//       });
//     }
//   }

//   @override
//   Widget build(BuildContext context) {
//     var size = MediaQuery.of(context).size;
//     return SingleChildScrollView(
//       child: Column(
//         crossAxisAlignment: CrossAxisAlignment.center,
//         mainAxisAlignment: MainAxisAlignment.spaceEvenly,
//         children: [
//           Center(
//             child: Container(
//               width: size.width / 1.2,
//               height: 200,
//               decoration: BoxDecoration(
//                   color: Colors.white, borderRadius: BorderRadius.circular(15)),
//               child: Column(
//                 mainAxisAlignment: MainAxisAlignment.spaceEvenly,
//                 children: [
//                   Column(
//                     children: [
//                       // Row(
//                       //   mainAxisAlignment: MainAxisAlignment.end,
//                       //   children: [
//                       //     IconButton(
//                       //       onPressed: () {},
//                       //       icon: const Icon(Icons.edit),
//                       //     )
//                       //   ],
//                       // ),
//                       CircleAvatar(
//                         radius: 50,
//                         backgroundImage: userInfo.photoUrl != ""
//                             ? CachedNetworkImageProvider(userInfo.photoUrl)
//                             : const AssetImage("assets/user.png")
//                                 as ImageProvider,
//                       ),
//                     ],
//                   ),
//                   Text(
//                     userInfo.bio == "" ? "Nothing to show" : userInfo.bio,
//                     style: const TextStyle(fontWeight: FontWeight.w500),
//                   ),
//                   Row(
//                     mainAxisAlignment: MainAxisAlignment.center,
//                     children: [
//                       const Icon(
//                         Icons.location_on,
//                         color: mainColor,
//                       ),
//                       Text(
//                         userInfo.location == ""
//                             ? "Nothing to show"
//                             : userInfo.location,
//                         style: const TextStyle(fontWeight: FontWeight.bold),
//                       ),
//                     ],
//                   )
//                 ],
//               ),
//             ),
//           ),
//           const SizedBox(
//             height: 50,
//           ),
//           // ProfileUpdateScreen(),
//           Center(
//             child: Container(
//                 width: size.width / 1.2,
//                 height: 170,
//                 decoration: BoxDecoration(
//                     color: Colors.white,
//                     borderRadius: BorderRadius.circular(15)),
//                 child: Column(
//                   mainAxisAlignment: MainAxisAlignment.spaceEvenly,
//                   children: [
//                     ListTile(
//                       onTap: () {
//                         Navigator.of(context).push(MaterialPageRoute(
//                             builder: (context) => const ProfileUpdateScreen()));
//                       },
//                       leading: Container(
//                         decoration: BoxDecoration(
//                             color: mainColor.withOpacity(0.1),
//                             borderRadius: BorderRadius.circular(15)),
//                         width: 45,
//                         height: 45,
//                         child: const Icon(
//                           Icons.person,
//                           color: mainColor,
//                         ),
//                       ),
//                       title: const Text(
//                         "Account",
//                         style: TextStyle(fontWeight: FontWeight.bold),
//                       ),
//                       subtitle: const Text(
//                         "Update your account details",
//                         style: TextStyle(fontWeight: FontWeight.normal),
//                       ),
//                       trailing: const Icon(
//                         Icons.arrow_forward_ios,
//                         color: mainColor,
//                       ),
//                     ),
//                     const Padding(
//                       padding: EdgeInsets.symmetric(horizontal: 20),
//                       child: Divider(
//                         color: Colors.black45,
//                       ),
//                     ),
//                     // Column(
//                     //   children: [
//                     //     ListTile(
//                     //       leading: Container(
//                     //         decoration: BoxDecoration(
//                     //             color: mainColor.withOpacity(0.1),
//                     //             borderRadius: BorderRadius.circular(15)),
//                     //         width: 45,
//                     //         height: 45,
//                     //         child: const Icon(
//                     //           Icons.chat,
//                     //           color: mainColor,
//                     //         ),
//                     //       ),
//                     //       title: const Text(
//                     //         "Chat",
//                     //         style: TextStyle(fontWeight: FontWeight.bold),
//                     //       ),
//                     //       subtitle: const Text(
//                     //         "Control your chat backup",
//                     //         style: TextStyle(fontWeight: FontWeight.normal),
//                     //       ),
//                     //       trailing: const Icon(
//                     //         Icons.arrow_forward_ios,
//                     //         color: mainColor,
//                     //       ),
//                     //     ),
//                     //     const Padding(
//                     //       padding: EdgeInsets.symmetric(horizontal: 20),
//                     //       child: Divider(
//                     //         color: Colors.black45,
//                     //       ),
//                     //     ),
//                     //   ],
//                     // ),
//                     // Column(
//                     //   children: [
//                     //     ListTile(
//                     //       leading: Container(
//                     //         decoration: BoxDecoration(
//                     //             color: mainColor.withOpacity(0.1),
//                     //             borderRadius: BorderRadius.circular(15)),
//                     //         width: 45,
//                     //         height: 45,
//                     //         child: const Icon(
//                     //           Icons.send_rounded,
//                     //           color: mainColor,
//                     //         ),
//                     //       ),
//                     //       title: const Text(
//                     //         "Integration",
//                     //         style: TextStyle(fontWeight: FontWeight.bold),
//                     //       ),
//                     //       subtitle: const Text(
//                     //         "Sync your other social account",
//                     //         style: TextStyle(fontWeight: FontWeight.normal),
//                     //       ),
//                     //       trailing: const Icon(
//                     //         Icons.arrow_forward_ios,
//                     //         color: mainColor,
//                     //       ),
//                     //     ),
//                     //     const Padding(
//                     //       padding: EdgeInsets.symmetric(horizontal: 20),
//                     //       child: Divider(
//                     //         color: Colors.black45,
//                     //       ),
//                     //     ),
//                     //   ],
//                     // ),
//                     ListTile(
//                       leading: Container(
//                         decoration: BoxDecoration(
//                             color: mainColor.withOpacity(0.1),
//                             borderRadius: BorderRadius.circular(15)),
//                         width: 45,
//                         height: 45,
//                         child: const Icon(
//                           Icons.help_rounded,
//                           color: mainColor,
//                         ),
//                       ),
//                       title: const Text(
//                         "Help",
//                         style: TextStyle(fontWeight: FontWeight.bold),
//                       ),
//                       subtitle: const Text(
//                         "Have any confusion? Consult us",
//                         style: TextStyle(fontWeight: FontWeight.normal),
//                       ),
//                       trailing: const Icon(
//                         Icons.arrow_forward_ios,
//                         color: mainColor,
//                       ),
//                     ),
//                   ],
//                 )),
//           )
//         ],
//       ),
//     );
//   }
// }

///
///