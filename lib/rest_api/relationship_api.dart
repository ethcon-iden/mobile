import 'dart:convert';
import 'package:http/http.dart' as http;

import '../controller/state_controller.dart';
import '../model/session.dart';
import '../resource/kConstant.dart';
import '../rest_api/api_resources.dart';

class RelationshipApi {
  RelationshipApi();

  static Future<dynamic> postFollow(String targetUserId) async {
    String path = '/follow';
    HttpsResponse httpsResponse = await _callApi(path, targetUserId);
    return Future.value(httpsResponse);
  }

  static Future<dynamic> postUnfollow(String targetUserId) async {
    String path = '/unfollow';
    HttpsResponse httpsResponse = await _callApi(path, targetUserId);
    return Future.value(httpsResponse);
  }

  static Future<dynamic> postBlock(String targetUserId) async {
    String path = '/block';
    HttpsResponse httpsResponse = await _callApi(path, targetUserId);
    return Future.value(httpsResponse);
  }

  static Future<dynamic> postUnblock(String targetUserId) async {
    String path = '/unblock';
    HttpsResponse httpsResponse = await _callApi(path, targetUserId);
    return Future.value(httpsResponse);
  }

  static Future<dynamic> postHide(String targetUserId) async {
    String path = '/hide';
    HttpsResponse httpsResponse = await _callApi(path, targetUserId);
    return Future.value(httpsResponse);
  }

  static Future<dynamic> postUnhide(String targetUserId) async {
    String path = '/unhide';
    HttpsResponse httpsResponse = await _callApi(path, targetUserId);
    return Future.value(httpsResponse);
  }

  static Future<dynamic> postFavorite(String targetUserId) async {
    String path = '/favorite';
    HttpsResponse httpsResponse = await _callApi(path, targetUserId);
    return Future.value(httpsResponse);
  }

  static Future<dynamic> postUnFavorite(String targetUserId) async {
    String path = '/unfavorite';
    HttpsResponse httpsResponse = await _callApi(path, targetUserId);
    return Future.value(httpsResponse);
  }
  static Future<HttpsResponse> _callApi(String path, String targetUserId) async {

    RESTApi.relationship.headerQuery(path);

    http.Response res = await http.post(
        RESTApi.relationship.url,
        headers: RESTApi.relationship.header,
        body: jsonEncode({
          'targetUserId': targetUserId
        })
    ).timeout(Duration(seconds: kConst.networkTimeout));

    HttpsResponse httpsResponse = checkHttpsResponse(path, res);
    return Future.value(httpsResponse);
  }

  static Future<dynamic> getFollowContact({bool isContactBased = false, String? name}) async {
    String query = '';

    query += '?isContactBased=$isContactBased';
    if (name?.isNotEmpty == true) {
      query += '&includedName=$name';
    }

    String path = '/follow-recommend/contact$query';

    RESTApi.relationship.headerQuery(path);

    http.Response res = await http.get(
      RESTApi.relationship.url,
      headers: ApiFormat.acceptAuth,
    ).timeout(Duration(seconds: kConst.networkTimeout));

    HttpsResponse httpsResponse = checkHttpsResponse(path, res);
    return Future.value(httpsResponse);
  }

  static Future<dynamic> getFollowCommon({bool? isContactBased = false, Paging? paging, String? name}) async {
    String query = '';

    query = '?isContactBased=$isContactBased';
    if (paging?.afterCursor?.isNotEmpty == true) {
      query += '&afterCursor=${paging?.afterCursor}';
    }
    if (name?.isNotEmpty == true) {
      query += '&includedName=$name';
    }

    String path = '/follow-recommend/common$query';

    RESTApi.relationship.headerQuery(path);

    http.Response res = await http.get(
        RESTApi.relationship.url,
        headers: ApiFormat.acceptAuth,
    ).timeout(Duration(seconds: kConst.networkTimeout));

    HttpsResponse httpsResponse = checkHttpsResponse(path, res);
    return Future.value(httpsResponse);
  }

  static Future<dynamic> getFollowSameSchool({Paging? paging, String? name}) async {
    String query = '';
    String finalQuery = '';

    if (paging?.afterCursor?.isNotEmpty == true) {
      query += 'afterCursor=${paging?.afterCursor}&';
    }
    if (name?.isNotEmpty == true) {
      query += 'includedName=$name&';
    }
    if (query.isNotEmpty) {
      finalQuery = '?${query.substring(0, query.length - 1)}'; // 마지막 '&' 제거
    }

    String path = '/follow-recommend/school$finalQuery';

    RESTApi.relationship.headerQuery(path);

    http.Response res = await http.get(
      RESTApi.relationship.url,
      headers: ApiFormat.acceptAuth,
    ).timeout(Duration(seconds: kConst.networkTimeout));

    HttpsResponse httpsResponse = checkHttpsResponse(path, res);
    return Future.value(httpsResponse);
  }

  static Future<HttpsResponse> postFollowBatch(List<String> targetUserId) async {
    String path = '/follow/batch';

    RESTApi.relationship.headerQuery(path);

    final body = jsonEncode({
      'targetUserIds': targetUserId
    });

    print('---> post follow batch > body: $body');

    http.Response res = await http.post(
        RESTApi.relationship.url,
        headers: RESTApi.relationship.header,
        body: body
    ).timeout(Duration(seconds: kConst.networkTimeout));

    HttpsResponse httpsResponse = checkHttpsResponse(path, res);
    return Future.value(httpsResponse);
  }

  static Future<dynamic> getHide() async {
    String path = '/hide';

    RESTApi.relationship.headerQuery(path);

    http.Response res = await http.get(
      RESTApi.relationship.url,
      headers: ApiFormat.acceptAuth,
    ).timeout(Duration(seconds: kConst.networkTimeout));

    HttpsResponse httpsResponse = checkHttpsResponse(path, res);
    return Future.value(httpsResponse);
  }

  static Future<dynamic> getBlock() async {
    String path = '/block';

    RESTApi.relationship.headerQuery(path);

    http.Response res = await http.get(
      RESTApi.relationship.url,
      headers: ApiFormat.acceptAuth,
    ).timeout(Duration(seconds: kConst.networkTimeout));

    HttpsResponse httpsResponse = checkHttpsResponse(path, res);
    return Future.value(httpsResponse);
  }

  static Future<dynamic> getFollowing({bool? isFavorite, String? name}) async {
    String path = '/following';
    String query = '';
    String finalQuery = '';

    if (isFavorite != null) {
      query += 'isFavorite=$isFavorite&';
    }
    if (name?.isNotEmpty == true) {
      query += 'includedName=$name&';
    }

    if (query.isNotEmpty) {
      finalQuery = '$path?${query.substring(0, query.length - 1)}';  // 마지막 '&' 제거
    } else {
      query = path;
    }

    RESTApi.relationship.headerQuery(finalQuery);

    http.Response res = await http.get(
      RESTApi.relationship.url,
      headers: ApiFormat.acceptAuth,
    ).timeout(Duration(seconds: kConst.networkTimeout));

    HttpsResponse httpsResponse = checkHttpsResponse('/relationship$path', res);
    return Future.value(httpsResponse);
  }
}