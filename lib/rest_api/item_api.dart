import 'dart:convert';
import 'package:http/http.dart' as http;

import '../model/session.dart';
import '../resource/kConstant.dart';
import '../rest_api/api_resources.dart';

class ItemApi {
  ItemApi();

  static Future<dynamic> getPrices() async {
    HttpsResponse httpsResponse;
    String path = '/prices';
    RESTApi.item.headerQuery(path);

    http.Response res = await http.get(
      RESTApi.item.url,
      headers: RESTApi.item.header,
    ).timeout(Duration(seconds: kConst.networkTimeout));

    httpsResponse = checkHttpsResponse(path, res);
    return Future.value(httpsResponse);
  }

  static Future<dynamic> getMyOmpPass() async {
    HttpsResponse httpsResponse;
    String path = '/my-omg-pass';
    RESTApi.item.headerQuery(path);

    http.Response res = await http.get(
        RESTApi.item.url,
        headers: RESTApi.item.header,
    ).timeout(Duration(seconds: kConst.networkTimeout));

    httpsResponse = checkHttpsResponse(path, res);
    return Future.value(httpsResponse);
  }

  static Future<dynamic> postItemBuy4InjectRandom() async {   // 100 cookie
    HttpsResponse httpsResponse;
    String path = '/buy/inject-to-random-friends';
    RESTApi.item.headerQuery(path);

    http.Response res = await http.post(
      RESTApi.item.url,
      headers: RESTApi.item.header,
    ).timeout(Duration(seconds: kConst.networkTimeout));

    httpsResponse = checkHttpsResponse(path, res);
    return Future.value(httpsResponse);
  }

  static Future<dynamic> postItemBuy4InjectCertain(String userId) async {   // 300 cookie
    HttpsResponse httpsResponse;
    String path = '/buy/inject-to-certain-friend';
    RESTApi.item.headerQuery(path);

    final body = jsonEncode({
      'targetId': userId
    });

    http.Response res = await http.post(
      RESTApi.item.url,
      headers: RESTApi.item.header,
      body: body
    ).timeout(Duration(seconds: kConst.networkTimeout));

    httpsResponse = checkHttpsResponse(path, res);
    return Future.value(httpsResponse);
  }

  static Future<dynamic> postItemBuy4lastCharacter(String cardId) async {   // 400 cookie
    HttpsResponse httpsResponse;
    String path = '/buy/inject-to-certain-friend';
    RESTApi.item.headerQuery(path);

    final body = jsonEncode({
      'cardId': cardId
    });

    http.Response res = await http.post(
      RESTApi.item.url,
      headers: ApiFormat.acceptContentAuth,
      body: body
    ).timeout(Duration(seconds: kConst.networkTimeout));

    httpsResponse = checkHttpsResponse(path, res);
    return Future.value(httpsResponse);
  }

  // HttpsResponse _checkResponse(String path, http.Response res) {
  //   final statusCode = res.statusCode;
  //   print('---> _checkResponse ($path) > status code: $statusCode');
  //   final responseBody = res.body;
  //   print('---> _checkResponse ($path) > responseBody: $responseBody');
  //
  //   dynamic body;
  //   if (responseBody.isNotEmpty) {
  //     body = json.decode(responseBody);
  //   }
  //
  //   StatusType statusType;
  //   dynamic result;
  //   if (200 <= statusCode && statusCode <= 299) {  // return success
  //     result = body;
  //
  //     if (body != null) {
  //       statusType = StatusType.success;
  //     } else {
  //       statusType = StatusType.empty;
  //     }
  //
  //   } else {  // return error
  //     statusType = StatusType.error;
  //     result = ErrorResponse.fromJson(body);
  //   }
  //
  //   HttpsResponse httpsResponse = HttpsResponse(
  //       statusCode: statusCode,
  //       statusType: statusType,
  //       body: result
  //   );
  //   return httpsResponse;
  // }
}