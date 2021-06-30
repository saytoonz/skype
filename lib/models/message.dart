import 'package:cloud_firestore/cloud_firestore.dart';

class Message {
  String senderId;
  String receiverId;
  String type;
  String message;
  Timestamp timestmap;
  String photoUrl;

  Message(
      {this.message,
      this.receiverId,
      this.senderId,
      this.timestmap,
      this.type});

  Message.imageMessage(
      {this.message,
      this.photoUrl,
      this.receiverId,
      this.senderId,
      this.timestmap,
      this.type});

  Map toMap() {
    var map = Map<String, dynamic>();
    map["senderId"] = this.senderId;
    map["receiverId"] = this.receiverId;
    map["type"] = this.type;
    map["message"] = this.message;
    map["timestmap"] = this.timestmap;
    return map;
  }

  Map toImageMap() {
    var map = Map<String, dynamic>();
    map["senderId"] = this.senderId;
    map["receiverId"] = this.receiverId;
    map["type"] = this.type;
    map["message"] = this.message;
    map["photoUrl"] = this.photoUrl;
    map["timestmap"] = this.timestmap;
    return map;
  }

  Message.fromMap(Map<String, dynamic> map) {
    this.senderId = map["senderId"];
    this.receiverId = map["receiverId"];
    this.type = map["type"];
    this.message = map["message"];
    this.timestmap = map["timestmap"];
    this.photoUrl = map["photoUrl"];
  }
}
