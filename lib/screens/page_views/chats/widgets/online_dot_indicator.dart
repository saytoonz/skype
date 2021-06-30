import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:skype/enum/user_state.dart';
import 'package:skype/models/user.dart';
import 'package:skype/resources/auth_methods.dart';
import 'package:skype/utils/utilities.dart';

class OnlineDotIndicator extends StatelessWidget {
  final String uid;
  AuthMethods _authMethods = AuthMethods();

  OnlineDotIndicator({Key key, this.uid}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    getIndicatorColor(int state) {
      switch (Utils.setNumToState(state)) {
        case UserState.Offline:
          return Colors.red;
        case UserState.Online:
          return Colors.green;
        default:
          return Colors.orange;
      }
    }

    return StreamBuilder<DocumentSnapshot>(
      stream: _authMethods.getUserStream(uid: uid),
      builder: (context, snapshot) {
        UserModel userModel;
        if (snapshot.hasData && snapshot.data.data() != null) {
          userModel = UserModel.fromMap(snapshot.data.data());
        }

        return Container(
          height: 10,
          width: 10,
          margin: EdgeInsets.only(right: 8, top: 8),
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: getIndicatorColor(userModel?.state),
          ),
        );
      },
    );
  }
}
