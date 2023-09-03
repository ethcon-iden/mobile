import 'package:flutter/material.dart';

/// get the size of text widget
Size getTextSize(String text, TextStyle style) {
  final TextPainter textPainter = TextPainter(
      text: TextSpan(text: text, style: style), maxLines: 1, textDirection: TextDirection.ltr)
    ..layout(minWidth: 0, maxWidth: double.infinity);
  return textPainter.size;
}

class CalendarUtil {
  CalendarUtil();

  static final CalendarUtil _instance = CalendarUtil();

  static String? getWeekOfMonth(DateTime? date) {
    String? output;
    if (date != null) {
      if (DateTime.now().isBefore(date)) {
        output = '진행중';
      } else {
        // final int resForSimples = _instance._weekOfMonthSimple(date);
        final int resForStandard = weekOfMonthStandard(date);
        // print('---> week of month simple: ${date.month}월 $resForSimples주차');
        // print('---> week of month standard: ${date.month}월 $resForStandard주차');
        output = '${date.month}월 $resForStandard주차';
      }
    }
    return output;
  }

  int _weekOfMonthSimple(DateTime date) {
    DateTime firstDay = DateTime(date.year, date.month, 1); // 월의 첫번째 날짜.
    DateTime firstMonday = firstDay
        .add(Duration(days: (DateTime.monday + 7 - firstDay.weekday) % 7)); // 월중에 첫번째 월요일인 날짜.

    /// 첫번째 날짜와 첫번째 월요일인 날짜가 동일한지 판단.
    /// 동일할 경우: 1, 동일하지 않은 경우: 2 를 마지막에 더한다.
    final bool isFirstDayMonday = firstDay == firstMonday;
    final different = (date.difference(firstMonday).inHours / 24).round();    // D-Day 계산.
    int weekOfMonth = (different / 7 + (isFirstDayMonday ? 1 : 2)).toInt();   // 주차 계산.
    return weekOfMonth;
  }

  bool _isSameWeek(DateTime dateTime1, DateTime dateTime2) {
    final int dateTime1WeekOfMonth = _weekOfMonthSimple(dateTime1);
    final int dateTime2WeekOfMonth = _weekOfMonthSimple(dateTime2);
    return dateTime1WeekOfMonth == dateTime2WeekOfMonth;
  }

  static int weekOfMonthStandard(DateTime date) {
    int weekOfMonth; // 월 주차

    final firstDay = DateTime(date.year, date.month, 1);  // 선택한 월의 첫번째 날짜.
    final lastDay = DateTime(date.year, date.month + 1, 0);   // 선택한 월의 마지막 날짜.
    final isFirstDayBeforeThursday = firstDay.weekday <= DateTime.thursday;   // 첫번째 날짜가 목요일보다 작은지 판단.
    if (_instance._isSameWeek(date, firstDay)) {  // 선택한 날짜와 첫번째 날짜가 같은 주에 위치하는지 판단.
      if (isFirstDayBeforeThursday) {  // 첫번째 날짜가 목요일보다 작은지 판단.
        weekOfMonth = 1;    // 1주차.
      }
      else {   // 저번달의 마지막 날짜의 주차와 동일.
        final lastDayOfPreviousMonth = DateTime(date.year, date.month, 0);
        weekOfMonth = weekOfMonthStandard(lastDayOfPreviousMonth);        // n주차.
      }
    } else {
      if (_instance._isSameWeek(date, lastDay)) {       // 선택한 날짜와 마지막 날짜가 같은 주에 위치하는지 판단.
        final isLastDayBeforeThursday = lastDay.weekday >= DateTime.thursday;   // 마지막 날짜가 목요일보다 큰지 판단.
        if (isLastDayBeforeThursday) {
          // 주차를 단순 계산 후 첫번째 날짜의 위치에 따라서 0/-1 결합.
          weekOfMonth = _instance._weekOfMonthSimple(date) + (isFirstDayBeforeThursday ? 0 : -1);    // n주차.
        }
        else {      // 다음달 첫번째 날짜의 주차와 동일.
          weekOfMonth = 1;    // 1주차.
        }
      }
      // 첫번째주와 마지막주가 아닌 날짜들.
      else {
        // 주차를 단순 계산 후 첫번째 날짜의 위치에 따라서 0/-1 결합.
        weekOfMonth = _instance._weekOfMonthSimple(date) + (isFirstDayBeforeThursday ? 0 : -1);    // n주차.
      }
    }
    return weekOfMonth;
  }

  static int getWeekOfYear(DateTime dateTime) {   // return YYWK (예, 2328 -> 2023년 28주차)
    final firstJan = DateTime(dateTime.year, 1, 1);
    final weekNumber = _instance._weeksBetween(firstJan, dateTime);
    final yr = dateTime.year%2000;
    final out = yr*100 + weekNumber;
    print('---> get week of year: $out');
    return out;
  }

  int _weeksBetween(DateTime from, DateTime to) {
    from = DateTime.utc(from.year, from.month, from.day);
    to = DateTime.utc(to.year, to.month, to.day);
    return (to.difference(from).inDays / 7).ceil();
  }
}

class TimeUtil {

  static Duration getTimeDifference() {
    DateTime now = DateTime.now();
    Duration timeDifference = now.timeZoneOffset;

    String sign = timeDifference.isNegative ? '-' : '+';
    String hours = (timeDifference.inHours % 24).toString().padLeft(2, '0');
    String minutes = (timeDifference.inMinutes % 60).toString().padLeft(2, '0');
    // print('---> time difference: UTC $sign $hours:$minutes');
    return timeDifference;
  }
}