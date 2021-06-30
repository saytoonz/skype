class UserModel {
  String uid;
  String name;
  String email;
  String username;
  String status;
  int state;
  String profilePhoto;

  UserModel(
      {this.uid,
      this.email,
      this.name,
      this.profilePhoto,
      this.state,
      this.status,
      this.username});

  Map toMap(UserModel user) {
    var data = Map<String, dynamic>();
    data["uid"] = user.uid;
    data["name"] = user.name;
    data["email"] = user.email;
    data["username"] = user.username;
    data["state"] = user.state;
    data["status"] = user.status;
    data["profilePhoto"] = user.profilePhoto;
    return data;
  }

  UserModel.fromMap(Map<String, dynamic> mapData) {
    this.uid = mapData["uid"];
    this.email = mapData["email"];
    this.name = mapData["name"];
    this.profilePhoto = mapData["profilePhoto"];
    this.state = mapData["state"];
    this.status = mapData["status"];
    this.username = mapData["username"];
  }
}
