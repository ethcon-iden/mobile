import 'dart:convert';
import 'package:http/http.dart' as http;

import '../model/user.dart';
import '../model/session.dart';
import '../resource/kConstant.dart';
import '../rest_api/api_resources.dart';
import '../controller/state_controller.dart';

class UserApi {
  UserApi();

  static Future<dynamic> postMobileOTP() async {
    HttpsResponse httpsResponse;

    final body = json.encode({
      'phoneNumber': service.phoneNumber.value
    });

    http.Response res = await http.post(
        RESTApi.mobileOTP.url,
        headers: RESTApi.mobileOTP.header,
        body: body
    ).timeout(Duration(seconds: kConst.networkTimeout));

    httpsResponse = checkHttpsResponse('postMobileOTP', res);
    return Future.value(httpsResponse);
  }

  static Future<dynamic> postVerifySmsCode(String code) async {
    final body = json.encode({
      'phoneNumber': service.phoneNumber.value,
      'code': code
    });

    http.Response res = await http.post(
        RESTApi.verifySmsCode.url,
        headers: RESTApi.verifySmsCode.header,
        body: body
    ).timeout(Duration(seconds: kConst.networkTimeout));

    HttpsResponse httpsResponse = checkHttpsResponse('verify sms code', res);
    return Future.value(httpsResponse);
  }

  static Future<dynamic> postRegister() async {
    final body = User().toJson();
    print('---> UserApi > postRegister > body: $body');

    http.MultipartRequest request = http.MultipartRequest(
        'POST',
        RESTApi.userRegister.url
    );

    request.fields.addAll(body);
    if (service.profileImage.value.isNotEmpty) {
      request.files.add(
          await http.MultipartFile.fromPath('profileImage', service.profileImage.value)
      );
    }

    print('---> UserApi > post Register >fields: ${request.fields.toString()}');

    http.StreamedResponse streamedResponse = await request.send();
    final res = await http.Response.fromStream(streamedResponse);

    HttpsResponse httpsResponse = checkHttpsResponse('postRegister', res);
    return Future.value(httpsResponse);
  }

  static Future<dynamic> getUserMe() async {
    http.Response res = await http.get(
        Uri.parse('${kConst.domain}/user/me'),
        headers: RESTApi.userMe.header,
    ).timeout(Duration(seconds: kConst.networkTimeout));

    HttpsResponse httpsResponse = checkHttpsResponse('getUserMe', res);
    return Future.value(httpsResponse);
  }

  static Future<dynamic> updateUserMe(String field, String value) async {
    print('---> UserApi > updateUserMe > data: $field - $value');

    http.MultipartRequest request = http.MultipartRequest(
        'PATCH',
        RESTApi.userMeUpdate.url
    );

    request.headers.addAll(RESTApi.userMeUpdate.header);
    request.fields[field] = value;

    print('---> UserApi > updateUserMe > fields: ${request.fields.toString()}');

    http.StreamedResponse streamedResponse = await request.send();
    final res = await http.Response.fromStream(streamedResponse);

    HttpsResponse httpsResponse = checkHttpsResponse('updateUserMe', res);
    return Future.value(httpsResponse);
  }

  static Future<dynamic> updateProfileImage(String image) async {
    http.MultipartRequest request = http.MultipartRequest(
        'PATCH',
        RESTApi.userMeUpdate.url
    );

    request.headers.addAll(RESTApi.userMeUpdate.header);

    if (image.isNotEmpty) {
      request.files.add(
          await http.MultipartFile.fromPath('profileImage', image)
      );
    } else {  // remove image from server
      request.fields['profileImage'] = image;
    }

    http.StreamedResponse streamedResponse = await request.send();
    final res = await http.Response.fromStream(streamedResponse);

    HttpsResponse httpsResponse = checkHttpsResponse('updateProfileImage', res);
    return Future.value(httpsResponse);
  }

  static Future<dynamic> checkNickname(String nickname) async {
    HttpsResponse httpsResponse;

    String query = '?exactName=$nickname';

    RESTApi.user.headerQuery(query);

    http.Response res = await http.get(
        RESTApi.user.url,
        headers: RESTApi.user.header,
    ).timeout(Duration(seconds: kConst.networkTimeout));

    httpsResponse = checkHttpsResponse(query, res);
    return Future.value(httpsResponse);
  }

  static Future<dynamic> getUpdateHistory() async {
    HttpsResponse httpsResponse;
    String path = '/update-history';

    RESTApi.userMe.headerQuery(path);

    http.Response res = await http.get(
      RESTApi.userMe.url,
      headers: RESTApi.userMe.header,
    ).timeout(Duration(seconds: kConst.networkTimeout));

    httpsResponse = checkHttpsResponse(path, res);
    return Future.value(httpsResponse);
  }

  static Future<dynamic> getUser({bool? following, String? includedNameOrNickname, String? exactName,
    String? exactNickname, String? grade, int? schoolId, Paging? paging}) async {
    String query = '';
    String finalQuery = '';

    if (following == true || following == false) {
      query += 'following=$following&';
    }
    if (includedNameOrNickname?.isNotEmpty == true) {
      query += 'includedNameOrNickname=$includedNameOrNickname&';
    }
    if (exactName?.isNotEmpty == true) {
      query += 'exactName=$exactName&';
    }
    if (exactNickname?.isNotEmpty == true) {
      query += 'exactNickname=$exactNickname&';
    }
    if (grade?.isNotEmpty == true) {
      query += 'grade=$grade&';
    }
    if (schoolId != null) {
      query += 'schoolId=$schoolId&';
    }
    if (paging?.afterCursor?.isNotEmpty == true) {
      query += 'afterCursor=${paging?.afterCursor}&';
    }

    if (query.isNotEmpty) {
      finalQuery = '?${query.substring(0, query.length - 1)}';  // 마지막 '&' 제거
    }

    RESTApi.user.headerQuery(finalQuery);

    http.Response res = await http.get(
      RESTApi.user.url,
      headers: RESTApi.user.header,
    ).timeout(Duration(seconds: kConst.networkTimeout));

    HttpsResponse httpsResponse = checkHttpsResponse('user$finalQuery', res);
    return Future.value(httpsResponse);
  }

  static Future<dynamic> getUserCount(String? userId) async {
    String path = '/count';

    if (userId?.isNotEmpty == true) {
      path += '?userId=$userId';
    }

    RESTApi.user.headerQuery(path);

    http.Response res = await http.get(
      RESTApi.user.url,
      headers: RESTApi.user.header,
    ).timeout(Duration(seconds: kConst.networkTimeout));

    HttpsResponse httpsResponse = checkHttpsResponse('/user$path', res);
    return Future.value(httpsResponse);
  }

  static Future<dynamic> getUserInfo(String userId) async {
    String url = '${kConst.domain}/user/$userId';

    http.Response res = await http.get(
      Uri.parse(url),
      headers: RESTApi.user.header,
    ).timeout(Duration(seconds: kConst.networkTimeout));

    HttpsResponse httpsResponse = checkHttpsResponse(url, res);
    return Future.value(httpsResponse);
  }
}