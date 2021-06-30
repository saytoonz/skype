import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import 'package:provider/provider.dart';
import 'package:skype/enum/user_state.dart';
import 'package:skype/provider/user_provider.dart';
import 'package:skype/resources/auth_methods.dart';
import 'package:skype/resources/local_db/repository/log_repository.dart';
import 'package:skype/screens/callscreens/pickup/pickup_layout.dart';
import 'package:skype/screens/page_views/chat_list_screen.dart';
import 'package:skype/screens/page_views/logs/logs_screen.dart';
import 'package:skype/utils/universal_variables.dart';

class HomeScreen extends StatefulWidget {
  @override
  _HomeScreenState createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> with WidgetsBindingObserver {
  PageController pageController;
  int _page = 0;
  double _lableFontSize = 10;

  UserProvider userProvider;
  AuthMethods _authMethods = AuthMethods();

  @override
  void initState() {
    super.initState();

    SchedulerBinding.instance.addPostFrameCallback((_) async {
      userProvider = Provider.of<UserProvider>(context, listen: false);
      await userProvider.refreshUser();

      _authMethods.setUserState(
        userId: userProvider.getUserModel.uid,
        userState: UserState.Online,
      );

      LogRepository.init(
        isHive: true,
        dbName: userProvider.getUserModel.uid,
      );
    });

    WidgetsBinding.instance.addObserver(this);

    pageController = PageController();
  }

  @override
  void dispose() {
    super.dispose();
    WidgetsBinding.instance.removeObserver(this);
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    String currentUserId =
        (userProvider != null && userProvider.getUserModel != null)
            ? userProvider.getUserModel.uid
            : "";

    super.didChangeAppLifecycleState(state);

    switch (state) {
      case AppLifecycleState.resumed:
        currentUserId != null
            ? _authMethods.setUserState(
                userId: currentUserId, userState: UserState.Online)
            : print("Resumed state");
        break;

      case AppLifecycleState.inactive:
        currentUserId != null
            ? _authMethods.setUserState(
                userId: currentUserId, userState: UserState.Offline)
            : print("Inactive state");
        break;

      case AppLifecycleState.paused:
        currentUserId != null
            ? _authMethods.setUserState(
                userId: currentUserId, userState: UserState.Waiting)
            : print("Pause state");
        break;

      case AppLifecycleState.detached:
        currentUserId != null
            ? _authMethods.setUserState(
                userId: currentUserId, userState: UserState.Offline)
            : print("Detached state");
        break;
    }
  }

  void onPageChanged(int page) {
    setState(() {
      _page = page;
    });
  }

  void navigationTap(int page) {
    pageController.jumpToPage(page);
  }

  @override
  Widget build(BuildContext context) {
    return PickupLayout(
      scaffold: Scaffold(
        backgroundColor: UniversalVariables.blackColor,
        body: PageView(
          children: [
            ChatListScreen(),
            LogScreen(),
            Center(child: Text("Contacts")),
          ],
          controller: pageController,
          onPageChanged: onPageChanged,
          physics: NeverScrollableScrollPhysics(),
        ),
        bottomNavigationBar: Container(
          child: Padding(
            padding: EdgeInsets.symmetric(vertical: 10),
            child: CupertinoTabBar(
              backgroundColor: UniversalVariables.blackColor,
              items: <BottomNavigationBarItem>[
                createNavItem(0, "Chat", Icons.chat),
                createNavItem(1, "Call", Icons.call),
                createNavItem(2, "Contacts", Icons.contacts),
              ],
              onTap: navigationTap,
              currentIndex: _page,
            ),
          ),
        ),
      ),
    );
  }

  BottomNavigationBarItem createNavItem(
      int selectedInt, String title, IconData icon) {
    return BottomNavigationBarItem(
      icon: Icon(
        icon,
        color: (_page == selectedInt)
            ? UniversalVariables.lightBlueColor
            : UniversalVariables.greyColor,
      ),
      title: Text(
        title,
        style: TextStyle(
          fontSize: _lableFontSize,
          color: (_page == selectedInt)
              ? UniversalVariables.lightBlueColor
              : Colors.grey,
        ),
      ),
    );
  }
}
