import 'package:flutter/material.dart';

class Notification {
  Notification({
    this.id,
    this.userId,
    this.deviceId,
    this.deviceOs,
    this.token,
    this.cardNotification,
    this.cookiePassNotification,
    this.marketingNotification,
    this.createdAt,
  });

  String? id;     // uid from server
  String? userId;   // user uid
  String? deviceId;  //  device id
  String? deviceOs;   // ios, android
  String? token;     // fcm token
  bool? cardNotification;   // bool
  bool? cookiePassNotification;  // bool
  bool? marketingNotification;  // bool
  String? createdAt;

  factory Notification.fromJson(Map<String, dynamic> data) {
    return Notification(
      id: data['id'],
      userId: data['user_id'],
      deviceId: data['device_id'],
      deviceOs: data['device_os'],
      token: data['fcm_token'],
      cardNotification: data['receive_card_notification'],
      cookiePassNotification: data['receive_coockie_pass_notification'],
      marketingNotification: data['receive_marketing_notification'],
      createdAt: data['created_at'],
    );
  }

  void printOut() {
    debugPrint('------------- user info -------------');
    debugPrint('---> id: $id');
    debugPrint('---> userId: $userId');
    debugPrint('---> deviceId: $deviceId');
    debugPrint('---> deviceOs: $deviceOs');
    debugPrint('---> token: $token');
    debugPrint('---> cardNotification: $cardNotification');
    debugPrint('---> cookiePassNotification: $cookiePassNotification');
    debugPrint('---> marketingNotification: $marketingNotification');
    debugPrint('---> createdAt: $createdAt');
    debugPrint('-------------    end    -------------');
  }

  void reset() {
    id = null;
    userId = null;
    deviceId = null;
    deviceOs = null;
    token = null;
    cardNotification = null;
    cookiePassNotification = null;
    marketingNotification = null;
    createdAt = null;
  }
}


class NotificationBadge {
  NotificationBadge({
    this.contactBadgeCount,
    this.cardBadgeCount,
    this.homeRedDot
  });

  int? contactBadgeCount;     // 신규 추가 연락처 수
  int? cardBadgeCount;   // 신규 확인 가능한 카드 수
  String? homeRedDot;

  factory NotificationBadge.fromJson(Map<String, dynamic> data) {
    return NotificationBadge(
      contactBadgeCount: data['contactBadgeCount'],
      cardBadgeCount: data['cardBagdeCount'],
      homeRedDot: data['homeRedDot'],
    );
  }

  void printOut() {
    debugPrint('---------- notification badge ----------');
    debugPrint('---> contactBadgeCount: $contactBadgeCount');
    debugPrint('---> cardBadgeCount: $cardBadgeCount');
    debugPrint('---> homeRedDot: $homeRedDot');
    debugPrint('-------------    end    -------------');
  }
}