import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:skype/constants/strings.dart';
import 'package:skype/models/call.dart';

class CallMethods {
  final CollectionReference callCollection =
      FirebaseFirestore.instance.collection(CALL_COLLECTION);

  Stream<DocumentSnapshot> callStream({String uid}) =>
      callCollection.doc(uid).snapshots();

  Future<bool> makeCall({Call call}) async {
    try {
      call.hasDialled = true;
      Map<String, dynamic> hasDailledMap = call.toMap(call);
      call.hasDialled = false;
      Map<String, dynamic> hasNotDailledMap = call.toMap(call);

      await callCollection.doc(call.callerId).set(hasDailledMap);
      await callCollection.doc(call.receiverId).set(hasNotDailledMap);
      return true;
    } catch (e) {
      print(e);
      return false;
    }
  }

  Future<bool> endCall({Call call}) async {
    try {
      await callCollection.doc(call.callerId).delete();
      await callCollection.doc(call.receiverId).delete();
      return true;
    } catch (e) {
      print(e);
      return false;
    }
  }
}
