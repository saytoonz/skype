import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:skype/constants/strings.dart';
import 'package:skype/models/contact.dart';
import 'package:skype/models/message.dart';
import 'package:skype/models/user.dart';

class ChatMethods {
  static final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  final CollectionReference _messageCollection =
      _firestore.collection(MESSAGES_COLLECTION);

  final CollectionReference _userCollection =
      _firestore.collection(USERS_COLLECTION);

  Future<void> addMessageToDB(
      Message message, UserModel sender, UserModel receiver) async {
    var map = message.toMap();

    await _messageCollection
        .doc(message.senderId)
        .collection(message.receiverId)
        .add(map);

    addToContacts(senderId: message.senderId, receiverId: message.receiverId);

    await _messageCollection
        .doc(message.receiverId)
        .collection(message.senderId)
        .add(map);
  }

  DocumentReference getContactsDocument({String of, String forContact}) =>
      _userCollection.doc(of).collection(CONTACTS_COLLECTION).doc(forContact);

  addToContacts({String senderId, String receiverId}) async {
    Timestamp currentTime = Timestamp.now();

    await addToSenderContacts(senderId, receiverId, currentTime);
    await addToReceiverContacts(senderId, receiverId, currentTime);
  }

  Future<void> addToSenderContacts(
    String senderId,
    String receiverId,
    currentTime,
  ) async {
    DocumentSnapshot senderSnapshot =
        await getContactsDocument(of: senderId, forContact: receiverId).get();

    if (!senderSnapshot.exists) {
      //does not exists
      Contact receiverContact = Contact(
        uid: receiverId,
        addedOn: currentTime,
      );

      var receiverMap = receiverContact.toMap(receiverContact);

      await getContactsDocument(of: senderId, forContact: receiverId)
          .set(receiverMap);
    }
  }

  Future<void> addToReceiverContacts(
    String senderId,
    String receiverId,
    currentTime,
  ) async {
    DocumentSnapshot receiverSnapshot =
        await getContactsDocument(of: receiverId, forContact: senderId).get();

    if (!receiverSnapshot.exists) {
      //does not exists
      Contact senderContact = Contact(
        uid: senderId,
        addedOn: currentTime,
      );

      var senderMap = senderContact.toMap(senderContact);

      await getContactsDocument(of: receiverId, forContact: senderId)
          .set(senderMap);
    }
  }

  void setImageMessge(String url, String receiverId, String senderId) async {
    Message _message;
    _message = Message.imageMessage(
        message: "IMAGE",
        senderId: senderId,
        receiverId: receiverId,
        photoUrl: url,
        timestmap: Timestamp.now(),
        type: "image");

    var map = _message.toImageMap();

    await _messageCollection
        .doc(_message.senderId)
        .collection(_message.receiverId)
        .add(map);

    await _messageCollection
        .doc(_message.receiverId)
        .collection(_message.senderId)
        .add(map);
  }

  Stream<QuerySnapshot> fetchContacts({String userId}) =>
      _userCollection.doc(userId).collection(CONTACTS_COLLECTION).snapshots();

  Stream<QuerySnapshot> fetchLastMessageBetween({
    @required String senderId,
    @required String receiverId,
  }) =>
      _messageCollection
          .doc(senderId)
          .collection(receiverId)
          .orderBy("timestamp")
          .snapshots();
}
