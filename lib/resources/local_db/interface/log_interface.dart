import 'package:skype/models/log.dart';

abstract class LogInterface {
  openDb(dbName);

  init();

  addLogs(Log log);

  Future<List<Log>> getLogs();

  deleteLogs(int logId);

  close();
}
