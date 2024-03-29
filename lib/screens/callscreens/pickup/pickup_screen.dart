import 'package:flutter/material.dart';
import 'package:skype/constants/strings.dart';
import 'package:skype/models/call.dart';
import 'package:skype/models/log.dart';
import 'package:skype/resources/call_methods.dart';
import 'package:skype/resources/local_db/repository/log_repository.dart';
import 'package:skype/screens/callscreens/call_screen.dart';
import 'package:skype/screens/chatscreens/widgets/cached_image.dart';
import 'package:skype/utils/permissions.dart';

class PickupScreen extends StatefulWidget {
  final Call call;

  PickupScreen({this.call});

  @override
  _PickupScreenState createState() => _PickupScreenState();
}

class _PickupScreenState extends State<PickupScreen> {
  final CallMethods callMethods = CallMethods();

  bool isCallMissed = true;

  addToLocalStorage({@required String callStatus}) {
    Log log = Log(
      callerName: widget.call.callerName,
      callerPic: widget.call.callerPic,
      receiverName: widget.call.receiverName,
      receiverPic: widget.call.receiverPic,
      timestamp: DateTime.now().toString(),
      callStatus: callStatus,
    );

    LogRepository.addLogs(log);
  }

  @override
  void dispose() {
    if (isCallMissed) {
      addToLocalStorage(callStatus: CALL_STATUS_MISSED);
    }
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        alignment: Alignment.center,
        padding: EdgeInsets.symmetric(vertical: 100),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              "Incoming...",
              style: TextStyle(fontSize: 30),
            ),
            SizedBox(height: 50),
            CachedImage(
              widget.call.callerPic,
              isRound: true,
              radius: 180,
            ),
            SizedBox(
              height: 15,
            ),
            Text(
              widget.call.callerName,
              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 20),
            ),
            SizedBox(height: 75),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                IconButton(
                  icon: Icon(Icons.call_end),
                  color: Colors.redAccent,
                  onPressed: () async {
                    isCallMissed = false;
                    addToLocalStorage(callStatus: CALL_STATUS_REJECT);
                    return await callMethods.endCall(call: widget.call);
                  },
                ),
                SizedBox(width: 25),
                IconButton(
                  icon: Icon(Icons.call),
                  color: Colors.green,
                  onPressed: () async {
                    isCallMissed = false;
                    addToLocalStorage(callStatus: CALL_STATUS_RECEIVED);
                    return await Permissions
                            .cameraAndMicrophonePermissionsGranted()
                        ? Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) =>
                                  CallScreen(call: widget.call),
                            ),
                          )
                        : {};
                  },
                ),
              ],
            )
          ],
        ),
      ),
    );
  }
}
