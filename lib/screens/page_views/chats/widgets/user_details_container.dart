import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:skype/models/user.dart';
import 'package:skype/provider/user_provider.dart';
import 'package:skype/resources/auth_methods.dart';
import 'package:skype/screens/chatscreens/widgets/cached_image.dart';
import 'package:skype/screens/login_screen.dart';
import 'package:skype/screens/page_views/chats/widgets/shimmering_logo.dart';
import 'package:skype/widgets/appBar.dart';

class UserDetailsContainer extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    signOut() async {
      bool isLogOut = await AuthMethods().signOut();

      if (isLogOut) {
        Navigator.pushAndRemoveUntil(
            context,
            MaterialPageRoute(
              builder: (context) => LoginScreen(),
            ),
            (route) => false);
      }
    }

    return Container(
      margin: EdgeInsets.only(top: 25),
      child: Column(
        children: [
          CustomAppBar(
            title: ShimmeringLogo(),
            leading: IconButton(
              icon: Icon(
                Icons.arrow_back,
                color: Colors.white,
              ),
              onPressed: () => Navigator.maybePop(context),
            ),
            centerTitle: true,
            actions: [
              FlatButton(
                  onPressed: () => signOut(),
                  child: Text(
                    "Sign Out",
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 14,
                    ),
                  ))
            ],
          ),
          UserDetailsBody(),
        ],
      ),
    );
  }
}

class UserDetailsBody extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    UserProvider userProvider = Provider.of<UserProvider>(context);
    final UserModel userModel = userProvider.getUserModel;

    return Container(
      padding: EdgeInsets.symmetric(vertical: 20, horizontal: 20),
      child: Row(
        children: [
          CachedImage(
            userModel.profilePhoto,
            isRound: true,
            radius: 50,
          ),
          SizedBox(width: 15),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                userModel.name,
                style: TextStyle(
                  fontSize: 18,
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                ),
              ),
              SizedBox(height: 10),
              Text(
                userModel.name,
                style: TextStyle(
                  fontSize: 14,
                  color: Colors.white,
                ),
              ),
            ],
          )
        ],
      ),
    );
  }
}
