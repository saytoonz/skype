class Call {
  String callerId;
  String callerName;
  String callerPic;
  String receiverId;
  String receiverName;
  String receiverPic;
  String channelId;
  bool hasDialled;

  Call({
    this.callerId,
    this.callerName,
    this.callerPic,
    this.receiverId,
    this.receiverName,
    this.receiverPic,
    this.channelId,
    this.hasDialled,
  });

  Map<String, dynamic> toMap(Call call) {
    Map<String, dynamic> callMap = Map();
    callMap["callerId"] = call.callerId;
    callMap["callerName"] = call.callerName;
    callMap["callerPic"] = call.callerPic;
    callMap["receiverId"] = call.receiverId;
    callMap["receiverName"] = call.receiverName;
    callMap["receiverPic"] = call.receiverPic;
    callMap["channelId"] = call.channelId;
    callMap["hasDialled"] = call.hasDialled;
    return callMap;
  }

  Call.fromMap(Map map) {
    this.callerId = map["callerId"];
    this.callerName = map["callerName"];
    this.callerPic = map["callerPic"];
    this.receiverId = map["receiverId"];
    this.receiverName = map["receiverName"];
    this.receiverPic = map["receiverPic"];
    this.channelId = map["channelId"];
    this.hasDialled = map["hasDialled"];
  }
}
