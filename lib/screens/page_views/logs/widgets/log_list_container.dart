import 'package:flutter/material.dart';
import 'package:skype/constants/strings.dart';
import 'package:skype/models/log.dart';
import 'package:skype/resources/local_db/repository/log_repository.dart';
import 'package:skype/screens/chatscreens/widgets/cached_image.dart';
import 'package:skype/screens/page_views/chats/widgets/quiet_box.dart';
import 'package:skype/utils/utilities.dart';
import 'package:skype/widgets/custom_tile.dart';

class LogListContainer extends StatefulWidget {
  const LogListContainer({Key key}) : super(key: key);

  @override
  _LogListContainerState createState() => _LogListContainerState();
}

class _LogListContainerState extends State<LogListContainer> {
  @override
  Widget build(BuildContext context) {
    getIcon(String callStatus) {
      Icon _icon;
      double _iconSize = 15;

      switch (callStatus) {
        case CALL_STATUS_DIALLED:
          _icon = Icon(
            Icons.call_made,
            size: _iconSize,
            color: Colors.green,
          );
          break;

        case CALL_STATUS_MISSED:
          _icon = Icon(
            Icons.call_missed,
            color: Colors.red,
            size: _iconSize,
          );
          break;

        case CALL_STATUS_REJECT:
          _icon = Icon(
            Icons.timelapse,
            color: Colors.red,
            size: _iconSize,
          );
          break;

        default:
          _icon = Icon(
            Icons.call_received,
            size: _iconSize,
            color: Colors.grey,
          );
          break;
      }

      return Container(
        margin: EdgeInsets.only(right: 5),
        child: _icon,
      );
    }

    return FutureBuilder(
      future: LogRepository.getLogs(),
      builder: (context, AsyncSnapshot<dynamic> snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return Center(
            child: CircularProgressIndicator(),
          );
        }

        if (snapshot.hasData) {
          List<dynamic> logList = snapshot.data;
          if (logList.isNotEmpty) {
            ListView.builder(
              itemCount: logList.length,
              itemBuilder: (context, index) {
                Log _log = logList[index];
                bool hasDailed = _log.callStatus == CALL_STATUS_DIALLED;
                return CustomTile(
                  leading: CachedImage(
                    hasDailed ? _log.receiverPic : _log.callerPic,
                    isRound: true,
                    radius: 80,
                  ),
                  mini: false,
                  title: Text(
                    hasDailed ? _log.receiverName : _log.callerName,
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 20,
                    ),
                  ),
                  icon: getIcon(_log.callStatus),
                  subtitle: Text(
                    Utils.formatDateString(_log.timestamp),
                    style: TextStyle(
                      fontSize: 13,
                    ),
                  ),
                  onLongPress: () => showDialog(
                    context: context,
                    builder: (context) => AlertDialog(
                      title: Text("Delete this log?"),
                      content:
                          Text("Are you sure you wish to delete this log?"),
                      actions: [
                        FlatButton(
                          child: Text("YES"),
                          onPressed: () async {
                            Navigator.maybePop(context);
                            await LogRepository.deleteLogs(index);
                            if (mounted) {
                              setState(() {});
                            }
                          },
                        ),
                        FlatButton(
                          child: Text("NO"),
                          onPressed: () => Navigator.maybePop(context),
                        ),
                      ],
                    ),
                  ),
                );
              },
            );
          }
          return QuietBox(
            heading: "This is where all your call logs are listed",
            subtitle: "Calling people all over the world with just one click",
          );
        }

        return Center(
          child: QuietBox(
            heading: "This is where all your call logs are listed",
            subtitle: "Calling people all over the world with just one click",
          ),
        );
      },
    );
  }
}
