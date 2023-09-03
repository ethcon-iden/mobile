import 'package:flutter/material.dart';

import '../../resource/kConstant.dart';
import '../model/omg_pass.dart';
import 'school.dart';
import '../controller/state_controller.dart';

class User {
  User({
    this.id,
    this.name,
    this.nickname,
    this.grade,
    this.bio,
    this.schoolId,
    this.gender,
    this.classNo,
    this.phoneNumber,
    this.profileImageKey,
    this.createdAt,
    this.updatedAt,
    this.lastLoginAt,
    this.deletedAt,
    this.roles,
    this.school,
    this.omgPassStatus,
    this.followerCount,
    this.followingCount,
    this.relationship,
    this.userId,
    this.commonFollowingCount,
    this.affiliation,
    this.duty,
    this.identityTitle,
    this.identityContent,
    this.identityReliability
  });

  String? id;     // uid from server
  String? name;   // 실명
  String? nickname;   // 닉네임
  String? grade;  //  M1, M2, M3, H1, H2, H3
  String? bio;
  int? schoolId;   // school uuid
  Gender? gender;     // male, female
  int? classNo;   // 반 번호
  String? phoneNumber;
  String? profileImageKey;
  String? createdAt;
  String? updatedAt;
  DateTime? lastLoginAt; // if necessary
  DateTime? deletedAt;
  List<UserRole>? roles;
  // OmgPass? omgPass;
  School? school;
  String? omgPassStatus;
  int? followerCount;   // 나룰 추가한 친구
  int? followingCount;  // 내가 추가한 친구
  Relationship? relationship;
  String? userId;
  String? commonFollowingCount;
  String? affiliation;
  String? duty;
  String? identityTitle;
  String? identityContent;
  int? identityReliability;

  factory User.fromJson(Map<String, dynamic> data) {
    Gender? gender;
    if (data['gender'] == 'female') {
      gender = Gender.female;
    } else if (data['gender'] == 'male') {
      gender = Gender.male;
    }

    List<UserRole> userRoles = [];
    if (data['roles'] != null && data['roles'].isNotEmpty) {
      for (var e in data['roles']) {
        if (e == 'USER') {
          userRoles.add(UserRole.user);
        }
      }
    }

    School? schoolData;
    if (data['school'] != null) {
      schoolData = School.fromJson(data['school']);
    }

    String? profileImage;
    if (data['profileImageKey'] != null) {
      profileImage = '${kConst.bucket}/${data['profileImageKey']}';
    }

    Relationship relationship;
    String? relation = data['relationship'];
    if (relation == 'ME') {
      relationship = Relationship.me;
    } else if (relation == 'FOLLOWING') {
      relationship = Relationship.following;
    } else if (relation == 'FAVORITE') {
      relationship = Relationship.favorite;
    } else {
      relationship = Relationship.none;
    }

    return User(
        id: data['id'],
        name: data['name'],
        nickname: data['nickname'],
        grade: data['grade'],
        bio: data['bio'],
        schoolId: data['schoolId'],
        gender: gender,
        classNo: data['class'],
        phoneNumber: data['phoneNumber'],
        profileImageKey: profileImage,
        createdAt: data['createdAt'],
        updatedAt: data['updatedAt'],
        lastLoginAt: data['lastLoginAt'] != null ? DateTime.parse(data['lastLoginAt']) : null,
        deletedAt: data['deletedAt'] != null ? DateTime.parse(data['deletedAt']) : null,
        roles: userRoles,
        school: schoolData,
        omgPassStatus: data['omgPassStatus'],
        followerCount: data['followerCount'],
        followingCount: data['followingCount'],
        relationship: relationship,
        userId: data['userId'],
        commonFollowingCount: data['commonFollowingCount'],
        affiliation: data['affiliation'],
        duty: data['duty'],
        identityTitle: data['identityTitle'],
        identityContent: data['identityContent'],
        identityReliability: data['identityReliability']
    );
  }

  void update(Map<String, dynamic> data) {
    Gender? gdr;
    if (data['gender'] == 'female') {
      gdr = Gender.female;
    } else if (data['gender'] == 'male') {
      gdr = Gender.male;
    }

    List<UserRole> userRoles = [];
    if (data['roles'] != null && data['roles'].isNotEmpty) {
      for (var e in data['roles']) {
        if (e == 'USER') {
          userRoles.add(UserRole.user);
        }
      }
    }

    id = data['id'];
    name = data['name'];
    grade = data['grade'];
    nickname = data['nickname'];
    bio = data['bio'];
    schoolId = data['schoolId'];
    gender = gdr;
    profileImageKey = data['profileImageKey'] ?? '';
  }

  Map<String, String> toJson() {
    String grade;
    if (service.userSchoolGrade.value == 0) {   // 중학교
      grade = 'M${service.userSchoolYear.value}';
    } else {  // 고등학교
      grade = 'H${service.userSchoolYear.value}';
    }

    return {
      'schoolId': service.userSchoolId.toString(),
      'name': service.username.value,
      'phoneNumber': service.phoneNumber.value,
      'gender': service.userGender.value == 0 ?'male' : 'female',
      'grade': grade,
      'phoneNumberToken': service.phoneNumberToken.value,
      'profileImage': service.profileImage.value,
    };
  }

  Map<String, dynamic> toSearchHistory() {
    return {
      'id': id,
      'name': name,
      'nickname': nickname,
      'gender': gender?.name,
      'grade': grade,
      'profileImageKey': profileImageKey,
    };
  }

  UserType get userType {     // 유저 상태 (기존 유저, 신규, 삭제, 복구) 정보
    /// 유저 상태 정보 등록
    UserType userType;
    if (deletedAt != null) {  // 기존 유저 -> 삭제 요청
      Duration diff = DateTime.now().difference(deletedAt!);
      if (diff >= const Duration(hours: 120)) {
        userType = UserType.deleted;
      }  else {
        userType = UserType.canRecover;
      }
    } else {  // 기존 유저
      userType = UserType.registered;
    }
    return userType;
  }

  String? get schoolInfo {  // 고1 남학생 ∙ 트리니티고등학교
    String out = '';
    String? grade = schoolGrade?.num;   // 1,2,3
    String? type = schoolType?.short;   // 중, 고

    if (type != null && grade != null) out += '$type$grade ';
    if (gender != null) out += gender!.student;
    if (school?.name != null) out += ' \u00B7 ${school?.name}';
    return out;
  }

  String? get schoolDetail {  // 트리니티고등학교 1학년 2반
    String out = '';
    String? sg = schoolGrade?.full;

    if (school?.name != null) out = '${school?.name} ';
    if (sg != null) out += sg;
    if (classNo != null) out += ' $classNo반';

    return out;
  }

  String? get clueWithDot {  // 고1 . 남학생
    String out = '';
    String? grade = schoolGrade?.num;
    String? type = schoolType?.short;
    if (grade != null && type != null) {
      out = '$type$grade';
    }
    if (gender != null) {
      out += ' \u00B7 ${gender!.student}';
    }
    return out;
  }

  String get clueWithoutDot {  // 고1 남학생
    String out = '';
    String? grade = schoolGrade?.num;
    String? type = schoolType?.short;
    if (grade != null && type != null) {
      out = '$type$grade ';
    }
    if (gender != null) {
      out += gender!.student;
    }
    return out;
  }

  String? get gradeClass {  // 1학년 3반
    String out = '';

    SchoolGrade? sg = schoolGrade;

    if (sg != null) out = sg.full;
    if (classNo != null) out += ' $classNo반';
    return out;
  }

  SchoolGrade? get schoolGrade {
    SchoolGrade? out;
    if (grade == 'M1') {
      out = SchoolGrade.first;
    } else if (grade == 'M2') {
      out = SchoolGrade.second;
    } else if (grade == 'M3') {
      out = SchoolGrade.third;
    } else if (grade == 'H1') {
      out = SchoolGrade.first;
    } else if (grade == 'H2') {
      out = SchoolGrade.second;
    } else if (grade == 'H3') {
      out = SchoolGrade.third;
    }
    return out;
  }

  SchoolType? get schoolType {
    SchoolType? out;
    if (grade == 'M1') {
      out = SchoolType.middle;
    } else if (grade == 'M2') {
      out = SchoolType.middle;
    } else if (grade == 'M3') {
      out = SchoolType.middle;
    } else if (grade == 'H1') {
      out = SchoolType.high;
    } else if (grade == 'H2') {
      out = SchoolType.high;
    } else if (grade == 'H3') {
      out = SchoolType.high;
    }
    return out;
  }

  void printOut() {
    debugPrint('------------ user info ------------');
    debugPrint('---> id: $id');
    debugPrint('---> name: $name');
    debugPrint('---> nickname: $nickname');
    debugPrint('---> bio: $bio');
    debugPrint('---> schoolId: $schoolId');
    debugPrint('---> gender: $gender');
    debugPrint('---> classNo: $classNo');
    debugPrint('---> phoneNumber: $phoneNumber');
    debugPrint('---> profileImageKey: $profileImageKey');
    debugPrint('---> createdAt: $createdAt');
    debugPrint('---> updatedAt: $updatedAt');
    debugPrint('---> lastLoginAt: $lastLoginAt');
    debugPrint('---> deletedAt: $deletedAt');
    debugPrint('---> followerCount: $followerCount');
    debugPrint('---> followingCount: $followingCount');
    debugPrint('---> relationship: $relationship');
    debugPrint('---> userId: $userId');
    debugPrint('---> commonFollowingCount: $commonFollowingCount');
    debugPrint('---> affiliation: $affiliation');
    debugPrint('---> duty: $duty');
    school?.printOut();
    debugPrint('------------- user end -----------');
  }
}

class UserSimple {
  UserSimple({
    this.id,
    this.userId,
    this.name,
    this.grade,
    this.gender,
    this.profileImageKey,
    this.phoneNumber,
    this.commonFollowingCount,
    this.followersCount,
    this.createdAt
  });

  String? id;
  String? userId;
  String? grade;      //  M1, M2, M3, H1, H2, H3
  Gender? gender;     // male, female
  String? profileImageKey;
  String? name;
  String? phoneNumber;
  String? commonFollowingCount;
  String? followersCount;
  String? createdAt;  // 친구 숨김/차단 한 날짜

  factory UserSimple.fromJson(Map<String, dynamic> data) {
    Gender? gender;
    if (data['gender'] == 'female') {
      gender = Gender.female;
    } else if (data['gender'] == 'male') {
      gender = Gender.male;
    }

    String? profileImage;
    if (data['profileImageKey'] != null) {
      profileImage = '${kConst.bucket}/${data['profileImageKey']}';
    }

    return UserSimple(
      id: data['id'],
      userId: data['userId'],
      grade: data['grade'],
      profileImageKey: profileImage,
      name: data['name'],
      gender: gender,
      phoneNumber: data['phoneNumber'],
      commonFollowingCount: data['commonFollowingCount'],
      followersCount: data['followersCount'],
      createdAt: data['createdAt']
    );
  }

  String get clueWithoutDot {  // 고1 남학생
    String out = '';
    String? grade = _getSchoolGrade?.num;
    String? type = _getSchoolType?.short;
    if (grade != null && type != null) {
      out = '$type$grade ';
    }
    if (gender != null) {
      out += gender!.student;
    }
    return out;
  }

  SchoolGrade? get _getSchoolGrade {
    SchoolGrade? out;
    if (grade == 'M1') {
      out = SchoolGrade.first;
    } else if (grade == 'M2') {
      out = SchoolGrade.second;
    } else if (grade == 'M3') {
      out = SchoolGrade.third;
    } else if (grade == 'H1') {
      out = SchoolGrade.first;
    } else if (grade == 'H2') {
      out = SchoolGrade.second;
    } else if (grade == 'H3') {
      out = SchoolGrade.third;
    }
    return out;
  }

  SchoolType? get _getSchoolType {
    SchoolType? out;
    if (grade == 'M1') {
      out = SchoolType.middle;
    } else if (grade == 'M2') {
      out = SchoolType.middle;
    } else if (grade == 'M3') {
      out = SchoolType.middle;
    } else if (grade == 'H1') {
      out = SchoolType.high;
    } else if (grade == 'H2') {
      out = SchoolType.high;
    } else if (grade == 'H3') {
      out = SchoolType.high;
    }
    return out;
  }

  void printOut() {
    debugPrint('------------ user simple -----------');
    debugPrint('---> gender: $gender');
    debugPrint('---> grade: $grade');
    debugPrint('---> profileImageKey: $profileImageKey');
    debugPrint('---> name: $name');
    debugPrint('---> phoneNumber: $phoneNumber');
    debugPrint('---> commonFollowingCount: $commonFollowingCount');
    debugPrint('---> followersCount: $followersCount');
    debugPrint('------------- end -----------');
  }
}













































class UserState {
  UserState({
    this.isVerified,
    this.phoneNumberToken,
    this.accessToken,
    this.isNewUser
  });

  bool? isVerified;
  String? phoneNumberToken;
  String? accessToken;
  bool? isNewUser;

  factory UserState.fromJson(Map<String, dynamic> data) {
    return UserState(
      phoneNumberToken: data['phoneNumberToken'],
      accessToken: data['accessToken'],
      isNewUser: data['isNewUser'] == 'true' ? true : false,
    );
  }
}

class ContactNoneOmg {
  ContactNoneOmg({
    required this.name,
    required this.phone,
    required this.omgFriends
  });

  String? name;
  String? phone;
  int? omgFriends;

  factory ContactNoneOmg.fromJson(Map<String, dynamic> data) {
    return ContactNoneOmg(
      name: data['name'],
      phone: data['phone'],
      omgFriends: data['omgFriends'],
    );
  }
}

class UserCount {
  UserCount({
    this.receivedCardsCount,
    this.profileViewCount,
    this.followerCount,
    this.followingCount
  });

  int? receivedCardsCount;
  int? profileViewCount;
  int? followerCount;
  int? followingCount;

  factory UserCount.fromJson(Map<String, dynamic> data) {
    return UserCount(
      receivedCardsCount: data['receivedCardsCount'],
      profileViewCount: data['profileViewCount'],
      followerCount: data['followerCount'],
      followingCount: data['followingCount'],
    );
  }
}

enum Gender {
  female('여자', '여학생'),
  male('남자', '남학생');

  const Gender(this.type, this.student);
  final String type;
  final String student;
}

enum UserRole {
  user,
}

enum UserType {
  registered,
  newbie,
  canRecover,
  deleted,
  error
}

enum SearchType {
  contact,
  sameSchool,
  maybe,
  omg
}

enum Relationship {
  me,
  favorite,
  following,
  none
}