import 'package:flutter/material.dart';
import 'package:skype/models/log.dart';
import 'package:skype/resources/local_db/repository/log_repository.dart';
import 'package:skype/screens/callscreens/pickup/pickup_layout.dart';
import 'package:skype/screens/page_views/logs/widgets/floating_column.dart';
import 'package:skype/screens/page_views/logs/widgets/log_list_container.dart';
import 'package:skype/utils/universal_variables.dart';
import 'package:skype/widgets/skype_appbar.dart';

class LogScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return PickupLayout(
      scaffold: Scaffold(
        backgroundColor: UniversalVariables.blackColor,
        appBar: SkypeAppBar(
          title: "Calls",
          actions: <Widget>[
            IconButton(
              icon: Icon(
                Icons.search,
                color: Colors.white,
              ),
              onPressed: () {
                Navigator.pushNamed(context, "/search_screen");
              },
            )
          ],
        ),
        floatingActionButton: FloatingActionColumn(),
        body: Padding(
          padding: EdgeInsets.only(left: 15),
          child: LogListContainer(),
        ),
      ),
    );
  }
}
