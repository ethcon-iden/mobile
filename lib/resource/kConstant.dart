// ignore_for_file: camel_case_types, file_names

import 'package:flutter/material.dart';
import '../model/user.dart';

class kRoutes {
  static const faqCupertino = '/faq_cupertino';
}

class kConst {
  static String domain = 'http://iden-backend.ap-northeast-2.elasticbeanstalk.com';
  static String bucket = 'https://dev-bucket.omgapp.io';
  static List<String> firstConsonants = ["ㄱ", "ㄲ", "ㄴ", "ㄷ", "ㄸ", "ㄹ", "ㅁ",
    "ㅂ", "ㅃ", "ㅅ", "ㅆ", "ㅇ" , "ㅈ", "ㅉ", "ㅊ", "ㅋ", "ㅌ", "ㅍ", "ㅎ"];     // 19
  static List<String> gender = ['남학생','여학생'];
  static List<String> schoolGrade = ['중학교','고등학교'];
  static List<String> schoolGradeShort = ['중','고'];
  static int networkTimeout = 10;
  static double bottomButtonMargin = 30;
}

class kStorageKey {
  // userMe
  static String accessToken = 'accessToken';
  static String phoneNumber = 'phoneNumber';
  static String username = 'username';
  static String school = 'school';
  static String grade = 'grade';
  static String gender = 'gender';
  static String profileImage = 'profileImage';
  /// control
  static String bio = 'bio';
  /// shared preference
  static String countdown = 'countdown';
  static String cardReadIndex = 'cardReadIndex';
  static String cardOpen = 'cardOpen';
  static String cardOpenComplete = 'cardOpenComplete';
  static String writeInVoteCount = 'writeInVoteCount';
  static String spectorModeCount = 'spectorModeCount';
  static String voteCountdownTime = 'voteCountdownTime';
  static String searchHistory = 'searchHistory';
  static String isFirstAppLaunch = 'isFirstAppLaunch';
  static String friendsTapBanner = 'friendsTapBanner';
}

class kLocale {
  static Map<String, dynamic> kr = {'name':'한국어', 'locale': const Locale('ko','KR')};
  static Map<String, dynamic> en = {'name':'English', 'locale': const Locale('en','US')};
}

enum kBrightness {
  light,
  dart
}

class Emoji {
  String? title;
  String? url;

  Emoji({
    this.title,
    this.url
  });
}

class kSamples {
  static List<String> names = [
    '김지민',
    '이선영',
    '한준호',
    '정은지',
    '최영호',
    '박지영',
    '김세영',
    '이현우',
    '김지훈',
    '유승민',
    '최용호',
    '윤준'
  ];
  static List<Gender> genders = [
    Gender.female,
    Gender.female,
    Gender.male,
    Gender.female,
    Gender.male,
    Gender.female,
    Gender.female,
    Gender.male,
    Gender.male,
    Gender.male,
    Gender.female,
    Gender.male
  ];
  static List<String> affiliations = [
    '서울교육대학교',
    '연세대학교',
    '서울대학교',
    'LG이노베이션',
    '프리랜서 디자이너',
    '삼성전자',
    '프리랜서 개발자',
    '현대자동차',
    '팔로알토네트웍스',
    'Airbnb',
    'DyveStudios',
    'DyveStudios'
  ];
  static List<String> questions = [
    'Who is the funniest?',
    'Most strong physics?',
    'questions3',
    'questions4',
    'questions5',
    'questions6',
    'questions7',
    'questions8',
    'questions9',
    'questions10',
  ];
  static List<String?> profiles = [
    null,
    'assets/images/profile2_female.jpeg',
    'assets/images/profile1_male.jpeg',
    'assets/images/profile3_character.jpeg',
    null,
    'assets/images/profile6_puppy.jpeg',
    'assets/images/profile4_female.jpeg',
    null,
    null,
    null,
  ];

  static List<Emoji> emojis = [
    Emoji(
        title: 'Alien Monster',
        url: 'https://raw.githubusercontent.com/Tarikul-Islam-Anik/Animated-Fluent-Emojis/master/Emojis/Smilies/Alien%20Monster.png'),
    Emoji(
        title: 'Alien',
        url: 'https://raw.githubusercontent.com/Tarikul-Islam-Anik/Animated-Fluent-Emojis/master/Emojis/Smilies/Alien.png'),
    Emoji(
        title: 'Beating Heart',
        url: 'https://raw.githubusercontent.com/Tarikul-Islam-Anik/Animated-Fluent-Emojis/master/Emojis/Smilies/Beating%20Heart.png'),
    Emoji(
        title: 'Backhand Index Pointing Down',
        url: 'https://raw.githubusercontent.com/Tarikul-Islam-Anik/Animated-Fluent-Emojis/master/Emojis/Hand%20gestures/Backhand%20Index%20Pointing%20Down.png'),
    Emoji(
        title: 'Cook',
        url: 'https://raw.githubusercontent.com/Tarikul-Islam-Anik/Animated-Fluent-Emojis/master/Emojis/People/Cook.png'),
    Emoji(
        title: 'Artist Medium-Dark Skin Tone',
        url: 'https://raw.githubusercontent.com/Tarikul-Islam-Anik/Animated-Fluent-Emojis/master/Emojis/People%20with%20professions/Artist%20Medium-Dark%20Skin%20Tone.png'),
    Emoji(
        title: 'Blossom',
        url: 'https://raw.githubusercontent.com/Tarikul-Islam-Anik/Animated-Fluent-Emojis/master/Emojis/Animals/Blossom.png'),
    Emoji(
        title: 'Bouquet',
        url: 'https://raw.githubusercontent.com/Tarikul-Islam-Anik/Animated-Fluent-Emojis/master/Emojis/Animals/Bouquet.png'),
    Emoji(
        title: 'Birthday Cake',
        url: 'https://raw.githubusercontent.com/Tarikul-Islam-Anik/Animated-Fluent-Emojis/master/Emojis/Food/Birthday%20Cake.png'),
    Emoji(
        title: 'Beer Mug',
        url: 'https://raw.githubusercontent.com/Tarikul-Islam-Anik/Animated-Fluent-Emojis/master/Emojis/Food/Beer%20Mug.png'),
  ];
}