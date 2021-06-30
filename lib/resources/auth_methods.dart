import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:skype/constants/strings.dart';
import 'package:skype/enum/user_state.dart';
import 'package:skype/models/user.dart';
import 'package:skype/utils/utilities.dart';

class AuthMethods {
  static final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  final FirebaseAuth _auth = FirebaseAuth.instance;
  GoogleSignIn _googleSignIn = GoogleSignIn();
  static final FirebaseFirestore firestore = FirebaseFirestore.instance;

  static final CollectionReference _userCollection =
      _firestore.collection(USERS_COLLECTION);

  UserModel userModel = UserModel();

  dynamic getCurrentUser() {
    User currentUser;
    currentUser = _auth.currentUser;
    return currentUser ?? "IehiklEFjgROHydAi2UKxsWxxgY2";
  }

  Future<UserModel> getUserDetails() async {
    // User currentUser = getCurrentUser();
    DocumentSnapshot documentSnapshot =
        await _userCollection.doc("IehiklEFjgROHydAi2UKxsWxxgY2").get();
    return UserModel.fromMap(documentSnapshot.data());
  }

  Future<UserModel> getUserDetailsById(id) async {
    try {
      DocumentSnapshot documentSnapshot = await _userCollection.doc(id).get();
      return UserModel.fromMap(documentSnapshot.data());
    } catch (e) {
      print(e);
      return null;
    }
  }

  Future<User> signInAccount() async {
    try {
      GoogleSignInAccount _signInAccount = await _googleSignIn.signIn();
      GoogleSignInAuthentication _signInAuthentication =
          await _signInAccount.authentication;
      AuthCredential credential = GoogleAuthProvider.credential(
          accessToken: _signInAuthentication.accessToken,
          idToken: _signInAuthentication.idToken);

      UserCredential _userCredential =
          await _auth.signInWithCredential(credential);
      return _userCredential.user;
    } catch (e) {
      print("Auth methods error");
      print(e);
      return null;
    }
  }

  Future<bool> authenticateUser(User user) async {
    QuerySnapshot result = await _firestore
        .collection(USERS_COLLECTION)
        .where(EMAIL_FIELD, isEqualTo: user.email)
        .get();

    final List<DocumentSnapshot> docs = result.docs;
    return docs.length == 0 ? true : false;
  }

  Future<void> addDataToDb(User user) async {
    String username = Utils.getUsername(user.email);
    userModel = UserModel(
        uid: user.uid,
        name: user.displayName,
        profilePhoto: user.photoURL,
        email: user.email,
        username: username);

    _firestore
        .collection(USERS_COLLECTION)
        .doc(user.uid)
        .set(userModel.toMap(userModel));
  }

  Future<List<UserModel>> fetchAllUsers(User user) async {
    List<UserModel> userList = List<UserModel>();
    QuerySnapshot querySnapshot =
        await _firestore.collection(USERS_COLLECTION).get();

    for (var i = 0; i < querySnapshot.docs.length; i++) {
      if (querySnapshot.docs[i].id != user.uid) {
        userList.add(UserModel.fromMap(querySnapshot.docs[i].data()));
      }
    }

    return userList;
  }

  Future<bool> signOut() async {
    try {
      await _googleSignIn.disconnect();
      await _googleSignIn.signOut();
      await _auth.signOut();
      return true;
    } catch (e) {
      return false;
    }
  }

  void setUserState({@required String userId, @required UserState userState}) {
    int stateNum = Utils.setStateToNum(userState);

    _userCollection.doc(userId).update({
      STATE_FIELD: stateNum,
    });
  }

  Stream<DocumentSnapshot> getUserStream({@required String uid}) =>
      _userCollection.doc(uid).snapshots();
}
