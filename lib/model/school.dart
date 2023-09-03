import 'package:flutter/material.dart';

class School {
  School({
    this.id,
    this.name,
    this.type,
    this.location,
    this.openForVote,
    this.openForPoll,
    this.studentCount
  });

  int? id;
  String? name;
  SchoolType? type;   //  MIDDLESCHOOL, HIGHSCHOOL
  String? location;
  bool? openForVote;
  bool? openForPoll;
  int? studentCount;

  factory School.fromJson(Map<String, dynamic> data) {
    SchoolType type;
    if (data['type'] == 'HIGH_SCHOOL') {
      type = SchoolType.high;
    } else {
      type = SchoolType.middle;
    }

    return School(
      id: data['id'],
      name: data['name'],
      type: type,
      location: data['location'],
      openForVote: data['openForVote'],
      openForPoll: data['openForPoll'],
      studentCount: data['studentCount'],
    );
  }

  void printOut() {
    debugPrint('----------  School  -----------');
    debugPrint('---> id: $id');
    debugPrint('---> name: $name');
    debugPrint('---> type: $type');
    debugPrint('---> location: $location');
    debugPrint('---> openForVote: $openForVote');
    debugPrint('---> openForPoll: $openForPoll');
    debugPrint('---> studentCount: $studentCount');
    debugPrint('-----------  end   -----------');
  }
}

enum SchoolType {
  middle('중', '증학교'),
  high('고', '고등학교');

  const SchoolType(this.short, this.name);
  final String name;
  final String short;
}

enum SchoolGrade {
  first('1', '1학년'),
  second('2', '2학년'),
  third('3', '3학년');

  const SchoolGrade(this.num, this.full);
  final String full;
  final String num;
}