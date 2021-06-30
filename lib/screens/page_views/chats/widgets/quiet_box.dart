import 'package:flutter/material.dart';
import 'package:skype/screens/search_screen.dart';
import 'package:skype/utils/universal_variables.dart';

class QuietBox extends StatelessWidget {
  final String heading;
  final String subtitle;

  const QuietBox({Key key, @required this.heading, @required this.subtitle})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: EdgeInsets.symmetric(horizontal: 25),
        child: Container(
          color: UniversalVariables.separatorColor,
          padding: EdgeInsets.symmetric(vertical: 35, horizontal: 25),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Text(
                heading,
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 30,
                ),
              ),
              SizedBox(height: 25),
              Text(
                subtitle,
                textAlign: TextAlign.center,
                style: TextStyle(
                  letterSpacing: 1.2,
                  fontWeight: FontWeight.normal,
                  fontSize: 18,
                ),
              ),
              SizedBox(height: 25),
              FlatButton(
                color: UniversalVariables.blueColor,
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) => SearchScreen()),
                  );
                },
                child: Text("START SEARCHING"),
              )
            ],
          ),
        ),
      ),
    );
  }
}
