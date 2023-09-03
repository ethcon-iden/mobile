import 'package:flutter/material.dart';

class OmgPassInfo {
  OmgPassInfo({
    this.omgPass,
    this.totalSubscribedWeeks,
    this.status,
  });

  OmgPass? omgPass;
  int? totalSubscribedWeeks;
  OmgPassStatus? status;

  factory OmgPassInfo.fromJson(Map<String, dynamic> data) {
    OmgPass? omgPass;
    OmgPassStatus? passStatus;
    String? status = data['status'];
    if (status != null) {
      if (status == 'NONE') {
        passStatus = OmgPassStatus.none;
      } else if (status == 'EXPIRED') {
        passStatus = OmgPassStatus.expired;
      } else if (status == 'ACTIVE_SUBSCRIBED') {
        passStatus = OmgPassStatus.activeSub;
      } else if (status == 'ACTIVE_UNSUBSCRIBED') {
        passStatus = OmgPassStatus.activeUnSub;
      }
    }
    if (data['omgPass'] != null) {
      omgPass = OmgPass.fromJson(data['omgPass']);
    }

    return OmgPassInfo(
      omgPass: omgPass,
      totalSubscribedWeeks: data['totalSubscribedWeeks'],
      status: passStatus,
    );
  }

  void printOut() {
    debugPrint('======= omg pass Info ======');
    omgPass?.printOut();
    debugPrint('---> totalSubscribedMonths: $totalSubscribedWeeks');
    debugPrint('---> status: $status');
    debugPrint('========   end   ===========');
  }

  void reset() {
    omgPass = null;
    totalSubscribedWeeks = null;
    status = null;
  }
}

class OmgPass {
  OmgPass({
    this.id,  // uuid
    this.userId,
    this.validUntil,
    this.createdAt,
    this.nextBillingId,
    this.nextBilling,
    this.remainingRevealChances
  });

  int? id;     // uuid
  String? userId;
  String? validUntil;
  String? createdAt;
  int? nextBillingId;
  Billing? nextBilling;
  int? remainingRevealChances;

  factory OmgPass.fromJson(Map<String, dynamic> data) {
    Billing? billing;
    if (data['nextBilling'] != null) {
      billing = Billing.fromJson(data['nextBilling']);
    }

    return OmgPass(
        id: data['id'],
        userId: data['userId'],
        validUntil: data['validUntil'],
        createdAt: data['createdAt'],
        nextBillingId: data['nextBillingId'],
        nextBilling: billing,
        remainingRevealChances: data['remainingRevealChances']
    );
  }

  void printOut() {
    debugPrint('------------ omg pass ------------');
    debugPrint('---> id: $id');
    debugPrint('---> userId: $userId');
    debugPrint('---> validUntil: $validUntil');
    debugPrint('---> createdAt: $createdAt');
    debugPrint('---> nextBillingId: $nextBillingId');
    debugPrint('---> remainingRevealChances: $remainingRevealChances');
    nextBilling?.printOut();
    debugPrint('------------    end    ------------');
  }

  void reset() {
    id = null;
    userId = null;
    validUntil = null;
    createdAt = null;
    nextBillingId = null;
  }
}

class Billing {
  Billing({
    this.id,
    this.pg,
    this.paymentType,
    this.userId,
    this.authenticatedAt,
    this.customerKeyOrUserId,
    this.billingKeyOrSid,
    this.orderId,
    this.cardNumber,
    this.cardType,
    this.deletedAt,
  });

  int? id;
  String? pg;
  PaymentType? paymentType;
  String? userId;
  String? authenticatedAt;
  String? customerKeyOrUserId;
  String? billingKeyOrSid;
  String? orderId;
  String? cardNumber;
  String? cardType;
  String? deletedAt;

  factory Billing.fromJson(Map<String, dynamic> data) {
    PaymentType? paymentType;
    if (data['paymentType'] != null) {
      if (data['paymentType'] == 'TOSS_CARD') {
        paymentType = PaymentType.tossCard;
      } else if (data['paymentType'] == 'KAKAO_CARD') {
        paymentType = PaymentType.kakaoCard;
      } else if (data['paymentType'] == 'KAKAO_MONEY') {
        paymentType = PaymentType.kakaoMoney;
      } else {
        paymentType = PaymentType.na;
      }
    }

    return Billing(
      id: data['id'],
      pg: data['pg'],
      paymentType: paymentType,
      userId: data['userId'],
      authenticatedAt: data['authenticatedAt'],
      customerKeyOrUserId: data['customerKeyOrUserId'],
      billingKeyOrSid: data['billingKeyOrSid'],
      orderId: data['orderId'],
      cardNumber: data['cardNumber'],
      cardType: data['cardType'],
      deletedAt: data['deletedAt'],
    );
  }

  void printOut() {
    debugPrint('------------ billing ------------');
    debugPrint('---> id: $id');
    debugPrint('---> pg: $pg');
    debugPrint('---> paymentType: $paymentType');
    debugPrint('---> userId: $userId');
    debugPrint('---> authenticatedAt: $authenticatedAt');
    debugPrint('---> customerKeyOrUserId: $customerKeyOrUserId');
    debugPrint('---> billingKeyOrSid: $billingKeyOrSid');
    debugPrint('---> orderId: $orderId');
    debugPrint('---> cardNumber: $cardNumber');
    debugPrint('---> cardType: $cardType');
    debugPrint('---> deletedAt: $deletedAt');
    debugPrint('-----------    end    -----------');
  }

  void reset() {
    id = null;
    pg = null;
    paymentType = null;
    userId = null;
    authenticatedAt = null;
    customerKeyOrUserId = null;
    billingKeyOrSid = null;
    orderId = null;
    cardNumber = null;
    cardType = null;
    deletedAt = null;
  }
}

enum OmgPassStatus {
  activeSub,    // 구독중 -> 결제수단 변경하기 & 해지하기
  activeUnSub,    // 유효하나 구독중이 아님 -> 다시 구독하기
  expired,  // 한 번 가졌다가 만료됨 -> 무료 이벤트 해당 안 됨
  none,   // 한 번도 가진 적 없음 -> 무료 체험 기회 / 이벤트 해당
}

enum CreditVendor {
  visa('Visa Card', 'assets/images/img_visa_logo.png'),
  master('MasterCard', 'assets/images/img_mastercard-logo.png'),
  americanExpress('American Express','assets/images/img_American_Express_logo.png'),
  discover('Discover','assets/images/img_discover_logo.png'),
  dinersClub('Diners Club','assets/images/img_dinersClub_logo.png'),
  JCB('JCB','assets/images/img_jcb_logo.png'),
  unionPay('Union Pay','assets/images/img_unionPay_logo.png');

  const CreditVendor(this.name, this.logo);
  final String logo;
  final String name;
}

enum PaymentType {
  tossCard,
  kakaoCard,
  kakaoMoney,
  na
}