import 'package:cloud_firestore/cloud_firestore.dart';

class UserModel {
  final String uid;
  final String username;
  final String email;
  final String photoUrl;
  final String bio;
  final String contact;
  final String contactEmail;
  final String location;
  final String token;
  final bool isOnline;
  final bool isInCall;
  List blockList;
  List contacts;

  UserModel({
    required this.uid,
    required this.username,
    required this.email,
    required this.photoUrl,
    required this.bio,
    required this.contact,
    required this.contactEmail,
    required this.location,
    required this.token,
    required this.isOnline,
    required this.isInCall,
    required this.blockList,
    required this.contacts,
  });
  Map<String, dynamic> toJson() => {
        'uid': uid,
        'name': username,
        'email': email,
        'photoUrl': photoUrl,
        'bio': bio,
        'contact': contact,
        'contactEmail': contactEmail,
        'location': location,
        'token': token,
        'isOnline': isOnline,
        'isInCall': isInCall,
        'blockList': blockList,
        'contacts': contacts,
      };
  static UserModel getValuesFromSnap(DocumentSnapshot snapshot) {
    var snap = snapshot.data() as Map<String, dynamic>;
    return UserModel(
      uid: snap['uid'],
      username: snap['name'],
      email: snap['email'],
      photoUrl: snap['photoUrl'],
      bio: snap['bio'],
      contact: snap['contact'],
      contactEmail: snap['contactEmail'] ?? "",
      location: snap['location'],
      token: snap['token'],
      isOnline: snap['isOnline'],
      isInCall: snap['isInCall'],
      blockList: snap['blockList'],
      contacts: snap['contacts'],
    );
  }
}
