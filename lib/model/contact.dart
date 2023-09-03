import 'dart:typed_data';

class MyContact {
  MyContact({
    this.displayName,
    this.phones
  });

  String? displayName;
  Uint8List? photo;
  Uint8List? thumbnail;
  List<String>? phones;
}

class Name { String? first; String? last; }
class Phone { String? number; }
class Email { String? address;  }
class Address { String? address;  }
class Organization { String? company; String? title; }
class Website { String? url;  }
class SocialMedia { String? userName;  }
class Event { int? year; int? month; int? day; }
class Note { String? note; }
class Group { String? id; String? name; }