import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:image_picker/image_picker.dart';
import 'package:provider/provider.dart';
import 'package:skype/constants/strings.dart';
import 'package:skype/enum/view_state.dart';
import 'package:skype/models/message.dart';
import 'package:skype/models/user.dart';
import 'package:skype/provider/image_upload_provider.dart';
import 'package:skype/resources/auth_methods.dart';
import 'package:skype/resources/chat_methods.dart';
import 'package:skype/resources/storage_methods.dart';
import 'package:skype/screens/chatscreens/widgets/cached_image.dart';
import 'package:skype/utils/call_utilities.dart';
import 'package:skype/utils/permissions.dart';
import 'package:skype/utils/universal_variables.dart';
import 'package:skype/utils/utilities.dart';
import 'package:skype/widgets/appBar.dart';
import 'package:skype/widgets/custom_tile.dart';

class ChatScreen extends StatefulWidget {
  final UserModel receiver;

  const ChatScreen({this.receiver});

  @override
  _ChatScreenState createState() => _ChatScreenState();
}

class _ChatScreenState extends State<ChatScreen> {
  ImageUploadProvider _imageUploadProvider;
  final StorageMethods _storageMethods = StorageMethods();
  final ChatMethods _chatMethods = ChatMethods();
  final AuthMethods _authMethods = AuthMethods();
  TextEditingController textController = TextEditingController();
  UserModel sender;
  String _currentUserId;

  bool isWriting = false;

  @override
  void initState() {
    super.initState();
    String user = _authMethods.getCurrentUser();
    _currentUserId = user;
    sender = UserModel(
      uid: user,
      name: "user.displayName",
      profilePhoto:
          "https://cdn.business2community.com/wp-content/uploads/2017/08/blank-profile-picture-973460_640.png",
    );
  }

  bool showEmojiPicker = false;
  hideEmojiContainer() => setState(() => showEmojiPicker = false);

  onEmojiIconClicked() {
    setState(() {
      showEmojiPicker
          ? SystemChannels.textInput.invokeMethod('TextInput.show')
          : SystemChannels.textInput.invokeMethod('TextInput.hide');

      showEmojiPicker = !showEmojiPicker;
    });
  }

  emojiContainer() {
    return Container();
  }

  @override
  Widget build(BuildContext context) {
    _imageUploadProvider = Provider.of<ImageUploadProvider>(context);
    return SafeArea(
      top: false,
      child: Scaffold(
        backgroundColor: UniversalVariables.blackColor,
        appBar: customAppBar(context),
        body: GestureDetector(
          onTap: () => FocusScope.of(context).unfocus(),
          child: Container(
            color: Colors.grey[900],
            child: Column(
              children: [
                Flexible(child: messageList()),
                _imageUploadProvider.getViewState == ViewState.LOADING
                    ? Container(
                        margin: EdgeInsets.only(right: 15),
                        alignment: Alignment.centerRight,
                        child: CircularProgressIndicator(),
                      )
                    : Container(),
                Container(child: chatControls()),
                SingleChildScrollView(
                  child: emojiContainer(),
                )
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget messageList() {
    return StreamBuilder(
      stream: FirebaseFirestore.instance
          .collection(MESSAGES_COLLECTION)
          .doc(_currentUserId)
          .collection(widget.receiver.uid)
          .orderBy(TIMESTAMP_FIELD, descending: true)
          .snapshots(),
      builder: (context, AsyncSnapshot<QuerySnapshot> snapshot) {
        if (snapshot.data == null) {
          return Center(
            child: CircularProgressIndicator(),
          );
        }

        return ListView.builder(
          padding: EdgeInsets.all(10),
          itemCount: snapshot.data.documents.length,
          reverse: true,
          itemBuilder: (context, index) {
            return chatMessageItem(snapshot.data.documents[index]);
          },
        );
      },
    );
  }

  Widget chatMessageItem(DocumentSnapshot snapshot) {
    Message _message = Message.fromMap(snapshot.data());

    return Container(
      margin: EdgeInsets.symmetric(vertical: 15),
      child: Container(
        alignment: (_message.senderId == _currentUserId)
            ? Alignment.centerRight
            : Alignment.centerLeft,
        child: (_message.senderId == _currentUserId)
            ? senderLayout(_message)
            : receiverLayout(_message),
      ),
    );
  }

  Widget senderLayout(Message message) {
    Radius messageRadius = Radius.circular(10);
    return Container(
      margin: EdgeInsets.only(top: 12),
      constraints: BoxConstraints(
        maxWidth: MediaQuery.of(context).size.width * 0.65,
      ),
      decoration: BoxDecoration(
        color: UniversalVariables.senderColor,
        borderRadius: BorderRadius.only(
          topLeft: messageRadius,
          topRight: messageRadius,
          bottomLeft: messageRadius,
        ),
      ),
      child: Padding(
        padding: EdgeInsets.all(10),
        child: getMessage(message),
      ),
    );
  }

  Widget getMessage(Message message) {
    return message.type != MESSAGE_TYPE_IMAGE
        ? Text(
            message != null ? message.message : "",
            style: TextStyle(
              color: Colors.white,
              fontSize: 16,
            ),
          )
        : message.photoUrl != null
            ? CachedImage(
                message.photoUrl,
                height: 250,
                width: 250,
                radius: 10,
              )
            : Text("Url is null");
  }

  Widget receiverLayout([Message message]) {
    Radius messageRadius = Radius.circular(10);
    return Container(
      margin: EdgeInsets.only(top: 12),
      constraints: BoxConstraints(
        maxWidth: MediaQuery.of(context).size.width * 0.65,
      ),
      decoration: BoxDecoration(
        color: UniversalVariables.receiverColor,
        borderRadius: BorderRadius.only(
          bottomLeft: messageRadius,
          topRight: messageRadius,
          bottomRight: messageRadius,
        ),
      ),
      child: Padding(
        padding: EdgeInsets.all(10),
        child: getMessage(message),
      ),
    );
  }

  Widget chatControls() {
    setWritingTo(bool val) {
      setState(() {
        isWriting = val;
      });
    }

    addMediaModle(BuildContext context) {
      showModalBottomSheet(
        context: context,
        elevation: 0,
        backgroundColor: UniversalVariables.blackColor,
        builder: (context) {
          return Column(
            children: [
              Container(
                padding: EdgeInsets.symmetric(vertical: 10),
                child: Row(
                  children: [
                    FlatButton(
                      onPressed: () => Navigator.maybePop(context),
                      child: Icon(Icons.close),
                    ),
                    Expanded(
                      child: Align(
                        alignment: Alignment.centerLeft,
                        child: Text(
                          "Content and Tools",
                          style: TextStyle(
                              color: Colors.white,
                              fontSize: 20,
                              fontWeight: FontWeight.bold),
                        ),
                      ),
                    )
                  ],
                ),
              ),
              Flexible(
                child: ListView(
                  children: [
                    ModelTile(
                      onTap: () => pickImage(source: ImageSource.gallery),
                      title: "Media",
                      subtitle: "Share photos and videos",
                      icon: Icons.image,
                    ),
                    ModelTile(
                      title: "File",
                      subtitle: "Share files",
                      icon: Icons.tab,
                    ),
                    ModelTile(
                      title: "Contact",
                      subtitle: "Share contacts",
                      icon: Icons.contacts,
                    ),
                    ModelTile(
                      title: "Location",
                      subtitle: "Share a location",
                      icon: Icons.add_location,
                    ),
                    ModelTile(
                      title: "Schedule a Call",
                      subtitle: "Arrange a skype call and get remiders",
                      icon: Icons.schedule,
                    ),
                    ModelTile(
                      title: "Create poll",
                      subtitle: "Share polls",
                      icon: Icons.poll,
                    ),
                  ],
                ),
              )
            ],
          );
        },
      );
    }

    return Container(
      padding: EdgeInsets.all(10),
      child: Row(
        children: [
          GestureDetector(
            child: Container(
              padding: EdgeInsets.all(5),
              decoration: BoxDecoration(
                  gradient: UniversalVariables.fabGradient,
                  shape: BoxShape.circle),
              child: Icon(Icons.add),
            ),
            onTap: () => addMediaModle(context),
          ),
          SizedBox(width: 5),
          Expanded(
            child: Stack(
              children: [
                TextField(
                  // focusNode: textFieldFocus,
                  controller: textController,
                  onTap: () => hideEmojiContainer(),
                  style: TextStyle(color: Colors.white),
                  onChanged: (value) {
                    (value.length > 0 && value.trim() != "")
                        ? setWritingTo(true)
                        : setWritingTo(false);
                  },
                  decoration: InputDecoration(
                    hintText: "Type a message",
                    hintStyle: TextStyle(
                      color: UniversalVariables.greyColor,
                    ),
                    border: OutlineInputBorder(
                      borderRadius: const BorderRadius.all(
                        const Radius.circular(50.0),
                      ),
                      borderSide: BorderSide.none,
                    ),
                    contentPadding:
                        EdgeInsets.symmetric(horizontal: 20, vertical: 5),
                    filled: true,
                    fillColor: UniversalVariables.separatorColor,
                  ),
                ),
                IconButton(
                  alignment: Alignment.centerRight,
                  splashColor: Colors.transparent,
                  highlightColor: Colors.transparent,
                  icon: showEmojiPicker
                      ? Icon(Icons.keyboard)
                      : Icon(Icons.insert_emoticon),
                  onPressed: () => onEmojiIconClicked(),
                ),
              ],
            ),
          ),
          isWriting
              ? Container()
              : Padding(
                  padding: EdgeInsets.symmetric(horizontal: 10),
                  child: Icon(Icons.record_voice_over),
                ),
          isWriting
              ? Container()
              : GestureDetector(
                  onTap: () => pickImage(source: ImageSource.camera),
                  child: Icon(Icons.camera_alt)),
          isWriting
              ? Container(
                  margin: EdgeInsets.only(left: 10),
                  decoration: BoxDecoration(
                    gradient: UniversalVariables.fabGradient,
                    shape: BoxShape.circle,
                  ),
                  child: IconButton(
                    icon: Icon(
                      Icons.send,
                      size: 15,
                    ),
                    onPressed: () => sendMessage(),
                  ),
                )
              : Container(),
        ],
      ),
    );
  }

  pickImage({@required ImageSource source}) async {
    File selectedImage = await Utils.pickImage(source: source);
    _storageMethods.uploadImage(
        image: selectedImage,
        receiverId: widget.receiver.uid,
        senderId: _currentUserId,
        imageUploadProvider: _imageUploadProvider);
  }

  sendMessage() {
    var text = textController.text;

    Message _message = Message(
        receiverId: widget.receiver.uid,
        senderId: sender.uid,
        message: text,
        type: "text",
        timestmap: Timestamp.now());

    setState(() {
      isWriting = false;
      textController.clear();
    });
    _chatMethods.addMessageToDB(_message, sender, widget.receiver);
  }

  CustomAppBar customAppBar(BuildContext context) {
    return CustomAppBar(
      leading: IconButton(
        icon: Icon(
          Icons.arrow_back,
        ),
        onPressed: () => Navigator.pop(context),
      ),
      centerTitle: false,
      title: Text(widget.receiver.name),
      actions: [
        IconButton(
          icon: Icon(Icons.video_call),
          onPressed: () async =>
              await Permissions.cameraAndMicrophonePermissionsGranted()
                  ? CallUtils.dail(
                      from: sender,
                      to: widget.receiver,
                      context: context,
                    )
                  : {},
        ),
        IconButton(
          icon: Icon(Icons.phone),
          onPressed: () {},
        ),
      ],
    );
  }
}

class ModelTile extends StatelessWidget {
  final String title;
  final String subtitle;
  final IconData icon;
  final Function onTap;
  const ModelTile(
      {@required this.title,
      @required this.subtitle,
      @required this.icon,
      this.onTap});

  @override
  Widget build(BuildContext context) {
    return Container(
      child: Padding(
        padding: EdgeInsets.symmetric(horizontal: 15),
        child: CustomTile(
          onTap: onTap,
          mini: false,
          leading: Container(
            margin: EdgeInsets.only(right: 10),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(15),
              color: UniversalVariables.receiverColor,
            ),
            padding: EdgeInsets.all(10),
            child: Icon(
              icon,
              color: UniversalVariables.greyColor,
              size: 38,
            ),
          ),
          subtitle: Text(
            subtitle,
            style: TextStyle(
              color: UniversalVariables.greyColor,
              fontSize: 14,
            ),
          ),
          title: Text(
            title,
            style: TextStyle(
              fontWeight: FontWeight.bold,
              color: Colors.white,
              fontSize: 18,
            ),
          ),
        ),
      ),
    );
  }
}
