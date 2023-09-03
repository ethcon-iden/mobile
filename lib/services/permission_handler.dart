import 'package:permission_handler/permission_handler.dart';
import 'dart:io';

class PermissionHandler {
  PermissionHandler();

  static Future<bool> contacts() async {
    PermissionStatus? status;

    status = await Permission.contacts.request();
    print('---> Contact permission status: $status');

    if ((Platform.isAndroid && status.isGranted) || (Platform.isIOS && status.isGranted)) {
      return Future.value(true);
    } else {
      return Future.value(false);
    }
  }
  Future<bool> notification() async {
    bool out;

    PermissionStatus? status = await Permission.notification.request();
    print('---> Notification permission status');

    if (status.isGranted) {
      out = true;
    } else {
      out = false;
    }
    return out;
  }

}


