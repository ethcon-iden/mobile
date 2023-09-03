// ignore_for_file: camel_case_types

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'dart:io';

import '../services/extensions.dart';
import '../../controller/state_controller.dart';

class kStyle {
  static Color toastBackground = Colors.grey.shade100;
  static SystemUiOverlayStyle overlayStyleBottomLight = const SystemUiOverlayStyle(
      statusBarColor: Colors.transparent,
      statusBarIconBrightness: Brightness.light,
      statusBarBrightness: Brightness.light,
      systemNavigationBarColor: Colors.white,
      systemNavigationBarIconBrightness: Brightness.dark
  );
  /// set system overlay style
  static SystemUiOverlayStyle setSystemOverlayStyle(kScreenBrightness brightness) {
    SystemUiOverlayStyle style;
    if (Platform.isAndroid) {
      if (brightness == kScreenBrightness.light) {    // light
        style = const SystemUiOverlayStyle(
            statusBarColor: Colors.transparent,
            statusBarIconBrightness: Brightness.dark,
            statusBarBrightness: Brightness.dark,
            systemNavigationBarIconBrightness: Brightness.dark,
            systemNavigationBarColor: Colors.white
        );
      } else if (brightness == kScreenBrightness.darkModal){
        style = const SystemUiOverlayStyle(
            statusBarIconBrightness: Brightness.light,
            statusBarBrightness: Brightness.light,
            systemNavigationBarIconBrightness: Brightness.dark
        );
      } else {  // dark
        style = const SystemUiOverlayStyle(
            statusBarIconBrightness: Brightness.light,
            statusBarBrightness: Brightness.light,
            systemNavigationBarIconBrightness: Brightness.light
        );
      }
    } else {
      if (brightness == kScreenBrightness.light) {
        style = const SystemUiOverlayStyle(
            statusBarIconBrightness: Brightness.dark,
            statusBarBrightness: Brightness.light,
            systemNavigationBarIconBrightness: Brightness.dark,
            systemNavigationBarColor: Colors.white
        );
      } else if (brightness == kScreenBrightness.darkModal){
        style = const SystemUiOverlayStyle(
            statusBarIconBrightness: Brightness.light,
            statusBarBrightness: Brightness.dark,
            systemNavigationBarIconBrightness: Brightness.dark
        );
      } else {  // dark
        style = const SystemUiOverlayStyle(
            statusBarIconBrightness: Brightness.light,
            statusBarBrightness: Brightness.dark,
            systemNavigationBarIconBrightness: Brightness.light
        );
      }
    }
    return style;
  }

  /// appbar
  static double leadingPaddingLeft = 15;
  static double leadingWidth = 40;
  static Widget leading(BuildContext context, Color? iconColor) {
    return  GestureDetector(
      onTap: () => Navigator.of(context).pop(),
      child: Container(
          color: Colors.transparent,
          padding: EdgeInsets.only(left: kStyle.leadingPaddingLeft),
          child: Icon(Icons.arrow_back_ios_new, color: iconColor ?? Colors.black)
      ),
    );
  }

  static AppBar appBar(BuildContext context, String title) {
    return AppBar(
      backgroundColor: Colors.white,
      elevation: 0,
      leadingWidth: leadingWidth,
      systemOverlayStyle: kStyle.setSystemOverlayStyle(kScreenBrightness.light),
      leading: GestureDetector(
        onTap: () => Navigator.of(context).pop(),
        child: Container(
            color: Colors.transparent,
            padding: EdgeInsets.only(left: leadingPaddingLeft),
            child: const Icon(Icons.arrow_back_ios_new, color: Colors.black)
        ),
      ),
      title: Text(title, style: kTextStyle.title2ExtraBold22),
      centerTitle: false,
    );
  }

  static Widget bottomButton(String title, Color? color) {
    return Container(
      height: 56,
      alignment: Alignment.center,
      margin: EdgeInsets.only(left: 16, right: 16, top: 10, bottom: 40 + service.bottomMargin.value),
      decoration: BoxDecoration(
          color: color ?? kColor.blue100,
          borderRadius: BorderRadius.circular(12)
      ),
      child: Text(title, style: kTextStyle.headlineExtraBold18.copyWith(color: Colors.white)),
    );
  }

  static double cardHeightRatio = 0.65;
}

class kColor {
  // grey scale
  static Color grey20 = '#F8F8FA'.toColor();
  static Color grey30 = '#F2F2F4'.toColor();
  static Color grey100 = '#D5D5DA'.toColor();
  static Color grey300 = '#9F9FA7'.toColor();
  static Color grey500 = '#606064'.toColor();
  static Color grey900 = '#2E2E32'.toColor();
  static Color grey1000 = '#17171B'.toColor();
  // color
  static Color blue10 = '#EEF4FF'.toColor();
  static Color blue30 = '#D7E5FF'.toColor();
  static Color blue50 = '#78A9FF'.toColor();
  static Color blue100 = '#005CFF'.toColor();
  static Color green100 = '#29CC6A'.toColor();
  static Color red100 = '#EB2E23'.toColor();
}

class kTextStyle{
  static TextStyle largeTitle28 = const TextStyle(fontFamily: 'Pretendard', fontSize: 28,
      fontWeight: FontWeight.w900, color: Colors.black);
  static TextStyle title1ExtraBold24 = const TextStyle(fontFamily: 'Pretendard', fontSize: 24,
      fontWeight: FontWeight.w900, color: Colors.black);
  static TextStyle title2ExtraBold22 = const TextStyle(fontFamily: 'Pretendard', fontSize: 22,
      fontWeight: FontWeight.w800, color: Colors.black);
  static TextStyle title3ExtraBold20 = const TextStyle(fontFamily: 'Pretendard', fontSize: 20,
      fontWeight: FontWeight.w800, color: Colors.black);
  static TextStyle headlineExtraBold18 = const TextStyle(fontFamily: 'Pretendard', fontSize: 18,
      fontWeight: FontWeight.w800, color: Colors.black);
  static TextStyle bodyMedium18 = const TextStyle(fontFamily: 'Pretendard', fontSize: 18,
      fontWeight: FontWeight.w500, color: Colors.black);
  static TextStyle hint = TextStyle(fontFamily: 'Pretendard', fontSize: 18,
      fontWeight: FontWeight.w500, color: '#C4C4C4'.toColor());
  static TextStyle callOutBold16 = const TextStyle(fontFamily: 'Pretendard', fontSize: 16,
      fontWeight: FontWeight.w700, color: Colors.black);
  static TextStyle callOutMedium16 = const TextStyle(fontFamily: 'Pretendard', fontSize: 16,
      fontWeight: FontWeight.w500, color: Colors.black);
  static TextStyle subHeadlineBold14 = const TextStyle(fontFamily: 'Pretendard', fontSize: 14,
      fontWeight: FontWeight.w700, color: Colors.black);
  static TextStyle caption1 = const TextStyle(fontFamily: 'Pretendard', fontSize: 14,
      fontWeight: FontWeight.w600, color: Colors.black);
  static TextStyle caption1SemiBold12 = const TextStyle(fontFamily: 'Pretendard', fontSize: 12,
      fontWeight: FontWeight.w600, color: Colors.black);
  static TextStyle caption2 = const TextStyle(fontFamily: 'Pretendard', fontSize: 14,
      fontWeight: FontWeight.w500, color: Colors.black);
  static TextStyle caption2Medium12 = const TextStyle(fontFamily: 'Pretendard', fontSize: 12,
      fontWeight: FontWeight.w500, color: Colors.black);
  static TextStyle footnoteMedium14 = const TextStyle(fontFamily: 'Pretendard', fontSize: 14,
      fontWeight: FontWeight.w500, color: Colors.black);
  static TextStyle footNote = const TextStyle(fontFamily: 'Pretendard', fontSize: 14,
      fontWeight: FontWeight.w400, color: Colors.black);
  static TextStyle footNoteRed = const TextStyle(fontFamily: 'Pretendard', fontSize: 14,
      fontWeight: FontWeight.w400, color: Colors.redAccent);
  static TextStyle footNoteGrey = TextStyle(fontFamily: 'Pretendard', fontSize: 14,
      fontWeight: FontWeight.w400, color: '#838383'.toColor());

  static TextStyle bodySubTitle = TextStyle(fontFamily: 'Pretendard', fontSize: 15,
      fontWeight: FontWeight.w500, color: '#555555'.toColor());
  static TextStyle contentBig = const TextStyle(fontFamily: 'Pretendard', fontSize: 18,
      fontWeight: FontWeight.w600, color: Colors.black54);
  static TextStyle buttonWhite = const TextStyle(fontFamily: 'Pretendard', fontSize: 20,
      fontWeight: FontWeight.w700, color: Colors.white);
  static TextStyle buttonBlack = const TextStyle(fontFamily: 'Pretendard', fontSize: 20,
      fontWeight: FontWeight.w700, color: Colors.black);
  static TextStyle number = const TextStyle(fontFamily: 'Pretendard', fontSize: 18,
      fontWeight: FontWeight.w600, color: Colors.black);
}

enum kScreenBrightness {
  light,
  dark,
  lightModal,
  darkModal
}
