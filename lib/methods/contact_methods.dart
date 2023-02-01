import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:yourteam/constants/constants.dart';

class ContactMethods {
  Future<String> addContact(String receiverUid) async {
    String res = "Some error occurred";
    try {
      var ref = firebaseFirestore
          .collection("users")
          .doc(firebaseAuth.currentUser?.uid);

      DocumentSnapshot snapshot = await ref.get();
      if ((snapshot.data()! as dynamic)['contacts'].contains(receiverUid)) {
        await ref.update({
          'contacts': FieldValue.arrayRemove([receiverUid]),
        });
        showToastMessage("Contact Removed Successfully");
      } else {
        await ref.update({
          'contacts': FieldValue.arrayUnion([receiverUid]),
        });
        showToastMessage("Contact Added Successfully");
      }
      res = 'success';
    } catch (err) {
      res = err.toString();
    }
    return res;
  }
}
