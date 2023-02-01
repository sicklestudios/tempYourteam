import 'package:cached_network_image/cached_network_image.dart';
import 'package:callkeep/callkeep.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:yourteam/constants/colors.dart';
import 'package:yourteam/constants/constant_utils.dart';
import 'package:yourteam/constants/constants.dart';
import 'package:yourteam/methods/auth_methods.dart';
import 'package:yourteam/models/user_model.dart';
import 'package:yourteam/screens/auth/login_screen.dart';
import 'package:yourteam/screens/bottom_pages.dart/contacts_screen.dart';
import 'package:yourteam/screens/bottom_pages.dart/profile/profile_screen.dart';
import 'package:yourteam/screens/bottom_pages.dart/todo_screen.dart';
import 'package:yourteam/screens/drawer/drawer_files/drawer_menu-controller.dart';
import 'package:yourteam/screens/drawer/drawer_todo_controller.dart';
import 'package:yourteam/screens/notifications_screen.dart';
import 'package:yourteam/screens/search_screen.dart';
import 'package:yourteam/screens/task/add_task.dart';
import 'package:yourteam/screens/toppages/call_screen_list.dart';
import 'package:yourteam/screens/toppages/chat/chat_list_screen.dart';
import 'package:yourteam/service/local_push_notification.dart';

//message handler
Future<void> firebaseMessagingBackgroundHandler(RemoteMessage message) async {
  LocalNotificationService.display(
    message,
  );
}

class HomeController extends StatefulWidget {
  const HomeController({super.key});

  @override
  State<HomeController> createState() => _HomeControllerState();
}

class _HomeControllerState extends State<HomeController>
    with SingleTickerProviderStateMixin, WidgetsBindingObserver {
  /// For fcm background message handler.
  final FlutterCallkeep _callKeep = FlutterCallkeep();
  bool _callKeepInited = false;

  //value to get from text field
  String value = "";
  int pageIndex = 0;
  int bottomIndex = 0;
  var topPages = [];
  var bottomPages = [];

  _getText() {
    if (bottomIndex == 0) {
      if (pageIndex == 0) {
        return "Chats";
      }
      return "Calls";
    } else if (bottomIndex == 1) {
      return "To Do";
    } else if (bottomIndex == 2) {
      return "Contact";
    } else {
      return "Profile";
    }
  }

  _getBottomItem(IconData icon, String label, color) {
    return BottomNavigationBarItem(
      icon: Icon(
        icon,
        color: color,
      ),
      label: label,
    );
  }

  void _onItemTapped(int index) {
    setState(() {
      bottomIndex = index;
      value = "";
      showSearchBar = false;
    });
  }

  // Animation controller
  late AnimationController _animationController;

  // // This is used to animate the icon of the main FAB
  // late Animation<double> _buttonAnimatedIcon;

  // This is used for the child FABs
  late Animation<double> _translateButton;

  // This variable determnies whether the child FABs are visible or not
  bool _isExpanded = false;

  bool showSearchBar = false;
  final callSetup = <String, dynamic>{
    'ios': {
      'appName': 'CallKeepDemo',
    },
    'android': {
      'alertTitle': 'Permissions required',
      'alertDescription':
          'This application needs to access your phone accounts',
      'cancelButton': 'Cancel',
      'okButton': 'ok',
      // Required to get audio in background when using Android 11
      'foregroundService': {
        'channelId': 'com.company.my',
        'channelName': 'Foreground service for my app',
        'notificationTitle': 'My app is running on background',
        'notificationIcon': 'mipmap/ic_notification_launcher',
      },
    },
  };

  @override
  initState() {
    _animationController = AnimationController(
        vsync: this, duration: const Duration(milliseconds: 10))
      ..addListener(() {
        setState(() {});
      });

    // _buttonAnimatedIcon =
    //     Tween<double>(begin: 0.0, end: 1.0).animate(_animationController);

    _translateButton = Tween<double>(
      begin: 200,
      end: -5,
    ).animate(CurvedAnimation(
      parent: _animationController,
      curve: Curves.easeInOut,
    ));

    super.initState();
    WidgetsBinding.instance.addObserver(this);
    AuthMethods().setUserState(true);
    //setting up fcm

    FirebaseMessaging.instance.getInitialMessage();
    FirebaseMessaging.onBackgroundMessage(firebaseMessagingBackgroundHandler);

    FirebaseMessaging.onMessage.listen((event) {
      LocalNotificationService.display(
        event,
      );
    });
    storeNotificationToken();
    fetchUserInfo();

    _callKeep.setup(context, callSetup);
  }
  //Notification related work

  storeNotificationToken() async {
    String? token = await FirebaseMessaging.instance.getToken();
    firebaseFirestore
        .collection('users')
        .doc(firebaseAuth.currentUser!.uid)
        .set({'token': token}, SetOptions(merge: true));
  }

  // dispose the animation controller
  @override
  dispose() {
    _animationController.dispose();
    super.dispose();
    WidgetsBinding.instance.removeObserver(this);
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    super.didChangeAppLifecycleState(state);
    switch (state) {
      case AppLifecycleState.resumed:
        fetchUserInfoWithoutSetState();
        AuthMethods().setUserState(true);
        break;
      case AppLifecycleState.inactive:
      case AppLifecycleState.detached:
      case AppLifecycleState.paused:
        AuthMethods().setUserState(false);
        break;
    }
  }

  _toggle() {
    if (_isExpanded) {
      _animationController.reverse();
    } else {
      _animationController.forward();
    }

    _isExpanded = !_isExpanded;
  }

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

  //getting the userInfo
  fetchUserInfoWithoutSetState() async {
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
    if (userInfo == null) {
      fetchUserInfo();
    }
    topPages = [
      ChatContactsListScreen(
        value: value,
      ),
      const CallScreenList(),
    ];
    bottomPages = [
      ChatContactsListScreen(
        value: value,
      ),
      const TodoScreen(),
      ContactsScreen(
        value: value,
        isChat: true,
      ),
      const ProfileScreen(),
    ];
    var size = MediaQuery.of(context).size;
    return WillPopScope(
      onWillPop: () async {
        if (showSearchBar) {
          setState(() {
            showSearchBar = !showSearchBar;
          });
          return false;
        } else {
          return true;
        }
      },
      child: GestureDetector(
          onTap: () {
            if (showSearchBar) {
              setState(() {
                showSearchBar = !showSearchBar;
                value = "";
              });
            }

            if (_isExpanded) {
              _animationController.reverse();
              _isExpanded = !_isExpanded;
            }
          },
          child: Scaffold(
            // backgroundColor: scaffoldBackgroundColor,
            floatingActionButton:
                bottomIndex <= 1 ? _getFloatingButton() : const SizedBox(),
            bottomNavigationBar: BottomNavigationBar(
                backgroundColor: whiteColor,
                showSelectedLabels: true,
                showUnselectedLabels: true,
                items: <BottomNavigationBarItem>[
                  _getBottomItem(Icons.message_rounded, "Chats",
                      bottomIndex == 0 ? mainColor : greyColor),
                  _getBottomItem(Icons.note, "To Do",
                      bottomIndex == 1 ? mainColor : greyColor),
                  _getBottomItem(Icons.people, "Contacts",
                      bottomIndex == 2 ? mainColor : greyColor),
                  _getBottomItem(Icons.person, "Profile",
                      bottomIndex == 3 ? mainColor : greyColor),
                ],
                type: BottomNavigationBarType.fixed,
                currentIndex: bottomIndex,
                selectedItemColor: mainColor,
                unselectedItemColor: greyColor,
                iconSize: 35,
                onTap: _onItemTapped,
                elevation: 5),
            appBar: showSearchBar
                ? AppBar(
                    automaticallyImplyLeading: false,
                    backgroundColor: Colors.transparent,
                    toolbarHeight: 100,
                    foregroundColor: Colors.black,
                    leading: IconButton(
                        onPressed: () {
                          setState(() {
                            showSearchBar = !showSearchBar;
                          });
                        },
                        icon: const Icon(Icons.arrow_back_ios)),
                    elevation: 0,
                    title: TextField(
                      onChanged: (val) {
                        setState(() {
                          value = val;
                        });
                      },
                      decoration: const InputDecoration(
                          border: InputBorder.none, hintText: 'Search'),
                    ))
                : AppBar(
                    automaticallyImplyLeading: false,
                    backgroundColor: Colors.transparent,
                    toolbarHeight: 100,
                    elevation: 0,
                    leading: Builder(
                      builder: (context) {
                        return IconButton(
                          onPressed: () {
                            // showSimpleDialog(context)
                            Scaffold.of(context).openDrawer();
                          },
                          // icon: getIcon(Icons.groups_rounded),
                          icon: Image.asset('assets/group.png'),
                        );
                      },
                    ),
                    title: Text(
                      _getText(),
                      style: const TextStyle(
                          color: mainTextColor, fontWeight: FontWeight.bold),
                    ),
                    centerTitle: true,
                    actions: [
                      if (bottomIndex != 1 &&
                          bottomIndex != 3 &&
                          pageIndex != 1)
                        IconButton(
                          onPressed: () {
                            setState(() {
                              showSearchBar = !showSearchBar;
                            });
                          },
                          icon: getIcon(Icons.search),
                        ),
                      IconButton(
                        onPressed: () {
                          Navigator.push(
                              context,
                              MaterialPageRoute(
                                  builder: (context) =>
                                      const NotificationsScreen()));
                        },
                        icon: getIcon(Icons.notifications),
                      ),
                    ],
                  ),
            drawer: SafeArea(
              child: Drawer(
                backgroundColor: mainColor,
                width: size.width / 1.5,
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.start,
                  children: [
                    const SizedBox(height: 100),
                    // Row(
                    //   mainAxisAlignment: MainAxisAlignment.end,
                    //   children: [
                    //     IconButton(
                    //         onPressed: () {
                    //           Navigator.pop(context);
                    //         },
                    //         icon: const Icon(
                    //           Icons.close_rounded,
                    //           color: Colors.red,
                    //         )),
                    //   ],
                    // ),
                    ListTile(
                      leading: SizedBox(
                        width: 60,
                        child: CircleAvatar(
                          radius: 45,
                          backgroundImage: userInfo == null
                              ? const AssetImage(
                                  'assets/user.png',
                                )
                              : userInfo!.photoUrl == ""
                                  ? const AssetImage(
                                      'assets/user.png',
                                    )
                                  : CachedNetworkImageProvider(
                                      userInfo!.photoUrl,
                                    ) as ImageProvider,
                        ),
                      ),
                      title: Text(
                        userInfo == null ? "Loading" : userInfo!.username,
                        style: const TextStyle(color: Colors.white),
                      ),
                      // subtitle: Row(
                      //   // ignore: prefer_const_literals_to_create_immutables
                      //   children: [
                      //     const Icon(Icons.call, size: 15, color: Colors.white),
                      //     Text(
                      //       userInfo == null ? "Loading" : userInfo!.contact,
                      //       style: const TextStyle(color: Colors.white),
                      //     )
                      //   ],
                      // ),
                      // trailing: IconButton(
                      //     onPressed: () {
                      //       Navigator.pop(context);
                      //     },
                      //     icon: const Icon(
                      //       Icons.close_rounded,
                      //       color: Colors.red,
                      //     )),
                    ),
                    const SizedBox(height: 50),
                    Expanded(
                      child: Container(
                        // height: size.height / 1.6,
                        decoration: const BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.only(
                                topLeft: Radius.circular(25),
                                topRight: Radius.circular(25))),
                        child: Column(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            mainAxisSize: MainAxisSize.max,
                            // ignore: prefer_const_literals_to_create_immutables
                            children: [
                              Column(
                                children: [
                                  const SizedBox(height: 20),
                                  ListTile(
                                    dense: true,
                                    leading: Container(
                                        decoration: BoxDecoration(
                                            color:
                                                Colors.green.withOpacity(0.2),
                                            borderRadius:
                                                BorderRadius.circular(100)),
                                        width: 45,
                                        height: 45,
                                        child: const Center(
                                            child: Icon(
                                          Icons.folder,
                                          size: 30,
                                          color:
                                              Color.fromARGB(255, 85, 164, 88),
                                        ))),
                                    onTap: () {
                                      Navigator.pop(context);
                                      Navigator.of(context).push(
                                          MaterialPageRoute(
                                              builder: (context) =>
                                                  const DrawerMenuController()));
                                      // Navigator.push(
                                      //     context,
                                      //     MaterialPageRoute(
                                      //         builder: (context) => const MyDoctors()));
                                    },
                                    title: const Text(
                                      "Files",
                                      style: TextStyle(
                                          color: Colors.black,
                                          fontWeight: FontWeight.bold),
                                    ),
                                    trailing: const Icon(
                                      Icons.arrow_forward_ios,
                                      size: 18,
                                      color: Colors.black,
                                    ),
                                  ),
                                  // ListTile(
                                  //   onTap: () {
                                  //     Navigator.pop(context);
                                  //     // Navigator.push(
                                  //     //     context,
                                  //     //     MaterialPageRoute(
                                  //     //         builder: (context) => const AllRecords()));
                                  //   },
                                  //   leading: Container(
                                  //     decoration: BoxDecoration(
                                  //         color: Colors.blue.withOpacity(0.3),
                                  //         borderRadius: BorderRadius.circular(50)),
                                  //     width: 45,
                                  //     height: 45,
                                  //     child: const Center(
                                  //         child: Icon(
                                  //       Icons.notes_outlined,
                                  //       size: 35,
                                  //       color: Colors.blue,
                                  //     )),
                                  //   ),
                                  //   title: const Text(
                                  //     "Notes",
                                  //     style: TextStyle(
                                  //         color: Colors.black,
                                  //         fontWeight: FontWeight.bold),
                                  //   ),
                                  //   trailing: const Icon(
                                  //     Icons.arrow_forward_ios,
                                  //     size: 18,
                                  //     color: Colors.black,
                                  //   ),
                                  // ),
                                  ListTile(
                                    leading: Container(
                                      decoration: BoxDecoration(
                                          color: Colors.red.withOpacity(0.3),
                                          borderRadius:
                                              BorderRadius.circular(50)),
                                      width: 45,
                                      height: 45,
                                      child: const Center(
                                          child: Icon(
                                        Icons.note_alt,
                                        size: 35,
                                        color: Color.fromARGB(255, 171, 70, 70),
                                      )),
                                    ),
                                    onTap: () {
                                      Navigator.pop(context);
                                      Navigator.of(context).push(
                                          MaterialPageRoute(
                                              builder: (context) =>
                                                  const DrawerTodoController()));
                                      // Navigator.push(
                                      //     context,
                                      //     MaterialPageRoute(
                                      //         builder: (context) => const PaymentScreen()));
                                    },
                                    title: const Text(
                                      "To Do",
                                      style: TextStyle(
                                          color: Colors.black,
                                          fontWeight: FontWeight.bold),
                                    ),
                                    trailing: const Icon(
                                      Icons.arrow_forward_ios,
                                      size: 18,
                                      color: Colors.black,
                                    ),
                                  ),
                                ],
                              ),
                              // ListTile(
                              //   leading: Container(
                              //     decoration: BoxDecoration(
                              //         color:
                              //             const Color.fromARGB(255, 249, 236, 122)
                              //                 .withOpacity(0.3),
                              //         borderRadius: BorderRadius.circular(50)),
                              //     width: 45,
                              //     height: 45,
                              //     child: Center(
                              //         child: Icon(
                              //       Icons.lock_clock,
                              //       size: 35,
                              //       color: Colors.yellow.shade900,
                              //     )),
                              //   ),
                              //   onTap: () {
                              //     Navigator.pop(context);
                              //     // Navigator.push(
                              //     //     context,
                              //     //     MaterialPageRoute(
                              //     //         builder: (context) => const PaymentScreen()));
                              //   },
                              //   title: const Text(
                              //     "Reminder",
                              //     style: TextStyle(
                              //         color: Colors.black,
                              //         fontWeight: FontWeight.bold),
                              //   ),
                              //   trailing: const Icon(
                              //     Icons.arrow_forward_ios,
                              //     size: 18,
                              //     color: Colors.black,
                              //   ),
                              // ),
                              Column(
                                children: [
                                  ListTile(
                                    leading: Container(
                                      decoration: BoxDecoration(
                                          color: const Color.fromARGB(
                                                  255, 249, 236, 122)
                                              .withOpacity(0.3),
                                          borderRadius:
                                              BorderRadius.circular(50)),
                                      width: 45,
                                      height: 45,
                                      child: Center(
                                          child: Icon(
                                        Icons.logout_rounded,
                                        size: 35,
                                        color: Colors.yellow.shade900,
                                      )),
                                    ),
                                    onTap: () {
                                      Navigator.pop(context);
                                      AuthMethods().signOut();
                                      Navigator.pushAndRemoveUntil(
                                          context,
                                          MaterialPageRoute(
                                            builder: (context) =>
                                                const LoginScreen(),
                                          ),
                                          ModalRoute.withName('/login'));
                                    },
                                    title: const Text(
                                      "Logout",
                                      style: TextStyle(
                                          color: Colors.black,
                                          fontWeight: FontWeight.bold),
                                    ),
                                    trailing: const Icon(
                                      Icons.arrow_forward_ios,
                                      size: 18,
                                      color: Colors.black,
                                    ),
                                  ),
                                  const SizedBox(height: 20),
                                ],
                              ),
                            ]),
                      ),
                    ),
                  ],
                ),
              ),
            ),
            body: bottomIndex == 0
                ? Column(
                    children: [
                      _TabSwitch(
                        value: pageIndex,
                        callBack: () {
                          setState(() {
                            if (pageIndex == 0) {
                              pageIndex = 1;
                            } else {
                              pageIndex = 0;
                            }
                          });
                        },
                      ),
                      topPages[pageIndex],
                    ],
                  )
                : bottomPages[bottomIndex],
          )),
    );
  }

  _getFloatingButton() {
    return bottomIndex == 1
        ? FloatingActionButton(
            onPressed: () {
              Navigator.of(context).push(
                  MaterialPageRoute(builder: (context) => const AddTask()));
            },
            child: const Icon(Icons.add),
          )
        : Column(
            mainAxisAlignment: MainAxisAlignment.end,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  Transform(
                    transform: Matrix4.translationValues(
                      0,
                      _translateButton.value * 2,
                      0,
                    ),
                    child: Container(
                        height: 150,
                        width: 160,
                        decoration: BoxDecoration(
                            color: whiteColor,
                            borderRadius: BorderRadius.circular(15)),
                        child: Padding(
                          padding: const EdgeInsets.all(8.0),
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              InkWell(
                                onTap: () {
                                  showNewMessage(context);
                                },
                                child: Row(
                                  mainAxisAlignment: MainAxisAlignment.end,
                                  children: const [
                                    Text(
                                      "New Chat",
                                      style: TextStyle(
                                          fontWeight: FontWeight.bold),
                                    ),
                                    Padding(
                                      padding: EdgeInsets.all(8.0),
                                      child: Icon(
                                        Icons.message_rounded,
                                        color: mainColor,
                                      ),
                                    )
                                  ],
                                ),
                              ),
                              InkWell(
                                onTap: () {
                                  showNewCall(context);
                                },
                                child: Row(
                                  mainAxisAlignment: MainAxisAlignment.end,
                                  children: const [
                                    Text(
                                      "New Call",
                                      style: TextStyle(
                                          fontWeight: FontWeight.bold),
                                    ),
                                    Padding(
                                      padding: EdgeInsets.all(8.0),
                                      child: Icon(
                                        Icons.call_rounded,
                                        color: mainColor,
                                      ),
                                    )
                                  ],
                                ),
                              ),
                              InkWell(
                                onTap: () {
                                  Navigator.of(context).push(MaterialPageRoute(
                                      builder: (context) =>
                                          const SearchScreen()));
                                },
                                child: Row(
                                  mainAxisAlignment: MainAxisAlignment.end,
                                  children: const [
                                    Text(
                                      "New Contact",
                                      style: TextStyle(
                                          fontWeight: FontWeight.bold),
                                    ),
                                    Padding(
                                      padding: EdgeInsets.all(8.0),
                                      child: Icon(
                                        Icons.people_rounded,
                                        color: mainColor,
                                      ),
                                    )
                                  ],
                                ),
                              ),
                            ],
                          ),
                        )),
                  ),
                ],
              ),

              // This is the primary FAB
              Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  FloatingActionButton(
                    onPressed: _toggle,
                    child: const Icon(Icons.add),
                  ),
                ],
              ),
            ],
          );
  }
}

class _TabSwitch extends StatefulWidget {
  int value;
  VoidCallback callBack;
  _TabSwitch({Key? key, required this.value, required this.callBack})
      : super(key: key);

  @override
  State<_TabSwitch> createState() => _TabSwitchState();
}

class _TabSwitchState extends State<_TabSwitch> {
  bool isPlay = true;
  @override
  Widget build(BuildContext context) {
    var size = MediaQuery.of(context).size;
    if (widget.value == 0) {
      isPlay = true;
    } else {
      isPlay = false;
    }
    return GestureDetector(
      onTap: widget.callBack,
      child: Container(
        height: 50,
        width: size.width / 1.2,
        decoration: BoxDecoration(
            color: Colors.white, borderRadius: BorderRadius.circular(35)),
        child: Stack(
          children: [
            AnimatedPositioned(
              duration: const Duration(milliseconds: 200),
              left: isPlay ? 0 : size.width / 1.2 * 0.5,
              child: Container(
                height: 50,
                width: size.width / 1.2 * 0.5,
                decoration: BoxDecoration(
                    color: mainColor, borderRadius: BorderRadius.circular(35)),
              ),
            ),
            Row(
              children: [
                Expanded(
                  child: Center(
                    child: Text(
                      "Chats",
                      style: TextStyle(
                          color: isPlay ? Colors.white : mainColor,
                          fontWeight: FontWeight.bold),
                    ),
                  ),
                ),
                Expanded(
                  child: Center(
                    child: Text(
                      "Calls",
                      style: TextStyle(
                          color: isPlay ? mainColor : Colors.white,
                          fontWeight: FontWeight.bold),
                    ),
                  ),
                )
              ],
            ),
          ],
        ),
      ),
    );
  }
}
