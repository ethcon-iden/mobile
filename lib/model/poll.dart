import 'package:flutter/material.dart';

import 'user.dart';
import '../services/utils.dart';

class SchoolPoll {
  SchoolPoll({
    this.id,
    this.question,
    this.voteCount,
    this.users,
    this.startedAt,
    this.closedAt,
  });

  String? id;
  String? question;
  List<int>? voteCount;
  List<User>? users;
  DateTime? startedAt;
  DateTime? closedAt;

  factory SchoolPoll.fromJson(Map<String, dynamic> data) {
    List<User> users = [];
    if (data['users'] != null) {
      for (var e in data['users']) {
        users.add(User.fromJson(e));
      }
    }

    return SchoolPoll(
      id: data['id'],
      question: data['question'],
      voteCount: data['voteCount'],
      users: users,
      startedAt: data['startedAt'] != null ? DateTime.parse(data['startedAt']) : null,
      closedAt: data['closedAt'] != null ? DateTime.parse(data['closedAt']) : null,
    );
  }

  void printOut() {
    debugPrint('------------ poll info ------------');
    debugPrint('---> id: $id');
    debugPrint('---> name: $question');
    debugPrint('---> bio: $users');
    debugPrint('---> startedAt: $startedAt');
    debugPrint('---> closedAt: $closedAt');
    if (users != null) {
      for (var e in users!) {
        e.printOut();
      }
    }
    debugPrint('------------- poll end -----------');
  }

  void reset() {
    id = null;
    question = null;
    voteCount = null;
    startedAt = null;
    closedAt = null;
  }
}

class PollOpen {
  PollOpen({
    this.status,
    this.polls,
    this.answers,
  });

  PollStatus? status;
  List<PollResult>? polls;
  List<PollAnswers>? answers;

  factory PollOpen.fromJson(Map<String, dynamic> data) {
    List<PollResult> polls = [];
    List<PollAnswers> pollAnswers = [];
    if (data['polls'] != null) {
      for (var e in data['polls']) {
        polls.add(
            PollResult.fromJson(e)
        );
      }
    }

    if (data['answers'] != null) {
      for (var e in data['answers']) {
        pollAnswers.add(
            PollAnswers.fromJson(e)
        );
      }
    }

    PollStatus? pollStatus;
    if (data['status'] != null) {
      String status = data['status'];
      if (status == 'UNAVAILABLE') {
        pollStatus = PollStatus.unavailable;
      } else if (status == 'OPEN') {
        pollStatus = PollStatus.open;
      } else if (status == 'ONGOING') {
        pollStatus = PollStatus.ongoing;
      } else if (status == 'ANSWERED') {
        pollStatus = PollStatus.answered;
      } else if (status == 'CLOSED') {
        pollStatus = PollStatus.closed;
      }
    }
    return PollOpen(
      status: pollStatus,
      polls: polls,
      answers: pollAnswers,
    );
  }
}

class PollResult {
  PollResult({
    this.id,
    this.pollQuestionId,
    this.question,
    this.emojiKey,
    this.schoolId,
    this.createdAt,
    this.weekOf,
    this.endedAt,
    this.order,
    this.isDefault,
    this.rankings
  });

  int? id;
  int? pollQuestionId;
  String? question;
  String? emojiKey;
  int? schoolId;
  DateTime? createdAt;
  DateTime? weekOf;
  DateTime? endedAt;
  int? order;
  bool? isDefault;
  List<PollRanking>? rankings;

  factory PollResult.fromJson(Map<String, dynamic> data) {
    List<PollRanking> pollRankings = [];
    if (data['rankings'] != null) {
      for (var e in data['rankings']) {
        pollRankings.add(PollRanking.fromJson(e));
      }
    }
    return PollResult(
        id: data['id'],
        pollQuestionId: data['pollQuestionId'],
        question: data['question'],
        emojiKey: data['emojiKey'],
        schoolId: data['schoolId'],
        createdAt: data['createdAt'] != null ? DateTime.parse(data['createdAt']) : null,
        weekOf: data['weekOf'] != null ? DateTime.parse(data['weekOf']) : null,
        endedAt: data['endedAt'] != null ? DateTime.parse(data['endedAt']) : null,
        order: data['order'],
        isDefault: data['isDefault'],
        rankings: pollRankings
    );
  }

  String? get weekOfMonth {
    String? out;
    if (weekOf != null) {
      out = CalendarUtil.getWeekOfMonth(weekOf);
    }
    return out;
  }
}

class PollAnswers {
  PollAnswers({
    this.id,
    this.pollId,
    this.chosenUserId,
    this.answererUserId,
    this.createdAt,
  });

  int? id;
  int? pollId;
  String? chosenUserId;
  String? answererUserId;
  DateTime? createdAt;

  factory PollAnswers.fromJson(Map<String, dynamic> data) {
    return PollAnswers(
      id: data['id'],
      pollId: data['pollId'],
      chosenUserId: data['chosenUserId'],
      answererUserId: data['answererUserId'],
      createdAt: data['createdAt'] != null ? DateTime.parse(data['createdAt']) : null,
    );
  }
}

class PollRanking {
  PollRanking({
    this.user,
    this.ranking,
    this.voteCount,
  });

  User? user;
  int? ranking;
  int? voteCount;

  factory PollRanking.fromJson(Map<String, dynamic> data) {
    User? userInfo;
    if (data['user'] != null) {
      userInfo = User.fromJson(data['user']);
    }
    return PollRanking(
      user: userInfo,
      ranking: data['ranking'],
      voteCount: data['voteCount'],
    );
  }
}

enum PollStatus {
  unavailable,
  open,
  ongoing,
  answered,
  closed
}