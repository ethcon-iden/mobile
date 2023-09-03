import 'package:contacts_service/contacts_service.dart';
import 'dart:async';
import 'permission_handler.dart';

import '../services/extensions.dart';
import '../../controller/state_controller.dart';
import '../model/contact.dart';

class ServiceContact {
  ServiceContact();

  static Future<List<Contact>> getContact() async {
    List<Contact> out = [];
    List<String?> displayNames = [];
    // Request contact permission
    final res = await PermissionHandler.contacts();
    if (res) {
      final List<Contact> res = await ContactsService.getContacts();
      if (res.isNotEmpty) {
        for (var e in res) {
          List<String> phones = [];
          bool isMobile = false;
          // bool isDuplicated = false;
          // bool hasInvited = false;
          if (e.phones != null && e.phones!.isNotEmpty) {
            for (var i in e.phones!) {
              if (i.value != null) {
                final res = i.value!.isMobileNumber();
                if (res) {
                  phones.add(i.value!.onlyNumber());
                  isMobile = true;
                }
              }
            }
          }
          // 이름 중복 확인
          // if (e.displayName != null && displayNames.contains(e.displayName)) {
          //   isDuplicated = true;
          // }
          // if (isMobile && !hasInvited) {  // condition: mobile & 초대장 안보낸 친구들
          if (isMobile) {
            out.add(e);
            displayNames.add(e.displayName);
          }
        }
      }
      return out;
    } else {
      return Future.value([]);
    }
  }

  static Future<List<MyContact>> getMyContacts() async {
    List<MyContact> out = [];
    // Request contact permission
    final res = await PermissionHandler.contacts();
    if (res) {
      final List<Contact> res = await ContactsService.getContacts();
      if (res.isNotEmpty) {
        for (var e in res) {
          List<String> phones = [];
          bool isMobile = false;
          if (e.phones != null && e.phones!.isNotEmpty) {
            for (var i in e.phones!) {
              if (i.value != null) {
                final res = i.value!.isMobileNumber();
                if (res) {
                  phones.add(i.value!.onlyNumber());
                  isMobile = true;
                }
              }
            }
          }
          if (isMobile) {
            out.add(
              MyContact(
                displayName: e.displayName,
                phones: phones
              )
            );
          }
        }
      }
      return out;
    } else {
      return Future.value([]);
    }
  }

  static Future<List<Contact>> searchQuery(String name) async {
    List<Contact> out = [];
    List<String?> names = []; // 이름 중복 확인 용
    List<Contact> found = await ContactsService.getContacts(query: name);
    if (found.isNotEmpty) {
      for (var e in found) {
        bool isPhoneAvailable = false;
        bool isDuplicated = false;
        if (e.phones != null && e.phones!.isNotEmpty) {
          for (var i in e.phones!) {
            if (i.value != null) {
              if (!service.buddyInvited.contains(i.value!.onlyNumber())) {   // 이미 초대장을 보낸 친구 제외
                isPhoneAvailable = true;
              }
            }
            if (e.displayName != null && names.contains(e.displayName)) {  // 이름 중복 확인
              isDuplicated = true;
            }
          }
        }
        if (isPhoneAvailable && !isDuplicated) {
          out.add(e);
        }
      }
    }
    return Future.value(out);
  }
}