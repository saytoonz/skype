import 'package:permission_handler/permission_handler.dart';

class Permissions {
  static Future<bool> cameraAndMicrophonePermissionsGranted() async {
    if (await Permission.camera.status.isGranted &&
        await Permission.microphone.status.isGranted) {
      return true;
    } else {
      Map<Permission, PermissionStatus> statuses = await [
        Permission.microphone,
        Permission.camera,
      ].request();

      if (statuses[Permission.microphone].isGranted &&
          statuses[Permission.camera].isGranted) {
        return true;
      } else {
        return false;
      }
    }
  }
}
