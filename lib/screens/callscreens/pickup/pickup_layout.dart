import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:skype/models/call.dart';
import 'package:skype/provider/user_provider.dart';
import 'package:skype/resources/call_methods.dart';
import 'package:skype/screens/callscreens/pickup/pickup_screen.dart';

class PickupLayout extends StatelessWidget {
  final Widget scaffold;
  final CallMethods callMethods = CallMethods();

  PickupLayout({Key key, @required this.scaffold}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final UserProvider userProvider = Provider.of<UserProvider>(context);
    return (userProvider != null && userProvider.getUserModel != null)
        ? StreamBuilder<DocumentSnapshot>(
            stream: callMethods.callStream(uid: userProvider.getUserModel.uid),
            builder: (context, snapshot) {
              if (snapshot.hasData && snapshot.data.data() != null) {
                Call call = Call.fromMap(snapshot.data.data());
                if (!call.hasDialled) {
                  return PickupScreen(call: call);
                }
                return scaffold;
              }
              return scaffold;
            },
          )
        : Scaffold(
            body: Center(
              child: CircularProgressIndicator(),
            ),
          );
  }
}
