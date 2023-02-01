import 'dart:developer';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:yourteam/constants/colors.dart';
import 'package:yourteam/constants/constant_utils.dart';
import 'package:yourteam/constants/constants.dart';
import 'package:yourteam/models/user_model.dart';

class SearchScreen extends StatefulWidget {
  const SearchScreen({super.key});

  @override
  State<SearchScreen> createState() => _SearchScreenState();
}

class _SearchScreenState extends State<SearchScreen> {
  List<UserModel> usersList = [];
  bool isLoading = false;

  void onSearch(searchText) async {
    setState(() {
      isLoading = true;
    });
    log(searchText);
    await firebaseFirestore
        .collection('users')
        .where("name", isGreaterThanOrEqualTo: searchText)
        .limit(10)
        .get()
        .then((value) {
      usersList.clear();
      for (var elements in value.docs) {
        var val = UserModel.getValuesFromSnap(elements);
        if (val.uid != firebaseAuth.currentUser!.uid) {
          usersList.add(val);
        }
      }
      setState(() {
        isLoading = false;
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;

    return Scaffold(
        backgroundColor: scaffoldBackgroundColor,
        appBar: AppBar(
          foregroundColor: Colors.black,
          backgroundColor: Colors.transparent,
          automaticallyImplyLeading: true,
          title: const Text("Search Users"),
          elevation: 0,
        ),
        body: SingleChildScrollView(
          child: Column(
            children: [
              Padding(
                padding: const EdgeInsets.all(20.0),
                child: Card(
                  elevation: 0.0,
                  margin: EdgeInsets.zero,
                  child: Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: TextFormField(
                      // controller: _search,
                      onChanged: (value) => onSearch(value),
                      cursorColor: mainColor,
                      style: const TextStyle(color: Colors.black),
                      decoration: InputDecoration(
                        prefixIcon: const Icon(
                          Icons.search,
                          size: 24,
                          color: mainColor,
                        ),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(5),
                          borderSide: const BorderSide(
                            color: whiteColor,
                          ),
                        ),
                        enabledBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(5),
                          borderSide: const BorderSide(
                            color: whiteColor,
                          ),
                        ),
                        focusedBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(5),
                          borderSide: const BorderSide(
                            color: whiteColor,
                          ),
                        ),
                        hintStyle: const TextStyle(
                          color: mainColor,
                          fontSize: 12.0,
                        ),
                        fillColor: whiteColor,
                        filled: true,
                        hintText: "Search",
                        isDense: true,
                        contentPadding: const EdgeInsets.all(10),
                      ),
                    ),
                  ),
                ),
              ),
              isLoading
                  ? Center(
                      child: SizedBox(
                        height: size.height / 20,
                        width: size.height / 20,
                        child: const CircularProgressIndicator(),
                      ),
                    )
                  : usersList.isEmpty
                      ? Container()
                      : ListView.builder(
                          itemCount: usersList.length,
                          physics: const NeverScrollableScrollPhysics(),
                          shrinkWrap: true,
                          itemBuilder: ((context, index) {
                            return Padding(
                              padding: const EdgeInsets.all(8.0),
                              child: InkWell(
                                onTap: () {
                                  showAddToContact(context, usersList[index]);
                                },
                                child: ListTile(
                                  tileColor: Colors.white60,
                                  leading: CircleAvatar(
                                      backgroundImage:
                                          CachedNetworkImageProvider(
                                              usersList[index].photoUrl)),
                                  title: Text(
                                    usersList[index].username,
                                    style: const TextStyle(
                                        fontSize: 18, color: Colors.black),
                                  ),
                                  subtitle: Text(
                                    usersList[index].bio,
                                    style: const TextStyle(
                                        fontSize: 13, color: Colors.black),
                                  ),
                                  trailing: const Icon(Icons.arrow_forward_ios),
                                ),
                              ),
                            );
                          }))
            ],
          ),
        ));
  }
}
