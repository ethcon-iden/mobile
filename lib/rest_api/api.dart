import 'dart:convert';
import 'package:http/http.dart' as http;

import '../model/session.dart';
import '../model/user.dart';
import '../resource/kConstant.dart';
import '../rest_api/api_resources.dart';
import '../controller/state_controller.dart';

class IdenApi {
  IdenApi();

  static Future<dynamic> postRegister(String name, String email, String phoneNumber,
      String department, String duty) async {
    String url = '${kConst.domain}/user/register';

    final Map<String, String> body = {
      'name': name,
      'email': email,
      'phoneNumber': phoneNumber,
      'gender': 'male',
      'affiliation': department,
      'duty': duty,
    };

    http.MultipartRequest request = http.MultipartRequest(
        'POST',
        Uri.parse(url)
    );

    request.fields.addAll(body);

    print('---> UserApi > post Register >fields: ${request.fields.toString()}');

    http.StreamedResponse streamedResponse = await request.send();
    final res = await http.Response.fromStream(streamedResponse);

    HttpsResponse httpsResponse = checkHttpsResponse(url, res);
    return Future.value(httpsResponse);
  }

  static Future<dynamic> postEmail(String keyShare) async {
    String path = '${kConst.domain}/user/mail';

    final body = jsonEncode({
      'email': 'yj990315@gmail.com',
      'splitKey': keyShare
    });

    http.Response res = await http.post(
        Uri.parse(path),
        headers: {'accept': '*/*', 'Content-Type': 'application/json'},
        body: body
    ).timeout(Duration(seconds: kConst.networkTimeout));

    HttpsResponse httpsResponse = checkHttpsResponse(path, res);
    return Future.value(httpsResponse);
  }

  static Future<dynamic> getFollowContact({bool isContactBased = false, String? name, String? afterCursor}) async {
    String query = '';

    query += '?isContactBased=$isContactBased';
    if (name?.isNotEmpty == true) {
      query += '&includedName=$name';
    }
    if (afterCursor?.isNotEmpty == true) {
      query += '&afterCursor=$afterCursor';
    }

    String path = '${kConst.domain}/relationship/follow-recommend/contact$query';

    RESTApi.relationship.headerQuery(path);

    http.Response res = await http.get(
      Uri.parse(path),
      headers: {'accept': 'application/json', 'Authorization': 'Bearer ${service.accessToken.value}'}
    ).timeout(Duration(seconds: kConst.networkTimeout));

    HttpsResponse httpsResponse = checkHttpsResponse(path, res);
    return Future.value(httpsResponse);
  }

  static Future<dynamic> updateProfileImage(String image) async {
    String url = '${kConst.domain}/user/me';
    http.MultipartRequest request = http.MultipartRequest(
        'PATCH',
        Uri.parse(url)
    );

    Map<String, String> header = {'accept': 'application/json', 'Content-Type': 'multipart/form-data',
      'Authorization': 'Bearer ${service.accessToken.value}'};

    request.headers.addAll(header);

    if (image.isNotEmpty) {
      request.files.add(
          await http.MultipartFile.fromPath('profileImage', image)
      );
    } else {  // remove image from server
      request.fields['profileImage'] = image;
    }

    http.StreamedResponse streamedResponse = await request.send();
    final res = await http.Response.fromStream(streamedResponse);

    HttpsResponse httpsResponse = checkHttpsResponse(url, res);
    return Future.value(httpsResponse);
  }

  static Future<dynamic> postContact() async {
    String path = '${kConst.domain}/contact';

    final body = jsonEncode({
      'displayName': '정장원',
      'phoneNumber': '01024559761'
    });

    http.Response res = await http.post(
        Uri.parse(path),
        headers: {'accept': 'application/json', 'Content-Type': 'application/json',
          'Authorization': 'Bearer ${service.accessToken.value}'},
        body: body
    ).timeout(Duration(seconds: kConst.networkTimeout));

    HttpsResponse httpsResponse = checkHttpsResponse(path, res);
    return Future.value(httpsResponse);
  }

  static Future<dynamic> getCardBatchStart() async {
    String path = '${kConst.domain}/card/batch/start';

    http.Response res = await http.post(
        Uri.parse(path),
        headers: {'accept': 'application/json', 'Authorization': 'Bearer ${service.accessToken.value}'},
    ).timeout(Duration(seconds: kConst.networkTimeout));

    HttpsResponse httpsResponse = checkHttpsResponse(path, res);
    return Future.value(httpsResponse);
  }

  static Future<dynamic> getCardBatch() async {
    String path = '${kConst.domain}/card/batch';

    http.Response res = await http.post(
      Uri.parse(path),
      headers: {'accept': 'application/json', 'Authorization': 'Bearer ${service.accessToken.value}'},
    ).timeout(Duration(seconds: kConst.networkTimeout));

    HttpsResponse httpsResponse = checkHttpsResponse(path, res);
    return Future.value(httpsResponse);
  }

  static Future<dynamic> getUserCount(String? userId) async {
    String path = '${kConst.domain}/user/count';

    if (userId?.isNotEmpty == true) {
      path += '?userId=$userId';
    }

    http.Response res = await http.get(
      Uri.parse(path),
      headers: {'accept': 'application/json', 'Authorization': 'Bearer ${service.accessToken.value}'},
    ).timeout(Duration(seconds: kConst.networkTimeout));

    HttpsResponse httpsResponse = checkHttpsResponse('/user$path', res);
    return Future.value(httpsResponse);
  }

  static Future<dynamic> getIdenTokenBalance() async {
    String path = '${kConst.domain}/cookie/balance';

    http.Response res = await http.get(
      Uri.parse(path),
      headers: {'accept': 'application/json', 'Authorization': 'Bearer ${service.accessToken.value}'},
    ).timeout(Duration(seconds: kConst.networkTimeout));

    HttpsResponse httpsResponse = checkHttpsResponse(path, res);
    return Future.value(httpsResponse);
  }

  static Future<dynamic> postCardVote(int cardId, String candidateUserId, bool isSpectorMode) async {
    String path = '${kConst.domain}/card/$cardId/vote';

    Map<String, String> header = {'accept': 'application/json', 'Content-Type': 'application/json',
      'Authorization': 'Bearer ${service.accessToken.value}'};

    final body = jsonEncode({
      'isSpector': isSpectorMode,
      'candidateUserId': candidateUserId
    });

    http.Response res = await http.post(
        Uri.parse(path),
        headers: header,
        body: body
    ).timeout(Duration(seconds: kConst.networkTimeout));

    HttpsResponse httpsResponse = checkHttpsResponse('$path | body: $body', res);
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
      headers: {'accept': 'application/json', 'Authorization': 'Bearer ${service.accessToken.value}'}
    ).timeout(Duration(seconds: kConst.networkTimeout));

    HttpsResponse httpsResponse = checkHttpsResponse(path, res);
    return Future.value(httpsResponse);
  }

  static Future<dynamic> getFeed(bool? filterFavorite, Paging? paging) async {
    String path = '${kConst.domain}/card/feed';
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

    http.Response res = await http.get(
      Uri.parse(path),
      headers: {'accept': 'application/json', 'Authorization': 'Bearer ${service.accessToken.value}'},
    ).timeout(Duration(seconds: kConst.networkTimeout));

    HttpsResponse httpsResponse = checkHttpsResponse(path, res);
    return Future.value(httpsResponse);
  }

  static Future<dynamic> postFollowBatch(List<String> userIds) async {
    String url = '${kConst.domain}/relationship/follow/batch';

    Map<String, String> header = {'accept': 'application/json', 'Content-Type': 'application/json',
      'Authorization': 'Bearer ${service.accessToken.value}'};

    // List<Map<String, String>> dataset = List.generate(userIds.length, (index) => {
    //   'targetUserIds': userIds[index]
    // });

    final body = jsonEncode({
      'targetUserIds': userIds
    });

    http.Response res = await http.post(
        Uri.parse(url),
        headers: header,
        body: body
    ).timeout(Duration(seconds: kConst.networkTimeout));

    HttpsResponse httpsResponse = checkHttpsResponse('$url | body: $body', res);
    return Future.value(httpsResponse);
  }

  static Future<dynamic> getBestCard(String userId) async {
    String url = '${kConst.domain}/card/best?userId=$userId';

    http.Response res = await http.get(
      Uri.parse(url),
      headers: {'accept': 'application/json', 'Authorization': 'Bearer ${service.accessToken.value}'},
    ).timeout(Duration(seconds: kConst.networkTimeout));

    HttpsResponse httpsResponse = checkHttpsResponse(url, res);
    return Future.value(httpsResponse);
  }
}