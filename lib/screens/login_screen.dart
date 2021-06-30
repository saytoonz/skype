import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:skype/resources/auth_methods.dart';
import 'package:skype/screens/home_screen.dart';
import 'package:shimmer/shimmer.dart';
import 'package:skype/utils/universal_variables.dart';

class LoginScreen extends StatefulWidget {
  @override
  LoginScreenState createState() => LoginScreenState();
}

class LoginScreenState extends State<LoginScreen> {
  AuthMethods _authMethods = AuthMethods();
  bool isLoginPressed = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: UniversalVariables.blackColor,
      body: Stack(children: [
        loginButton(),
        isLoginPressed
            ? Center(child: CircularProgressIndicator())
            : Container(),
      ]),
    );
  }

  Widget loginButton() {
    return Center(
      child: Shimmer.fromColors(
        baseColor: Colors.white,
        highlightColor: UniversalVariables.senderColor,
        child: FlatButton(
          padding: EdgeInsets.all(35.0),
          child: Text(
            "LOGIN",
            style: TextStyle(
                fontSize: 35, fontWeight: FontWeight.w900, letterSpacing: 1.2),
          ),
          onPressed: () => performLogin(),
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
        ),
      ),
    );
  }

  void performLogin() {
    setState(() {
      isLoginPressed = true;
    });
    _authMethods.signInAccount().then((User user) {
      if (user != null) {
        authenticateUser(user);
      } else {
        print("Theere was a signin error....");
      }
    });
  }

  void authenticateUser(User user) {
    _authMethods.authenticateUser(user).then((isNewUser) {
      setState(() {
        isLoginPressed = false;
      });

      if (isNewUser) {
        _authMethods.addDataToDb(user).then((value) {
          Navigator.pushReplacement(context,
              MaterialPageRoute(builder: (context) {
            return HomeScreen();
          }));
        });
      } else {
        Navigator.pushReplacement(context,
            MaterialPageRoute(builder: (context) {
          return HomeScreen();
        }));
      }
    });
  }
}
