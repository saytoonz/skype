import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:gradient_app_bar/gradient_app_bar.dart';
import 'package:skype/models/user.dart';
import 'package:skype/resources/auth_methods.dart';
import 'package:skype/screens/chatscreens/chat_screen.dart';
import 'package:skype/utils/universal_variables.dart';
import 'package:skype/widgets/custom_tile.dart';

class SearchScreen extends StatefulWidget {
  @override
  _SearchScreenState createState() => _SearchScreenState();
}

class _SearchScreenState extends State<SearchScreen> {
  AuthMethods _authMethods = AuthMethods();
  List<UserModel> userList = List<UserModel>();
  String query = "";

  TextEditingController searchController = TextEditingController();

  @override
  void initState() {
    super.initState();

    User user = _authMethods.getCurrentUser();
    _authMethods.fetchAllUsers(user).then((List<UserModel> list) {
      setState(() {
        userList = list;
      });
    });
  }

  searchAppBar(BuildContext context) {
    return GradientAppBar(
      gradient: LinearGradient(colors: [
        UniversalVariables.gradientColorStart,
        UniversalVariables.gradientColorEnd
      ]),
      leading: IconButton(
        icon: Icon(
          Icons.arrow_back,
          color: Colors.white,
        ),
        onPressed: () => Navigator.pop(context),
      ),
      elevation: 0,
      bottom: PreferredSize(
        preferredSize: const Size.fromHeight(kToolbarHeight + 20),
        child: Padding(
          padding: EdgeInsets.only(left: 20),
          child: TextField(
            controller: searchController,
            onChanged: (value) {
              setState(() {
                query = value;
              });
            },
            cursorColor: UniversalVariables.blackColor,
            autofocus: true,
            style: TextStyle(
              fontWeight: FontWeight.bold,
              color: Colors.white,
              fontSize: 35,
            ),
            decoration: InputDecoration(
              suffixIcon: IconButton(
                icon: Icon(
                  Icons.close,
                  color: Colors.white,
                ),
                onPressed: () {
                  WidgetsBinding.instance
                      .addPostFrameCallback((_) => searchController.clear());
                },
              ),
              border: InputBorder.none,
              hintText: "Search",
              hintStyle: TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 35,
                color: Color(0x88ffffff),
              ),
            ),
          ),
        ),
      ),
    );
  }

  buildSuggestions(String query) {
    final List<UserModel> suggestionList = query.isEmpty || userList.length < 1
        ? []
        : userList.where((UserModel user) {
            String _getUsername = user.username.toLowerCase();
            String _getName = user.name.toLowerCase();
            String _query = query.toLowerCase();
            bool matchUsername = _getUsername.contains(_query);
            bool matchName = _getName.contains(_query);

            return (matchName || matchUsername);
            // => (user.username.toLowerCase().contains(query.toLowerCase()) ||
            // user.name.toLowerCase().contains(query.toLowerCase()))
          }).toList();

    return ListView.builder(
      itemCount: suggestionList.length,
      itemBuilder: (context, index) {
        UserModel searchedUser = UserModel(
          uid: suggestionList[index].uid,
          name: suggestionList[index].name,
          username: suggestionList[index].username,
          profilePhoto: suggestionList[index].profilePhoto,
        );

        return CustomTile(
            mini: false,
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => ChatScreen(
                    receiver: searchedUser,
                  ),
                ),
              );
            },
            leading: CircleAvatar(
              backgroundImage: NetworkImage(searchedUser.profilePhoto),
              backgroundColor: Colors.grey,
            ),
            title: Text(
              searchedUser.username,
              style: TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.bold,
              ),
            ),
            subtitle: Text(
              searchedUser.name,
              style: TextStyle(color: UniversalVariables.greyColor),
            ));
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: UniversalVariables.blackColor,
      appBar: searchAppBar(context),
      body: Container(
        padding: EdgeInsets.symmetric(horizontal: 20),
        child: buildSuggestions(query),
      ),
    );
  }
}
