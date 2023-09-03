import 'package:flutter/material.dart';

class Payment {
  Payment({
    this.userId,  // uuid
    this.passId,
    this.cardNumber,
    this.createdAt,
  });

  String? userId;     // uuid
  String? passId;
  String? cardNumber;
  String? createdAt;

  factory Payment.fromJson(Map<String, dynamic> data) {
    return Payment(
      userId: data['user_id'],
      passId: data['pass_id'],
      cardNumber: data['card_number'],
      createdAt: data['created_at'],
    );
  }

  void printOut() {
    debugPrint('------------- Payment -------------');
    debugPrint('---> userId: $userId');
    debugPrint('---> passId: $passId');
    debugPrint('---> cardNumber: $cardNumber');
    debugPrint('---> createdAt: $createdAt');
    debugPrint('-----------    end    ------------');
  }

  void reset() {
    userId = null;
    passId = null;
    cardNumber = null;
    createdAt = null;
  }
}

class KakaoPay {
  KakaoPay({
    this.tid,
    this.tmsResult,
    this.nextRedirectAppUrl,
    this.nextRedirectMobileUrl,
    this.nextRedirectPcUrl,
    this.androidAppScheme,
    this.iosAppScheme,
    this.createdAt,
  });

  String? tid;
  bool? tmsResult;
  String? nextRedirectAppUrl;
  String? nextRedirectMobileUrl;
  String? nextRedirectPcUrl;
  String? androidAppScheme;
  String? iosAppScheme;
  String? createdAt;

  factory KakaoPay.fromJson(Map<String, dynamic> data) {
    return KakaoPay(
      tid: data['tid'],
      tmsResult: data['tms_result'],
      nextRedirectAppUrl: data['next_redirect_app_url'],
      nextRedirectMobileUrl: data['next_redirect_mobile_url'],
      nextRedirectPcUrl: data['next_redirect_pc_url'],
      androidAppScheme: data['android_app_scheme'],
      iosAppScheme: data['ios_app_scheme'],
      createdAt: data['created_at'],
    );
  }

  void printOut() {
    debugPrint('------------- Kakao Pay -------------');
    debugPrint('---> tid: $tid');
    debugPrint('---> tmsResult: $tmsResult');
    debugPrint('---> nextRedirectAppUrl: $nextRedirectAppUrl');
    debugPrint('---> nextRedirectMobileUrl: $nextRedirectMobileUrl');
    debugPrint('---> nextRedirectPcUrl: $nextRedirectPcUrl');
    debugPrint('---> androidAppScheme: $androidAppScheme');
    debugPrint('---> iosAppScheme: $iosAppScheme');
    debugPrint('---> createdAt: $createdAt');
    debugPrint('-------------    end    -------------');
  }
}

class OmgPassPrice {
  String? priceOriginal;
  String? priceFinal;
  String? message;

  OmgPassPrice({this.priceOriginal, this.priceFinal, this.message});
}