import 'package:flutter/material.dart';

import '../controller/state_controller.dart';
import '../resource/kConstant.dart';
import '../model/user.dart';

class CardBatch {
  CardBatch({
    this.id,
    this.userId,    // 받을 때 -> 보낸 사람, 보낼 때 - > 나
    this.startedAt,
    this.endedAt,
    this.cards,
  });

  int? id;
  String? userId;
  DateTime? startedAt;
  DateTime? endedAt;
  List<OmgCard>? cards;

  factory CardBatch.fromJson(Map<String, dynamic> data) {
    List<OmgCard> listCard = [];
    if (data['cards'] != null && data['cards'].isNotEmpty) {
      for (var e in data['cards']) {
        OmgCard res = OmgCard.fromJson(e);
        listCard.add(res);
      }
    }
    return CardBatch(
      id: data['id'],
      userId: data['userId'],
      startedAt: data['startedAt'] != null ? DateTime.parse(data['startedAt']) : null,
      endedAt: data['endedAt'] != null ? DateTime.parse(data['endedAt']) : null,
      cards: listCard,
    );
  }

  void printOut() {
    debugPrint('------------- card batch -------------');
    debugPrint('---> id: $id');
    debugPrint('---> userId: $userId');
    debugPrint('---> startedAt: $startedAt');
    debugPrint('---> endedAt: $endedAt');
    if (cards != null && cards!.isNotEmpty) {
      for (var e in cards!) {
        e.printOut();
      }
    }
    debugPrint('----------- card batch end -----------');
  }

  void reset() {
    id = null;
    userId = null;
    startedAt = null;
    endedAt = null;
    cards = null;
  }
}

class OmgCard {
  OmgCard({
    this.id,  //  카드 ID
    this.order,
    this.cardBatchId,
    this.cardTypeId,
    this.question,
    this.emoji,
    this.createdAt,
    this.updateAt,
    this.voteAt,
    this.commentedAt,
    this.senderId,    // 내가 보낸 경우 -> 내 ID, 받은 경우 -> 보낸 친구 ID
    this.receiverId,  // 1 of candidate (user id), 내가 보낸 경우 -> 친구 ID, 받은 경우 -> 나의 ID
    this.comment,
    this.candidateResetCount,
    this.isSkipped,
    this.isSpector,
    this.revealedFirstConsonant,
    this.revealedLastCharacter,
    this.revealedFullName,
    this.isCardReadByReceiver,
    this.isCommentReadBySender,
    this.likeCount,
    this.likedByMe,
    this.cardCount,
    this.candidates,
    this.sender,  // 내가 받은 카드
    this.receiver,  // 내가 보낸 카드
  });

  int? id;
  int? order;
  int? cardBatchId;
  int? cardTypeId;
  String? question;
  String? emoji;
  String? createdAt;
  String? updateAt;
  String? voteAt;
  String? commentedAt;
  String? senderId;
  String? receiverId;
  String? comment;
  int? candidateResetCount;   // response only from vote rest
  bool? isSkipped;    // response only from vote rest
  bool? isSpector;
  String? revealedFirstConsonant;
  String? revealedLastCharacter;
  String? revealedFullName;
  bool? isCardReadByReceiver;
  bool? isCommentReadBySender;
  dynamic likeCount;
  dynamic likedByMe;
  List<Candidate>? candidates;
  User? sender;
  User? receiver;
  dynamic cardCount;   // 최고 & 실시간 카드

  factory OmgCard.fromJson(Map<String, dynamic> data) {
    List<Candidate> listCandidates = [];
    User? senderInfo;
    User? receiverInfo;
    if (data['candidates'] != null && data['candidates'].isNotEmpty) {
      for (var e in data['candidates']) {
        Candidate res = Candidate.fromJson(e);
        listCandidates.add(res);
      }
    }
    if (data['sender'] != null) {
      senderInfo = User.fromJson(data['sender']);
    }
    if (data['receiver'] != null) {
      receiverInfo = User.fromJson(data['receiver']);
    }

    return OmgCard(
      id: data['id'],
      order: data['order'],
      cardBatchId: data['cardBatchId'],
      cardTypeId: data['cardTypeId'],
      question: data['question'],
      emoji: data['emoji'],
      createdAt: data['createdAt'],
      updateAt: data['updateAt'],
      voteAt: data['voteAt'],
      commentedAt: data['commentedAt'],
      senderId: data['senderId'],
      receiverId: data['receiverId'],
      comment: data['comment'],
      candidateResetCount: data['candidateResetCount'],
      isSkipped: data['isSkipped'],
      isSpector: data['isSpector'],
      revealedFirstConsonant: data['revealedFirstConsonant'],
      revealedLastCharacter: data['revealedLastCharacter'],
      revealedFullName: data['revealedFullName'],
      isCardReadByReceiver: data['isCardReadByReceiver'],
      isCommentReadBySender: data['isCommentReadBySender'],
      likeCount: data['likeCount'],
      likedByMe: data['likedByMe'],
      cardCount: data['cardCount'],
      candidates: listCandidates,
      sender: senderInfo,
      receiver: receiverInfo
    );
  }

  CardSendTo? get cardSendTo {
    bool? isSend;
    User? user;
    int? index;
    if (senderId == service.userMe.value.id) {
      isSend = true;   // card send
      if (candidates != null) {
        int i = 0;
        for (var e in candidates!) {
          if (e.userId == receiverId) { // 투료한 친구
            user = e.user;
            index = i;
          }
          i++;
        }
      }
    } else {
      isSend = false;
    }
    return CardSendTo(
        isSend: isSend,
        whoReceive: user,
        whereIndex: index
    );
  }

  CardReceiveFrom? get cardReceiveFrom {
    bool? isCardReceived;
    User? user;
    int? index;
    if (receiverId == service.userMe.value.id) {
      isCardReceived = true;   // card send
      if (candidates != null) {
        int i = 0;
        for (var e in candidates!) {
          if (e.userId == receiverId) { // 투료한 친구
            user = sender;
            index = i;
          }
          i++;
        }
      }
    } else {
      isCardReceived = false;
    }
    return CardReceiveFrom(
      isReceived: isCardReceived,
      whoSend: user,
      whereIndex: index
    );
  }

  void printOut() {
    debugPrint('\t------------- card -------------');
    debugPrint('\t---> id: $id');
    debugPrint('\t---> order: $order');
    debugPrint('\t---> createdAt: $createdAt');
    debugPrint('\t---> cardBatchId: $cardBatchId');
    debugPrint('\t---> cardTypeId: $cardTypeId');
    debugPrint('\t---> candidateResetCount: $candidateResetCount');
    debugPrint('\t---> isSkipped: $isSkipped');
    if (candidates != null && candidates!.isNotEmpty) {
      for (var e in candidates!) {
        e.printOut();
      }
    }
    sender?.printOut();
    receiver?.printOut();
    debugPrint('\t----------- card end -----------');
  }
}

class Candidate {
  Candidate({
    this.id,
    this.cardId,
    this.userId,    // used for vote
    this.user,
    this.fillBoxRatio   // todo > move to
  });

  int? id;
  int? cardId;
  String? userId;
  User? user;
  double? fillBoxRatio;    // 각 후보자 투표 받은 상태 gauge : 0 ~ 1

  factory Candidate.fromJson(Map<String, dynamic> data) {
    User? resUser;
    if (data['user'] != null) {
      resUser = User.fromJson(data['user']);
    }

    double? ratio;
    if (data['fillBoxRatio'] != null) {
      print('---> ${data['fillBoxRatio'].runtimeType}');
      ratio = double.parse(data['fillBoxRatio']);
    }

    return Candidate(
      id: data['id'],
      cardId: data['cardId'],
      userId: data['userId'],
      user: resUser,
      fillBoxRatio: ratio,
    );
  }

  void printOut() {
    debugPrint('\t\t------------- candidate -------------');
    debugPrint('\t\t---> id: $id');
    debugPrint('\t\t---> cardId: $cardId');
    debugPrint('\t\t---> userId: $userId');
    // debugPrint('\t\t---> fillBoxRatio: $fillBoxRatio');
    user?.printOut();
    debugPrint('\t\t----------- candidate end -----------');
  }
}

class CompactCard {
  CompactCard({
    this.id,
    this.question,
    this.emoji,
    this.votedAt,
    this.commentedOrCreatedAt,
    this.isSpector,
    this.comment,
    this.revealedLastCharacter,
    this.revealedFullName,
    this.isCommentReadBySender,
    this.isCardReadByReceiver,
    this.receiver,
    this.sender,
    this.likeCount,
    this.likedByMe
  });

  int? id;
  String? question;
  String? emoji;
  String? votedAt;
  String? commentedOrCreatedAt;
  bool? isSpector;
  String? comment;
  String? revealedLastCharacter;
  String? revealedFullName;
  bool? isCardReadByReceiver;
  bool? isCommentReadBySender;
  User? receiver;
  User? sender;
  int? likeCount;
  int? likedByMe;

  factory CompactCard.fromJson(Map<String, dynamic> data) {
    User? sender;
    if (data['sender'] != null) {
      sender = User.fromJson(data['sender']);
    }

    User? receiver;
    if (data['receiver'] != null) {
      receiver = User.fromJson(data['receiver']);
    }

    return CompactCard(
      id: data['id'],
      question: data['question'],
      emoji: data['emoji'],
      isSpector: data['isSpector'],
      votedAt: data['votedAt'],
      commentedOrCreatedAt: data['commentedOrCreatedAt'],
      comment: data['comment'],
      revealedLastCharacter: data['revealedLastCharacter'],
      revealedFullName: data['revealedFullName'],
      isCommentReadBySender: data['isCommentReadBySender'],
      isCardReadByReceiver: data['isCardReadByReceiver'],
      receiver: receiver,
      sender: sender,
      likeCount: data['likeCount'],
      likedByMe: data['likedByMe'],
    );
  }

  void printOut() {
    debugPrint('\t\t----------- card compact -----------');
    debugPrint('\t\t---> id: $id');
    debugPrint('\t\t---> question: $question');
    debugPrint('\t\t---> emoji: $emoji');
    debugPrint('\t\t---> votedAt: $votedAt');
    debugPrint('\t\t---> commentedOrCreatedAt: $commentedOrCreatedAt');
    debugPrint('\t\t---> isSpector: $isSpector');
    debugPrint('\t\t---> comment: $comment');
    debugPrint('\t\t---> revealedLastCharacter: $revealedLastCharacter');
    debugPrint('\t\t---> revealedFullName: $revealedFullName');
    debugPrint('\t\t---> isCardReadByReceiver: $isCardReadByReceiver');
    debugPrint('\t\t---> isCommentReadBySender: $isCommentReadBySender');
    debugPrint('\t\t---> likeCount: $likeCount');
    debugPrint('\t\t---> likedByMe: $likedByMe');
    debugPrint('\t\t------------- end -------------');
  }
}

class CardType {
  CardType({
    this.id,
    this.question,
    this.emoji,
  });

  int? id;
  String? question;
  String? emoji;

  factory CardType.fromJson(Map<String, dynamic> data) {
    return CardType(
      id: data['id'],
      question: data['question'],
      emoji: data['emoji'],
    );
  }

  void printOut() {
    debugPrint('\t---------- card type ----------');
    debugPrint('\t---> id: $id');
    debugPrint('\t---> question: $question');
    debugPrint('\t---> emoji: $emoji');
    debugPrint('\t-------- card type end --------');
  }
}

class CardReceiveFrom {
  CardReceiveFrom({
    this.isReceived,
    this.whoSend,
    this.whereIndex
  });

  bool? isReceived;
  User? whoSend;
  int? whereIndex;
}

class CardSendTo {
  CardSendTo({
    this.isSend,
    this.whoReceive,
    this.whereIndex
  });

  bool? isSend;
  User? whoReceive;
  int? whereIndex;
}

enum CardDirection {
  receive,
  send
}

enum VoteStatus {
  // start,
  completed,
  inProcess,
  // waiting,
  ready,
  none
}
