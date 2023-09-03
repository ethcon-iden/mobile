import 'dart:math';
import 'package:flutter/material.dart';

import '../resource/kConstant.dart';
import '../services/utils.dart';

extension TruncateDoubles on double {
  double truncateToDecimalPlaces() => (this * pow(10, 6)).truncate() / pow(10, 6);
}

extension StringExtension on String {
  String toPhoneNumber() {
    String output = '';
    if (isNotEmpty) {
      List<String> num = split('');
      for (int i = 0; i < num.length; i++) {
        if (i == 4) {
          output += ' ';
        }
        output += num[i];
      }
    }
    return output;
  }

  String onlyNumber() {
    String output = '';
    if (isNotEmpty) {
      final res1 = replaceAll('-', '');
      final res2 = res1.replaceAll('.', '');
      output = res2.replaceAll(' ', '');
    }
    return output;
  }

  String? getFirstConstant() {
    String? output;
    if (isNotEmpty) {
      final txt = replaceAll(' ', '');
      final first = txt.split('').first;
      final unicode = first.codeUnits.first;
      print('---> get first consonant > unicode: $unicode');
      final index = ((unicode - 44032) ~/ 28) ~/ 21;
      output = kConst.firstConsonants[index];
    }

    debugPrint('---> getFirstConstant: $output');
    return output;
  }

  String getLastName() {
    String out = '';
    if (isNotEmpty) {
      final txt = replaceAll(' ', '');
      out = txt.split('').last;
    }
    return out;
  }

  bool isMobileNumber() {
    bool output;
    final input = onlyNumber();
    final prefix = input.substring(0,3);
    if (prefix == '010') {
      output = true;
    } else {
      output = false;
    }
    return output;
  }

  String toCurrency() {
    String out = '';

    int count = 0;
    for (int i = length-1; i>=0; i--) {
      count++;
      out = this[i] + out;
      if (count % 3 == 0 && i != 0) {
        out = ',$out';
      }
    }
    return out;
  }

  String whenReceived() {
    String out = '';
    DateTime now = DateTime.now();

    if (isNotEmpty) {
      DateTime dt = DateTime.parse(this);
      Duration diff = now.difference(dt);
      int differenceInMin = diff.inMinutes;
      int differenceInHr = diff.inHours;
      int differenceInDays = diff.inDays;
      if (differenceInMin < 1) {
        out = '방금전';
      } else if (differenceInMin < 60) {
        out = '$differenceInMin분 전';
      } else if (differenceInHr < 24) {
        out = '$differenceInHr시간 전';
      } else if (differenceInDays < 7) {
        out = '$differenceInDays일 전';
      } else {
        out = '1주일 전';
      }
    }
    return out;
  }

  DateTime? toDateTime() {
    DateTime? out;
    if (isNotEmpty) {
      out = DateTime.parse(this);
    }
    return out;
  }

  String toTimeFormat() {   // 2023년 2월 22일 ∙ 22:07
    String out = '';
    Duration timeDifference = TimeUtil.getTimeDifference();
    if (isNotEmpty) {
      DateTime dt = DateTime.parse(this);
      DateTime localTime = dt.add(timeDifference);
      String hh = '';
      String mm = '';
      if (localTime.hour < 10) {
        hh = '0${localTime.hour}';
      } else {
        hh = localTime.hour.toString();
      }
      if (localTime.minute < 10) {
        mm = '0${localTime.minute}';
      } else {
        mm = localTime.minute.toString();
      }
      out = '${localTime.year}년 ${localTime.month}월 ${localTime.day}일 \u00B7 $hh:$mm';
    }
    return out;
  }

  String toTimeFormatSimple() {   // 2023. 08. 02
    String out = '';
    Duration timeDifference = TimeUtil.getTimeDifference();
    if (isNotEmpty) {
      DateTime dt = DateTime.parse(this);
      DateTime localTime = dt.add(timeDifference);
      String mm;
      if (localTime.month < 10) {
        mm = '0${localTime.month}';
      } else {
        mm = localTime.month.toString();
      }
      String dd;
      if (localTime.day < 10) {
        dd = '0${localTime.day}';
      } else {
        dd = localTime.day.toString();
      }
      out = '${localTime.year}. $mm. $dd';
    }
    return out;
  }

  bool checkKoreanWordValidate() {
    bool out = false;
    if (isNotEmpty) {
      final RegExp regExp = RegExp(r'[\uac00-\ud7af]', unicode: true);
      if (regExp.allMatches(this).length == length) {
        out = true;
      }
    }
    return out;
  }

  bool checkKoreanValidate() {
    bool out = false;
    final RegExp regExp = RegExp(r'[ㄱ-ㅎ가-힣a-zA-Z0-9]', unicode: false);
    if (regExp.hasMatch(this)) {
      out = true;
    }
    return out;
  }
}

extension ColorExtension on String {
  toColor() {
    var hexString = this;
    final buffer = StringBuffer();
    if (hexString.length == 6 || hexString.length == 7) buffer.write('ff');
    buffer.write(hexString.replaceFirst('#', ''));
    return Color(int.parse(buffer.toString(), radix: 16));
  }
}