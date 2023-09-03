import 'dart:convert';
import 'package:http/http.dart' as http;

import '../controller/state_controller.dart';
import '../model/session.dart';
import '../model/user.dart';
import '../resource/kConstant.dart';
import '../rest_api/api_resources.dart';

class CardApi {
  CardApi();

  static final CardApi _instance = CardApi();

  static Future<dynamic> getCount() async {
    String path = '/count';

    RESTApi.card.headerQuery(path);

    http.Response res = await http.get(
      RESTApi.card.url,
      headers: RESTApi.card.header,
    ).timeout(Duration(seconds: kConst.networkTimeout));

    HttpsResponse httpsResponse = checkHttpsResponse(path, res);
    return Future.value(httpsResponse);
  }

  static Future<dynamic> postCardBatchStart() async {
    String path = '/batch/start';
    HttpsResponse httpsResponse = await _instance._callApi(path);
    return Future.value(httpsResponse);
  }

  static Future<dynamic> getCardBatchOpen() async {
    String path = '/batch/open';

    RESTApi.card.headerQuery(path);

    http.Response res = await http.get(
      RESTApi.card.url,
      headers: RESTApi.card.header,
    ).timeout(Duration(seconds: kConst.networkTimeout));

    HttpsResponse httpsResponse = checkHttpsResponse(path, res);
    return Future.value(httpsResponse);
  }

  static Future<dynamic> postCardReset(int cardId) async {
    String path = '/$cardId/reset';
    HttpsResponse httpsResponse = await _instance._callApi(path);
    return Future.value(httpsResponse);
  }

  Future<HttpsResponse> _callApi(String path) async {
    RESTApi.card.headerQuery(path);

    http.Response res = await http.post(
      RESTApi.card.url,
      headers: RESTApi.card.header,
    ).timeout(Duration(seconds: kConst.networkTimeout));

    HttpsResponse httpsResponse = checkHttpsResponse(path, res);
    return Future.value(httpsResponse);
  }

  static Future<dynamic> postCardVote(int cardId, String candidateUserId, bool isSpectorMode) async {
    String path = '/$cardId/vote';

    RESTApi.cardVote.headerQuery(path);

    final body = json.encode({
      'isSpector': isSpectorMode,
      'candidateUserId': candidateUserId
    });

    http.Response res = await http.post(
        RESTApi.cardVote.url,
        headers: RESTApi.cardVote.header,
        body: body
    ).timeout(Duration(seconds: kConst.networkTimeout));

    HttpsResponse httpsResponse = checkHttpsResponse(path, res);
    return Future.value(httpsResponse);
  }

  static Future<dynamic> postCardVoteDirect(int cardId, String candidateUserId, bool isSpectorMode) async {
    String path = '/$cardId/vote/direct';

    RESTApi.cardVote.headerQuery(path);

    final body = jsonEncode({
      'isSpector': isSpectorMode,
      'candidateUserId': candidateUserId
    });

    http.Response res = await http.post(
        RESTApi.cardVote.url,
        headers: RESTApi.cardVote.header,
        body: body
    ).timeout(Duration(seconds: kConst.networkTimeout));

    HttpsResponse httpsResponse = checkHttpsResponse(path, res);
    return Future.value(httpsResponse);
  }

  static Future<dynamic> getCardReceived(String? userId, bool? hasUnread, Gender? senderGender,
      bool? hasNameRevealed, Paging? paging) async {
    String query = '';
    String finalQuery = '';
    
    if (paging?.afterCursor != null) {
      query += 'afterCursor=${paging?.afterCursor}&';
    }

    if (userId?.isNotEmpty == true) { // 유저 이이디, null -> 내가 받은 카드
      query += 'userId=$userId&';
    }

    if (hasUnread != null) {    // 읽지 않은 카드
      query += 'filterUnreadCard=$hasUnread&';
    }

    if (senderGender != null) {   // 남학생/여학생이 보낸 카드
      query += 'senderGender=${senderGender.name}&';
    }

    if (hasNameRevealed != null) { // 이름 확인한 카드
      query += 'filterNameRevealed=$hasNameRevealed&';
    }

    if (query.isNotEmpty) {
      finalQuery = '?${query.substring(0, query.length - 1)}'; // 마지막 '&' 제거
    }
    String path = '${kConst.domain}/card/received$finalQuery';
    
    http.Response res = await http.get(
      Uri.parse(path),
      headers: RESTApi.card.header,
    ).timeout(Duration(seconds: kConst.networkTimeout));

    HttpsResponse httpsResponse = checkHttpsResponse(path, res);
    return Future.value(httpsResponse);
  }

  static Future<dynamic> getCardSent(String? userId, bool? hasComment, Gender? receiverGender,
      Paging? paging) async {
    String query = '';
    String finalQuery = '';

    if (paging?.afterCursor != null) {
      query += 'afterCursor=${paging?.afterCursor}&';
    }

    if (userId?.isNotEmpty == true) { // 유저 이이디, null -> 내가 보낸 카드
      query += 'userId=$userId&';
    }

    if (hasComment != null) {    // 답글 달린 카드
      query += 'filterCommented=$hasComment&';
    }

    if (receiverGender != null) {   // 받는 친구 셩별 (남학생/여학생)
      query += 'receiverGender=${receiverGender.name}&';
    }

    if (query.isNotEmpty) {
      finalQuery = '?${query.substring(0, query.length - 1)}'; // 마지막 '&' 제거
    }

    String path = '${kConst.domain}/card/sent$finalQuery';

    http.Response res = await http.get(
      Uri.parse(path),
      headers: RESTApi.card.header,
    ).timeout(Duration(seconds: kConst.networkTimeout));

    HttpsResponse httpsResponse = checkHttpsResponse(path, res);
    return Future.value(httpsResponse);
  }

  static Future<dynamic> postMarkReadAllReceivedCards() async {
    String path = '/read/all-received';

    RESTApi.card.headerQuery(path);

    http.Response res = await http.post(
        RESTApi.card.url,
        headers: RESTApi.card.header,
    ).timeout(Duration(seconds: kConst.networkTimeout));

    HttpsResponse httpsResponse = checkHttpsResponse(path, res);
    return Future.value(httpsResponse);
  }

  static Future<dynamic> getCardInfo(int cardId) async {
    String path = '${kConst.domain}/card/$cardId';

    http.Response res = await http.get(
      Uri.parse(path),
      headers: RESTApi.card.header,
    ).timeout(Duration(seconds: kConst.networkTimeout));

    HttpsResponse httpsResponse = checkHttpsResponse(path, res);
    return Future.value(httpsResponse);
  }

  static Future<dynamic> postComment(int cardId, String comment) async {
    String path = '/$cardId/comment';

    RESTApi.card.headerQuery(path);

    final body = jsonEncode({
      'comment': comment,
    });

    http.Response res = await http.post(
        RESTApi.card.url,
        headers: ApiFormat.acceptContentAuth,
        body: body
    ).timeout(Duration(seconds: kConst.networkTimeout));

    HttpsResponse httpsResponse = checkHttpsResponse(path, res);
    return Future.value(httpsResponse);
  }

  static Future<dynamic> deleteComment(int cardId) async {
    String path = '/$cardId/comment';

    RESTApi.card.headerQuery(path);

    http.Response res = await http.delete(
        RESTApi.card.url,
        headers: ApiFormat.acceptAuth,
    ).timeout(Duration(seconds: kConst.networkTimeout));

    HttpsResponse httpsResponse = checkHttpsResponse(path, res);
    return Future.value(httpsResponse);
  }

  static Future<dynamic> getFeed(bool? filterFavorite, Paging? paging) async {
    String path = '/feed';
    String query = '';
    String finalQuery = '';

    if (paging?.afterCursor != null) {
      query += 'afterCursor=${paging?.afterCursor}&';
    }

    if (filterFavorite != null) {   // 관심 친구 피드만 볼 것인지 여부
      query += 'filterFavorite=$filterFavorite&';
    }

    if (query.isNotEmpty) {
      finalQuery = '?${query.substring(0, query.length - 1)}'; // 마지막 '&' 제거
    }

    path += finalQuery;

    RESTApi.card.headerQuery(path);

    http.Response res = await http.get(
      RESTApi.card.url,
      headers: RESTApi.card.header,
    ).timeout(Duration(seconds: kConst.networkTimeout));

    HttpsResponse httpsResponse = checkHttpsResponse('card$path', res);
    return Future.value(httpsResponse);
  }

  static Future<dynamic> postLike(int cardId) async {
    String path = '/$cardId/like';

    RESTApi.card.headerQuery(path);

    http.Response res = await http.post(
        RESTApi.card.url,
        headers: ApiFormat.acceptAuth,
    ).timeout(Duration(seconds: kConst.networkTimeout));

    HttpsResponse httpsResponse = checkHttpsResponse(path, res);
    return Future.value(httpsResponse);
  }

  static Future<dynamic> postUnlike(int cardId) async {
    String path = '/$cardId/unlike';

    RESTApi.card.headerQuery(path);

    http.Response res = await http.post(
      RESTApi.card.url,
      headers: ApiFormat.acceptAuth,
    ).timeout(Duration(seconds: kConst.networkTimeout));

    HttpsResponse httpsResponse = checkHttpsResponse(path, res);
    return Future.value(httpsResponse);
  }

  static Future<dynamic> getBestCard(String userId) async {
    String path = '/best?userId=$userId';

    RESTApi.card.headerQuery(path);

    http.Response res = await http.get(
      RESTApi.card.url,
      headers: RESTApi.card.header,
    ).timeout(Duration(seconds: kConst.networkTimeout));

    HttpsResponse httpsResponse = checkHttpsResponse('/card$path', res);
    return Future.value(httpsResponse);
  }

  static Future<dynamic> getRecentCard(String userId, Paging paging) async {
    // String path = '/recent?userId=$userId&afterCursor=${paging.afterCursor}&beforeCursor=${paging.beforeCursor}';
    String path = '/recent?userId=$userId';

    if (paging.afterCursor?.isNotEmpty == true) {
      path += '&afterCursor=${paging.afterCursor}';
    }

    RESTApi.card.headerQuery(path);

    http.Response res = await http.get(
      RESTApi.card.url,
      headers: RESTApi.card.header,
    ).timeout(Duration(seconds: kConst.networkTimeout));

    HttpsResponse httpsResponse = checkHttpsResponse('/card$path', res);
    return Future.value(httpsResponse);
  }
}