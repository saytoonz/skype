import 'dart:io';

import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/widgets.dart';
import 'package:skype/models/user.dart';
import 'package:skype/provider/image_upload_provider.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:skype/resources/chat_methods.dart';

class StorageMethods {
  static final Firestore firestore = Firestore.instance;

  StorageReference _storageReference;

  //user class
  UserModel user = UserModel();

  Future<String> uploadImageToStorage(File imageFile) async {
    // mention try catch later on

    try {
      _storageReference = FirebaseStorage.instance
          .ref()
          .child('${DateTime.now().millisecondsSinceEpoch}');
      StorageUploadTask storageUploadTask =
          _storageReference.putFile(imageFile);
      var url = await (await storageUploadTask.onComplete).ref.getDownloadURL();
      // print(url);
      return url;
    } catch (e) {
      return null;
    }
  }

  void uploadImage({
    @required File image,
    @required String receiverId,
    @required String senderId,
    @required ImageUploadProvider imageUploadProvider,
  }) async {
    final ChatMethods chatMethods = ChatMethods();

    // Set some loading value to db and show it to user
    imageUploadProvider.setLoading();

    // Get url from the image bucket
    String url = await uploadImageToStorage(image);

    // Hide loading
    imageUploadProvider.setIdle();

    chatMethods.setImageMessge(url, receiverId, senderId);
  }
}
