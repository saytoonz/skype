import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:skype/models/contact.dart';
import 'package:skype/models/user.dart';
import 'package:skype/provider/user_provider.dart';
import 'package:skype/resources/auth_methods.dart';
import 'package:skype/resources/chat_methods.dart';
import 'package:skype/screens/chatscreens/chat_screen.dart';
import 'package:skype/screens/chatscreens/widgets/cached_image.dart';
import 'package:skype/screens/page_views/chats/widgets/last_message_container.dart';
import 'package:skype/screens/page_views/chats/widgets/online_dot_indicator.dart';
import 'package:skype/widgets/custom_tile.dart';

class ContactView extends StatelessWidget {
  AuthMethods _authMethods = AuthMethods();
  final Contact contact;
  ContactView(this.contact);

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<UserModel>(
      future: _authMethods.getUserDetailsById(contact.uid),
      builder: (context, AsyncSnapshot<UserModel> snapshot) {
        if (snapshot.hasData) {
          UserModel userModel = snapshot.data;
          return ViewLayout(contact: userModel);
        }
        return Center(
          child: CircularProgressIndicator(),
        );
      },
    );
  }
}

class ViewLayout extends StatelessWidget {
  final UserModel contact;
  ChatMethods _chatMethods = ChatMethods();

  ViewLayout({@required this.contact});

  @override
  Widget build(BuildContext context) {
    UserProvider userProvider = Provider.of<UserProvider>(context);

    return CustomTile(
      mini: false,
      onTap: () => Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => ChatScreen(receiver: contact),
        ),
      ),
      title: Text(
        contact?.name ?? "...",
        style: TextStyle(
          color: Colors.white,
          fontFamily: "Arial",
          fontSize: 19,
        ),
      ),
      subtitle: LastMessageContainer(
          stream: _chatMethods.fetchLastMessageBetween(
              senderId: userProvider.getUserModel.uid,
              receiverId: contact.uid)),
      leading: Container(
        constraints: BoxConstraints(maxHeight: 60, maxWidth: 60),
        child: Stack(
          children: [
            CachedImage(
              contact.profilePhoto,
              radius: 80,
              isRound: true,
            ),
            OnlineDotIndicator(uid: contact.uid),
          ],
        ),
      ),
    );
  }
}
