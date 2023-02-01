import 'dart:developer';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:image_picker/image_picker.dart';
import 'package:yourteam/constants/colors.dart';
import 'package:yourteam/constants/constants.dart';
import 'package:yourteam/constants/utils.dart';
import 'package:yourteam/methods/firestore_methods.dart';
import 'package:yourteam/methods/storage_methods.dart';
import 'package:yourteam/models/user_model.dart';

class ProfileUpdateScreen extends StatefulWidget {
  const ProfileUpdateScreen({super.key});

  @override
  State<ProfileUpdateScreen> createState() => _ProfileUpdateScreenState();
}

class _ProfileUpdateScreenState extends State<ProfileUpdateScreen> {
  TextEditingController? _usernameFieldController;
  TextEditingController? _bioFieldController;
  TextEditingController? _contactFieldController;
  TextEditingController? _locationFieldController;
  bool isEmailCorrect = false;
  UserModel value = userInfo;
  Uint8List? _image;
  String imgUrl = "";

  @override
  void initState() {
    super.initState();

    _usernameFieldController = TextEditingController(text: value.username);
    _bioFieldController = TextEditingController(text: value.bio);
    _contactFieldController = TextEditingController(text: value.contact);
    _locationFieldController = TextEditingController(text: value.location);
  }

  @override
  void dispose() {
    _usernameFieldController?.dispose();
    _bioFieldController?.dispose();
    _contactFieldController?.dispose();
    _locationFieldController?.dispose();
    fetchUserInfoFromUtils();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    var size = MediaQuery.of(context).size;

    return SingleChildScrollView(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Column(
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  SizedBox(
                    height: 130,
                    width: 130,
                    child: Stack(
                      clipBehavior: Clip.none,
                      fit: StackFit.expand,
                      children: [
                        _image == null
                            ? CircleAvatar(
                                radius: 80,
                                backgroundImage:
                                    CachedNetworkImageProvider(value.photoUrl))
                            : CircleAvatar(
                                radius: 80,
                                backgroundImage: MemoryImage(_image!)),
                        Positioned(
                            bottom: 0,
                            right: -25,
                            child: RawMaterialButton(
                              onPressed: () {
                                // pickImageFromGallery();

                                showModalBottomSheet(
                                  context: context,
                                  builder: (context) {
                                    return Container(
                                      color: scaffoldBackgroundColor,
                                      child: Wrap(
                                        children: [
                                          Padding(
                                            padding: const EdgeInsets.all(8.0),
                                            child: Row(
                                              mainAxisAlignment:
                                                  MainAxisAlignment
                                                      .spaceBetween,
                                              children: [
                                                const Text(
                                                  "Profile Picture",
                                                  style: TextStyle(
                                                      fontWeight:
                                                          FontWeight.bold,
                                                      fontSize: 18),
                                                ),
                                                if (userInfo.photoUrl !=
                                                    staticPhotoUrl)
                                                  IconButton(
                                                      onPressed: () {
                                                        StorageMethods()
                                                            .deleteImageFromStorage(
                                                                userInfo
                                                                    .photoUrl);
                                                        fetchUserInfo();
                                                        Navigator.pop(context);
                                                      },
                                                      icon: const Icon(
                                                          Icons.delete)),
                                              ],
                                            ),
                                          ),
                                          Container(
                                            margin: const EdgeInsets.all(20),
                                            child: Row(
                                              mainAxisAlignment:
                                                  MainAxisAlignment.spaceEvenly,
                                              children: [
                                                InkWell(
                                                  onTap: () {
                                                    pickImageFromGallery(
                                                        ImageSource.camera);
                                                    Navigator.pop(context);
                                                  },
                                                  child: Column(
                                                    children: [
                                                      Container(
                                                        decoration:
                                                            BoxDecoration(
                                                          border: Border.all(
                                                              color: mainColor),
                                                          borderRadius:
                                                              BorderRadius
                                                                  .circular(50),
                                                        ),
                                                        child: const Padding(
                                                          padding:
                                                              EdgeInsets.all(
                                                                  10),
                                                          child: Icon(
                                                            Icons
                                                                .camera_alt_outlined,
                                                            size: 35,
                                                            color: mainColor,
                                                          ),
                                                        ),
                                                      ),
                                                      const Text(
                                                        'Camera',
                                                      )
                                                    ],
                                                  ),
                                                ),
                                                const SizedBox(
                                                  width: 20,
                                                ),
                                                InkWell(
                                                  onTap: () {
                                                    pickImageFromGallery(
                                                        ImageSource.gallery);
                                                    Navigator.pop(context);
                                                  },
                                                  child: Column(
                                                    children: [
                                                      Container(
                                                        decoration:
                                                            BoxDecoration(
                                                          border: Border.all(
                                                              color: mainColor),
                                                          borderRadius:
                                                              BorderRadius
                                                                  .circular(50),
                                                        ),
                                                        child: const Padding(
                                                          padding:
                                                              EdgeInsets.all(
                                                                  10),
                                                          child: Icon(
                                                            Icons.photo,
                                                            size: 35,
                                                            color: mainColor,
                                                          ),
                                                        ),
                                                      ),
                                                      const Text(
                                                        'Gallery',
                                                      )
                                                    ],
                                                  ),
                                                ),
                                              ],
                                            ),
                                          )
                                        ],
                                      ),
                                    );
                                    // return Wrap(
                                  },
                                );
                              },
                              elevation: 2.0,
                              fillColor: const Color(0xFFF5F6F9),
                              padding: const EdgeInsets.all(15.0),
                              shape: const CircleBorder(),
                              child: const Icon(
                                Icons.camera_alt_outlined,
                                color: mainColor,
                              ),
                            )),
                      ],
                    ),
                  ),
                ],
              ),
              Padding(
                padding:
                    const EdgeInsets.symmetric(horizontal: 25.0, vertical: 15),
                child: Container(
                  decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(25)),
                  child: Column(
                    children: [
                      ListTile(
                        onTap: () {
                          _openInputBottomSheet('username');
                        },
                        leading: Container(
                          decoration: BoxDecoration(
                              color: mainColor.withOpacity(0.1),
                              borderRadius: BorderRadius.circular(15)),
                          width: 45,
                          height: 45,
                          child: const Icon(
                            Icons.person,
                            color: mainColor,
                          ),
                        ),
                        title: const Text(
                          "Username:",
                          style: TextStyle(fontWeight: FontWeight.w500),
                        ),
                        subtitle: Text(
                          _usernameFieldController!.text,
                          style: const TextStyle(fontWeight: FontWeight.w500),
                        ),
                        trailing: const Icon(
                          Icons.edit,
                          color: mainColor,
                        ),
                      ),

                      ListTile(
                        onTap: () {
                          _openInputBottomSheet('bio');
                        },
                        leading: Container(
                          decoration: BoxDecoration(
                              color: mainColor.withOpacity(0.1),
                              borderRadius: BorderRadius.circular(15)),
                          width: 45,
                          height: 45,
                          child: const Icon(
                            Icons.help,
                            color: mainColor,
                          ),
                        ),
                        title: const Text(
                          "Bio:",
                          style: TextStyle(fontWeight: FontWeight.w500),
                        ),
                        subtitle: Text(
                          _bioFieldController!.text,
                          style: const TextStyle(fontWeight: FontWeight.w500),
                        ),
                        trailing: const Icon(
                          Icons.edit,
                          color: mainColor,
                        ),
                      ),
                      ListTile(
                        onTap: () {
                          _openInputBottomSheet('phone');
                        },
                        leading: Container(
                          decoration: BoxDecoration(
                              color: mainColor.withOpacity(0.1),
                              borderRadius: BorderRadius.circular(15)),
                          width: 45,
                          height: 45,
                          child: const Icon(
                            Icons.phone,
                            color: mainColor,
                          ),
                        ),
                        title: const Text(
                          "Contact Number:",
                          style: TextStyle(fontWeight: FontWeight.w500),
                        ),
                        subtitle: Text(
                          _contactFieldController!.text,
                          style: const TextStyle(fontWeight: FontWeight.w500),
                        ),
                        trailing: const Icon(
                          Icons.edit,
                          color: mainColor,
                        ),
                      ),
                      ListTile(
                        onTap: () {
                          _openInputBottomSheet('location');
                        },
                        leading: Container(
                          decoration: BoxDecoration(
                              color: mainColor.withOpacity(0.1),
                              borderRadius: BorderRadius.circular(15)),
                          width: 45,
                          height: 45,
                          child: const Icon(
                            Icons.location_on,
                            color: mainColor,
                          ),
                        ),
                        title: const Text(
                          "Location:",
                          style: TextStyle(fontWeight: FontWeight.w500),
                        ),
                        subtitle: Text(
                          _locationFieldController!.text,
                          style: const TextStyle(fontWeight: FontWeight.w500),
                        ),
                        trailing: const Icon(
                          Icons.edit,
                          color: mainColor,
                        ),
                      ),

                      // Padding(
                      //   padding: const EdgeInsets.symmetric(vertical: 5),
                      //   child: SizedBox(
                      //     height: 70,
                      //     child: TextFormField(
                      //       controller: _usernameFieldController,
                      //       autofocus: false,
                      //       obscureText: false,
                      //       decoration: const InputDecoration(
                      //         labelText: 'Username',
                      //         border: OutlineInputBorder(
                      //           borderRadius: BorderRadius.all(
                      //             Radius.circular(15),
                      //           ),
                      //           borderSide: BorderSide(
                      //             color: mainColor,
                      //             // width: 1,
                      //           ),
                      //         ),
                      //         focusedBorder: OutlineInputBorder(
                      //           borderRadius: BorderRadius.all(
                      //             Radius.circular(15),
                      //           ),
                      //           borderSide: BorderSide(color: mainColor
                      //               // width: 1,
                      //               ),
                      //         ),
                      //         hintText: 'Enter Username',
                      //         filled: true,
                      //         fillColor: Colors.white,
                      //         hintStyle: TextStyle(
                      //             color: Color.fromRGBO(102, 124, 150, 1),
                      //             fontFamily: 'Poppins',
                      //             fontSize: 13,
                      //             letterSpacing:
                      //                 0 /*percentages not used in flutter. defaulting to zero*/,
                      //             fontWeight: FontWeight.normal,
                      //             height: 1),
                      //       ),
                      //     ),
                      //   ),
                      // ),
                      // Padding(
                      //   padding: const EdgeInsets.symmetric(vertical: 5),
                      //   child: SizedBox(
                      //     height: 70,
                      //     child: TextFormField(
                      //       controller: _bioFieldController,
                      //       autofocus: false,
                      //       obscureText: false,
                      //       decoration: const InputDecoration(
                      //         labelText: 'Bio',
                      //         border: OutlineInputBorder(
                      //           borderRadius: BorderRadius.all(
                      //             Radius.circular(15),
                      //           ),
                      //           borderSide: BorderSide(
                      //             color: mainColor,
                      //             // width: 1,
                      //           ),
                      //         ),
                      //         focusedBorder: OutlineInputBorder(
                      //           borderRadius: BorderRadius.all(
                      //             Radius.circular(15),
                      //           ),
                      //           borderSide: BorderSide(color: mainColor
                      //               // width: 1,
                      //               ),
                      //         ),
                      //         hintText: 'Enter Bio',
                      //         filled: true,
                      //         fillColor: Colors.white,
                      //         hintStyle: TextStyle(
                      //             color: Color.fromRGBO(102, 124, 150, 1),
                      //             fontFamily: 'Poppins',
                      //             fontSize: 13,
                      //             letterSpacing:
                      //                 0 /*percentages not used in flutter. defaulting to zero*/,
                      //             fontWeight: FontWeight.normal,
                      //             height: 1),
                      //       ),
                      //     ),
                      //   ),
                      // ),
                      // Padding(
                      //   padding: const EdgeInsets.symmetric(vertical: 5),
                      //   child: SizedBox(
                      //     height: 70,
                      //     child: TextFormField(
                      //       keyboardType: TextInputType.number,
                      //       controller: _contactFieldController,
                      //       autofocus: false,
                      //       obscureText: false,
                      //       decoration: const InputDecoration(
                      //         labelText: 'Contact Number',
                      //         border: OutlineInputBorder(
                      //           borderRadius: BorderRadius.all(
                      //             Radius.circular(15),
                      //           ),
                      //           borderSide: BorderSide(
                      //             color: mainColor,
                      //             // width: 1,
                      //           ),
                      //         ),
                      //         focusedBorder: OutlineInputBorder(
                      //           borderRadius: BorderRadius.all(
                      //             Radius.circular(15),
                      //           ),
                      //           borderSide: BorderSide(
                      //             color: mainColor,
                      //             // width: 1,
                      //           ),
                      //         ),
                      //         hintText: 'Enter Contact Number',
                      //         filled: true,
                      //         fillColor: Colors.white,
                      //         hintStyle: TextStyle(
                      //             color: Color.fromRGBO(102, 124, 150, 1),
                      //             fontFamily: 'Poppins',
                      //             fontSize: 13,
                      //             letterSpacing:
                      //                 0 /*percentages not used in flutter. defaulting to zero*/,
                      //             fontWeight: FontWeight.normal,
                      //             height: 1),
                      //       ),
                      //     ),
                      //   ),
                      // ),
                      // Padding(
                      //   padding: const EdgeInsets.symmetric(vertical: 5),
                      //   child: SizedBox(
                      //     height: 70,
                      //     child: TextFormField(
                      //       controller: _locationFieldController,
                      //       autofocus: false,
                      //       obscureText: false,
                      //       decoration: const InputDecoration(
                      //         labelText: "Location",
                      //         border: OutlineInputBorder(
                      //           borderRadius: BorderRadius.all(
                      //             Radius.circular(15),
                      //           ),
                      //           borderSide: BorderSide(
                      //             color: mainColor,
                      //             // width: 1,
                      //           ),
                      //         ),
                      //         focusedBorder: OutlineInputBorder(
                      //           borderRadius: BorderRadius.all(
                      //             Radius.circular(15),
                      //           ),
                      //           borderSide: BorderSide(
                      //             color: mainColor,
                      //             // width: 1,
                      //           ),
                      //         ),
                      //         hintText: 'Enter Location',
                      //         filled: true,
                      //         fillColor: Colors.white,
                      //         hintStyle: TextStyle(
                      //             color: Color.fromRGBO(102, 124, 150, 1),
                      //             fontFamily: 'Poppins',
                      //             fontSize: 13,
                      //             letterSpacing:
                      //                 0 /*percentages not used in flutter. defaulting to zero*/,
                      //             fontWeight: FontWeight.normal,
                      //             height: 1),
                      //       ),
                      //     ),
                      //   ),
                      // ),
                      // Padding(
                      // padding: const EdgeInsets.symmetric(vertical: 5),
                      // child: ElevatedButton(
                      //     onPressed: () async {
                      //       if (_usernameFieldController!.text.isEmpty ||
                      //           _usernameFieldController!.text != "") {
                      //         String res = await FirestoreMethods()
                      //             .updateProfile(
                      //                 name: _usernameFieldController!.text,
                      //                 contact:
                      //                     _contactFieldController!.text,
                      //                 bio: _bioFieldController!.text,
                      //                 loc: _locationFieldController!.text);

                      //         if (res == "success") {
                      //           showFloatingFlushBar(context, "Success",
                      //               "Profile Updated Successfully");
                      //           fetchUserInfo();
                      //         } else {
                      //           showFloatingFlushBar(context, "Error", res);
                      //         }
                      //       } else {
                      //         showFloatingFlushBar(
                      //             context, "Error", "Name cannot be empty");
                      //       }
                      //       fetchUserInfo();
                      //     },
                      //     style: ElevatedButton.styleFrom(
                      //       shape: RoundedRectangleBorder(
                      //         borderRadius: BorderRadius.circular(8),
                      //       ),
                      //       padding: const EdgeInsetsDirectional.fromSTEB(
                      //           0, 0, 0, 0),
                      //       minimumSize: const Size(306, 54),
                      //     ),
                      //     child: const Text(
                      //       'Update',
                      //       textAlign: TextAlign.left,
                      //       style: TextStyle(
                      //           color: Color.fromRGBO(255, 255, 255, 1),
                      //           fontFamily: 'Poppins',
                      //           fontSize: 15,
                      //           letterSpacing:
                      //               0 /*percentages not used in flutter. defaulting to zero*/,
                      //           fontWeight: FontWeight.normal,
                      //           height: 1),
                      //     )),
                      // ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  _openInputBottomSheet(String type) {
    return showModalBottomSheet<void>(
      isScrollControlled: true,
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.only(
            topLeft: Radius.circular(30.0), topRight: Radius.circular(30.0)),
      ),
      builder: (BuildContext context) {
        return Padding(
            padding: MediaQuery.of(context).viewInsets,
            child: Container(
                margin: const EdgeInsets.all(25),
                child: Wrap(
                  children: [
                    if (type == "username")
                      TextFormField(
                        controller: _usernameFieldController,
                        autofocus: true,
                        obscureText: false,
                        decoration: const InputDecoration(
                          labelText: 'Username',
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.all(
                              Radius.circular(15),
                            ),
                            borderSide: BorderSide(
                              color: mainColor,
                              // width: 1,
                            ),
                          ),
                          focusedBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.all(
                              Radius.circular(15),
                            ),
                            borderSide: BorderSide(color: mainColor
                                // width: 1,
                                ),
                          ),
                          hintText: 'Enter Username',
                          filled: true,
                          fillColor: Colors.white,
                          hintStyle: TextStyle(
                              color: Color.fromRGBO(102, 124, 150, 1),
                              fontFamily: 'Poppins',
                              fontSize: 13,
                              letterSpacing:
                                  0 /*percentages not used in flutter. defaulting to zero*/,
                              fontWeight: FontWeight.normal,
                              height: 1),
                        ),
                      ),
                    if (type == "bio")
                      TextFormField(
                        controller: _bioFieldController,
                        autofocus: true,
                        obscureText: false,
                        decoration: const InputDecoration(
                          labelText: 'Bio',
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.all(
                              Radius.circular(15),
                            ),
                            borderSide: BorderSide(
                              color: mainColor,
                              // width: 1,
                            ),
                          ),
                          focusedBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.all(
                              Radius.circular(15),
                            ),
                            borderSide: BorderSide(color: mainColor
                                // width: 1,
                                ),
                          ),
                          hintText: 'Enter Bio',
                          filled: true,
                          fillColor: Colors.white,
                          hintStyle: TextStyle(
                              color: Color.fromRGBO(102, 124, 150, 1),
                              fontFamily: 'Poppins',
                              fontSize: 13,
                              letterSpacing:
                                  0 /*percentages not used in flutter. defaulting to zero*/,
                              fontWeight: FontWeight.normal,
                              height: 1),
                        ),
                      ),
                    if (type == "phone")
                      TextFormField(
                        keyboardType: TextInputType.number,
                        controller: _contactFieldController,
                        autofocus: true,
                        obscureText: false,
                        decoration: const InputDecoration(
                          labelText: 'Contact Number',
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.all(
                              Radius.circular(15),
                            ),
                            borderSide: BorderSide(
                              color: mainColor,
                              // width: 1,
                            ),
                          ),
                          focusedBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.all(
                              Radius.circular(15),
                            ),
                            borderSide: BorderSide(
                              color: mainColor,
                              // width: 1,
                            ),
                          ),
                          hintText: 'Enter Contact Number',
                          filled: true,
                          fillColor: Colors.white,
                          hintStyle: TextStyle(
                              color: Color.fromRGBO(102, 124, 150, 1),
                              fontFamily: 'Poppins',
                              fontSize: 13,
                              letterSpacing:
                                  0 /*percentages not used in flutter. defaulting to zero*/,
                              fontWeight: FontWeight.normal,
                              height: 1),
                        ),
                      ),
                    if (type == "location")
                      TextFormField(
                        controller: _locationFieldController,
                        autofocus: true,
                        obscureText: false,
                        decoration: const InputDecoration(
                          labelText: "Location",
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.all(
                              Radius.circular(15),
                            ),
                            borderSide: BorderSide(
                              color: mainColor,
                              // width: 1,
                            ),
                          ),
                          focusedBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.all(
                              Radius.circular(15),
                            ),
                            borderSide: BorderSide(
                              color: mainColor,
                              // width: 1,
                            ),
                          ),
                          hintText: 'Enter Location',
                          filled: true,
                          fillColor: Colors.white,
                          hintStyle: TextStyle(
                              color: Color.fromRGBO(102, 124, 150, 1),
                              fontFamily: 'Poppins',
                              fontSize: 13,
                              letterSpacing:
                                  0 /*percentages not used in flutter. defaulting to zero*/,
                              fontWeight: FontWeight.normal,
                              height: 1),
                        ),
                      ),
                    Padding(
                      padding: const EdgeInsets.only(top: 10.0),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.end,
                        children: [
                          Row(
                            children: [
                              TextButton(
                                  onPressed: () {
                                    Navigator.pop(context);
                                  },
                                  child: const Text(
                                    "Cancel",
                                    style: TextStyle(color: mainColor),
                                  )),
                              TextButton(
                                  onPressed: () async {
                                    if (_usernameFieldController!
                                            .text.isNotEmpty ||
                                        _usernameFieldController!.text != "") {
                                      String res = await FirestoreMethods()
                                          .updateProfile(
                                              name: _usernameFieldController!
                                                  .text,
                                              contact:
                                                  _contactFieldController!.text,
                                              bio: _bioFieldController!.text,
                                              loc: _locationFieldController!
                                                  .text);

                                      if (res == "success") {
                                        showToastMessage(
                                            "Profile Updated Successfully");
                                        // showFloatingFlushBar(context, "Success",
                                        //     "Profile Updated Successfully");
                                        fetchUserInfo();
                                        WidgetsBinding.instance
                                            .addPostFrameCallback((_) {
                                          Navigator.pop(context);
                                        });
                                      } else {
                                        // showFloatingFlushBar(
                                        //     context, "Error", res);
                                        showToastMessage(res);
                                      }
                                    } else {
                                      showToastMessage("Name cannot be empty");
                                      // showFloatingFlushBar(context, "Error",
                                      //     "Name cannot be empty");
                                    }
                                  },
                                  child: const Text(
                                    "Save",
                                    style: TextStyle(color: mainColor),
                                  )),
                            ],
                          )
                        ],
                      ),
                    )
                  ],
                )));
      },
    );
  }
  // @override
  // Widget build(BuildContext context) {
  //   return Scaffold(
  //     backgroundColor: scaffoldBackgroundColor,
  //     appBar: AppBar(
  //         automaticallyImplyLeading: true,
  //         backgroundColor: Colors.transparent,
  //         toolbarHeight: 100,
  //         foregroundColor: Colors.black,
  //         elevation: 0,
  //         title: const Text(
  //           'Update details',
  //           style: TextStyle(fontWeight: FontWeight.bold),
  //         )),
  //     body: SingleChildScrollView(
  //       child: Column(
  //         crossAxisAlignment: CrossAxisAlignment.center,
  //         children: [
  //           Column(
  //             children: [
  //               Row(
  //                 mainAxisAlignment: MainAxisAlignment.center,
  //                 children: [
  //                   SizedBox(
  //                     height: 150,
  //                     width: 150,
  //                     child: Stack(
  //                       clipBehavior: Clip.none,
  //                       fit: StackFit.expand,
  //                       children: [
  //                         _image == null
  //                             ? CircleAvatar(
  //                                 radius: 80,
  //                                 backgroundImage: CachedNetworkImageProvider(
  //                                     value.photoUrl))
  //                             : CircleAvatar(
  //                                 radius: 80,
  //                                 backgroundImage: MemoryImage(_image!)),
  //                         Positioned(
  //                             bottom: 0,
  //                             right: -25,
  //                             child: RawMaterialButton(
  //                               onPressed: () {
  //                                 // pickImageFromGallery();

  //                                 showModalBottomSheet(
  //                                   context: context,
  //                                   builder: (context) {
  //                                     return Container(
  //                                       color: scaffoldBackgroundColor,
  //                                       child: Wrap(
  //                                         children: [
  //                                           Padding(
  //                                             padding:
  //                                                 const EdgeInsets.all(8.0),
  //                                             child: Row(
  //                                               mainAxisAlignment:
  //                                                   MainAxisAlignment
  //                                                       .spaceBetween,
  //                                               children: [
  //                                                 const Text(
  //                                                   "Profile Picture",
  //                                                   style: TextStyle(
  //                                                       fontWeight:
  //                                                           FontWeight.bold,
  //                                                       fontSize: 18),
  //                                                 ),
  //                                                 if (userInfo.photoUrl !=
  //                                                     staticPhotoUrl)
  //                                                   IconButton(
  //                                                       onPressed: () {
  //                                                         StorageMethods()
  //                                                             .deleteImageFromStorage(
  //                                                                 userInfo
  //                                                                     .photoUrl);
  //                                                         fetchUserInfo();
  //                                                         Navigator.pop(
  //                                                             context);
  //                                                       },
  //                                                       icon: const Icon(
  //                                                           Icons.delete)),
  //                                               ],
  //                                             ),
  //                                           ),
  //                                           Container(
  //                                             margin: const EdgeInsets.all(20),
  //                                             child: Row(
  //                                               mainAxisAlignment:
  //                                                   MainAxisAlignment
  //                                                       .spaceEvenly,
  //                                               children: [
  //                                                 InkWell(
  //                                                   onTap: () {
  //                                                     pickImageFromGallery(
  //                                                         ImageSource.camera);
  //                                                     Navigator.pop(context);
  //                                                   },
  //                                                   child: Column(
  //                                                     children: [
  //                                                       Container(
  //                                                         decoration:
  //                                                             BoxDecoration(
  //                                                           border: Border.all(
  //                                                               color:
  //                                                                   mainColor),
  //                                                           borderRadius:
  //                                                               BorderRadius
  //                                                                   .circular(
  //                                                                       50),
  //                                                         ),
  //                                                         child: const Padding(
  //                                                           padding:
  //                                                               EdgeInsets.all(
  //                                                                   10),
  //                                                           child: Icon(
  //                                                             Icons
  //                                                                 .camera_alt_outlined,
  //                                                             size: 35,
  //                                                             color: mainColor,
  //                                                           ),
  //                                                         ),
  //                                                       ),
  //                                                       const Text(
  //                                                         'Camera',
  //                                                       )
  //                                                     ],
  //                                                   ),
  //                                                 ),
  //                                                 const SizedBox(
  //                                                   width: 20,
  //                                                 ),
  //                                                 InkWell(
  //                                                   onTap: () {
  //                                                     pickImageFromGallery(
  //                                                         ImageSource.gallery);
  //                                                     Navigator.pop(context);
  //                                                   },
  //                                                   child: Column(
  //                                                     children: [
  //                                                       Container(
  //                                                         decoration:
  //                                                             BoxDecoration(
  //                                                           border: Border.all(
  //                                                               color:
  //                                                                   mainColor),
  //                                                           borderRadius:
  //                                                               BorderRadius
  //                                                                   .circular(
  //                                                                       50),
  //                                                         ),
  //                                                         child: const Padding(
  //                                                           padding:
  //                                                               EdgeInsets.all(
  //                                                                   10),
  //                                                           child: Icon(
  //                                                             Icons.photo,
  //                                                             size: 35,
  //                                                             color: mainColor,
  //                                                           ),
  //                                                         ),
  //                                                       ),
  //                                                       const Text(
  //                                                         'Gallery',
  //                                                       )
  //                                                     ],
  //                                                   ),
  //                                                 ),
  //                                               ],
  //                                             ),
  //                                           )
  //                                         ],
  //                                       ),
  //                                     );
  //                                     // return Wrap(

  //                                     //   children: [
  //                                     //     const ListTile(
  //                                     //       leading: Icon(Icons.share),
  //                                     //       title: Text('Share'),
  //                                     //     ),
  //                                     //     const ListTile(
  //                                     //       leading: Icon(Icons.copy),
  //                                     //       title: Text('Copy Link'),
  //                                     //     ),
  //                                     //     const ListTile(
  //                                     //       leading: Icon(Icons.edit),
  //                                     //       title: Text('Edit'),
  //                                     //     ),
  //                                     //   ],
  //                                     // );
  //                                   },
  //                                 );
  //                               },
  //                               elevation: 2.0,
  //                               fillColor: const Color(0xFFF5F6F9),
  //                               padding: const EdgeInsets.all(15.0),
  //                               shape: const CircleBorder(),
  //                               child: const Icon(
  //                                 Icons.camera_alt_outlined,
  //                                 color: mainColor,
  //                               ),
  //                             )),
  //                       ],
  //                     ),
  //                   ),
  //                 ],
  //               ),
  //               // Padding(
  //               //   padding: const EdgeInsets.only(top: 15.0),
  //               //   child: InkWell(
  //               //     onTap: () {
  //               //       pickImageFromGallery();
  //               //     },
  //               //     child: const Text(
  //               //       'Change Profile',
  //               //       style: TextStyle(fontWeight: FontWeight.bold),
  //               //     ),
  //               //   ),
  //               // ),
  //               Padding(
  //                 padding: const EdgeInsets.symmetric(
  //                     horizontal: 25.0, vertical: 25),
  //                 child: Container(
  //                   decoration: BoxDecoration(
  //                       color: Colors.white,
  //                       borderRadius: BorderRadius.circular(25)),
  //                   child: Padding(
  //                     padding: const EdgeInsets.all(25.0),
  //                     child: Column(
  //                       children: [
  //                         Padding(
  //                           padding: const EdgeInsets.symmetric(vertical: 5),
  //                           child: SizedBox(
  //                             height: 70,
  //                             child: TextFormField(
  //                               controller: _usernameFieldController,
  //                               autofocus: false,
  //                               obscureText: false,
  //                               decoration: const InputDecoration(
  //                                 labelText: 'Username',
  //                                 border: OutlineInputBorder(
  //                                   borderRadius: BorderRadius.all(
  //                                     Radius.circular(15),
  //                                   ),
  //                                   borderSide: BorderSide(
  //                                     color: mainColor,
  //                                     // width: 1,
  //                                   ),
  //                                 ),
  //                                 focusedBorder: OutlineInputBorder(
  //                                   borderRadius: BorderRadius.all(
  //                                     Radius.circular(15),
  //                                   ),
  //                                   borderSide: BorderSide(color: mainColor
  //                                       // width: 1,
  //                                       ),
  //                                 ),
  //                                 hintText: 'Enter Username',
  //                                 filled: true,
  //                                 fillColor: Colors.white,
  //                                 hintStyle: TextStyle(
  //                                     color: Color.fromRGBO(102, 124, 150, 1),
  //                                     fontFamily: 'Poppins',
  //                                     fontSize: 13,
  //                                     letterSpacing:
  //                                         0 /*percentages not used in flutter. defaulting to zero*/,
  //                                     fontWeight: FontWeight.normal,
  //                                     height: 1),
  //                               ),
  //                             ),
  //                           ),
  //                         ),
  //                         Padding(
  //                           padding: const EdgeInsets.symmetric(vertical: 5),
  //                           child: SizedBox(
  //                             height: 70,
  //                             child: TextFormField(
  //                               controller: _bioFieldController,
  //                               autofocus: false,
  //                               obscureText: false,
  //                               decoration: const InputDecoration(
  //                                 labelText: 'Bio',
  //                                 border: OutlineInputBorder(
  //                                   borderRadius: BorderRadius.all(
  //                                     Radius.circular(15),
  //                                   ),
  //                                   borderSide: BorderSide(
  //                                     color: mainColor,
  //                                     // width: 1,
  //                                   ),
  //                                 ),
  //                                 focusedBorder: OutlineInputBorder(
  //                                   borderRadius: BorderRadius.all(
  //                                     Radius.circular(15),
  //                                   ),
  //                                   borderSide: BorderSide(color: mainColor
  //                                       // width: 1,
  //                                       ),
  //                                 ),
  //                                 hintText: 'Enter Bio',
  //                                 filled: true,
  //                                 fillColor: Colors.white,
  //                                 hintStyle: TextStyle(
  //                                     color: Color.fromRGBO(102, 124, 150, 1),
  //                                     fontFamily: 'Poppins',
  //                                     fontSize: 13,
  //                                     letterSpacing:
  //                                         0 /*percentages not used in flutter. defaulting to zero*/,
  //                                     fontWeight: FontWeight.normal,
  //                                     height: 1),
  //                               ),
  //                             ),
  //                           ),
  //                         ),
  //                         Padding(
  //                           padding: const EdgeInsets.symmetric(vertical: 5),
  //                           child: SizedBox(
  //                             height: 70,
  //                             child: TextFormField(
  //                               keyboardType: TextInputType.number,
  //                               controller: _contactFieldController,
  //                               autofocus: false,
  //                               obscureText: false,
  //                               decoration: const InputDecoration(
  //                                 labelText: 'Contact Number',
  //                                 border: OutlineInputBorder(
  //                                   borderRadius: BorderRadius.all(
  //                                     Radius.circular(15),
  //                                   ),
  //                                   borderSide: BorderSide(
  //                                     color: mainColor,
  //                                     // width: 1,
  //                                   ),
  //                                 ),
  //                                 focusedBorder: OutlineInputBorder(
  //                                   borderRadius: BorderRadius.all(
  //                                     Radius.circular(15),
  //                                   ),
  //                                   borderSide: BorderSide(
  //                                     color: mainColor,
  //                                     // width: 1,
  //                                   ),
  //                                 ),
  //                                 hintText: 'Enter Contact Number',
  //                                 filled: true,
  //                                 fillColor: Colors.white,
  //                                 hintStyle: TextStyle(
  //                                     color: Color.fromRGBO(102, 124, 150, 1),
  //                                     fontFamily: 'Poppins',
  //                                     fontSize: 13,
  //                                     letterSpacing:
  //                                         0 /*percentages not used in flutter. defaulting to zero*/,
  //                                     fontWeight: FontWeight.normal,
  //                                     height: 1),
  //                               ),
  //                             ),
  //                           ),
  //                         ),
  //                         Padding(
  //                           padding: const EdgeInsets.symmetric(vertical: 5),
  //                           child: SizedBox(
  //                             height: 70,
  //                             child: TextFormField(
  //                               controller: _locationFieldController,
  //                               autofocus: false,
  //                               obscureText: false,
  //                               decoration: const InputDecoration(
  //                                 labelText: "Location",
  //                                 border: OutlineInputBorder(
  //                                   borderRadius: BorderRadius.all(
  //                                     Radius.circular(15),
  //                                   ),
  //                                   borderSide: BorderSide(
  //                                     color: mainColor,
  //                                     // width: 1,
  //                                   ),
  //                                 ),
  //                                 focusedBorder: OutlineInputBorder(
  //                                   borderRadius: BorderRadius.all(
  //                                     Radius.circular(15),
  //                                   ),
  //                                   borderSide: BorderSide(
  //                                     color: mainColor,
  //                                     // width: 1,
  //                                   ),
  //                                 ),
  //                                 hintText: 'Enter Location',
  //                                 filled: true,
  //                                 fillColor: Colors.white,
  //                                 hintStyle: TextStyle(
  //                                     color: Color.fromRGBO(102, 124, 150, 1),
  //                                     fontFamily: 'Poppins',
  //                                     fontSize: 13,
  //                                     letterSpacing:
  //                                         0 /*percentages not used in flutter. defaulting to zero*/,
  //                                     fontWeight: FontWeight.normal,
  //                                     height: 1),
  //                               ),
  //                             ),
  //                           ),
  //                         ),
  //                         Padding(
  //                           padding: const EdgeInsets.symmetric(vertical: 25),
  //                           child: ElevatedButton(
  //                               onPressed: () async {
  // if (_usernameFieldController!.text.isEmpty ||
  //     _usernameFieldController!.text != "") {
  //   String res = await FirestoreMethods()
  //       .updateProfile(
  //           name:
  //               _usernameFieldController!.text,
  //           contact:
  //               _contactFieldController!.text,
  //           bio: _bioFieldController!.text,
  //           loc:
  //               _locationFieldController!.text);

  //   if (res == "success") {
  //     showFloatingFlushBar(context, "Success",
  //         "Profile Updated Successfully");
  //     fetchUserInfo();
  //   } else {
  //     showFloatingFlushBar(
  //         context, "Error", res);
  //   }
  // } else {
  //   showFloatingFlushBar(context, "Error",
  //       "Name cannot be empty");
  // }
  // fetchUserInfo();
  //                               },
  //                               style: ElevatedButton.styleFrom(
  //                                 shape: RoundedRectangleBorder(
  //                                   borderRadius: BorderRadius.circular(8),
  //                                 ),
  //                                 padding: const EdgeInsetsDirectional.fromSTEB(
  //                                     0, 0, 0, 0),
  //                                 minimumSize: const Size(306, 54),
  //                               ),
  //                               child: const Text(
  //                                 'Update',
  //                                 textAlign: TextAlign.left,
  //                                 style: TextStyle(
  //                                     color: Color.fromRGBO(255, 255, 255, 1),
  //                                     fontFamily: 'Poppins',
  //                                     fontSize: 15,
  //                                     letterSpacing:
  //                                         0 /*percentages not used in flutter. defaulting to zero*/,
  //                                     fontWeight: FontWeight.normal,
  //                                     height: 1),
  //                               )),
  //                         ),
  //                       ],
  //                     ),
  //                   ),
  //                 ),
  //               ),
  //             ],
  //           ),
  //         ],
  //       ),
  //     ),
  //   );
  // }

  //getting the userInfo
  fetchUserInfo() async {
    {
      await firebaseFirestore
          .collection("users")
          .doc(firebaseAuth.currentUser?.uid)
          .get()
          .then((value) {
        setState(() {
          userInfo = UserModel.getValuesFromSnap(value);
        });
      });
    }
  }

  pickImage(ImageSource imageSource) async {
    final ImagePicker picker = ImagePicker();
    XFile? xfile =
        await picker.pickImage(source: imageSource, imageQuality: 85);
    if (xfile != null) {
      return await xfile.readAsBytes();
    }
    //Prompt that no image is selected
    log("No image is selected");
  }

  void pickImageFromGallery(source) async {
    final ByteData bytes = await rootBundle.load('assets/user.png');
    final Uint8List tempImage = bytes.buffer.asUint8List();
    StorageMethods().uploadImageToStorage(
      tempImage,
    );
    Uint8List inList = await pickImage(source);
    setState(() {
      _image = inList;
      if (_image != null) {
      } else {
        _image = tempImage;
      }
    });
    showFloatingFlushBar(context, "Please wait", "Uploading");
    imgUrl = await StorageMethods().uploadImageToStorage(_image!);
    await FirestoreMethods().addPhotoToFirestore(url: imgUrl);
    showToastMessage("Profile Updated");
    fetchUserInfo();
  }
}
