import 'package:flutter/material.dart';

class RelationShip {
  RelationShip({
    this.id,  // uuid
    this.senderId,
    this.receiverId,
    this.createdAt,
    this.status,
  });

  String? id;     // uuid
  String? senderId;
  String? receiverId;
  String? createdAt;
  String? status;     // FRIEND, BLOCK, BLOCKED, HIDE

  factory RelationShip.fromJson(Map<String, dynamic> data) {
    return RelationShip(
      id: data['id'],
      senderId: data['sender_id'],
      receiverId: data['receiver_id'],
      createdAt: data['created_at'],
      status: data['status'],
    );
  }

  void printOut() {
    debugPrint('------------- user info -------------');
    debugPrint('---> id: $id');
    debugPrint('---> senderId: $senderId');
    debugPrint('---> receiverId: $receiverId');
    debugPrint('---> createdAt: $createdAt');
    debugPrint('---> status: $status');
    debugPrint('-------------    end    -------------');
  }

  void reset() {
    id = null;
    senderId = null;
    receiverId = null;
    createdAt = null;
    status = null;
  }
}
