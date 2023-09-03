import 'dart:convert';
import 'package:http/http.dart' as http;

import '../controller/state_controller.dart';
import '../model/session.dart';
import '../resource/kConstant.dart';
import '../rest_api/api_resources.dart';

class PollApi {
  PollApi();

  static Future<dynamic> getPollOpen() async {
    HttpsResponse httpsResponse;
    String path = '/open';

    RESTApi.poll.headerQuery(path);

    http.Response res = await http.get(
        RESTApi.poll.url,
        headers: ApiFormat.acceptAuth,
    ).timeout(Duration(seconds: kConst.networkTimeout));

    httpsResponse = checkHttpsResponse(path, res);
    return Future.value(httpsResponse);
  }

  static Future<dynamic> postPollAnswer(int pollId, String userId) async {
    HttpsResponse httpsResponse;
    String path = '/answer';

    RESTApi.poll.headerQuery(path);

    final body = jsonEncode({
      'pollId': pollId,
      'chosenUserId': userId
    });

    http.Response res = await http.post(
      RESTApi.poll.url,
      headers: ApiFormat.acceptContentAuth,
      body: body
    ).timeout(Duration(seconds: kConst.networkTimeout));

    httpsResponse = checkHttpsResponse(path, res);
    return Future.value(httpsResponse);
  }

  static Future<dynamic> getPollResults(Paging? paging) async {
    HttpsResponse httpsResponse;
    String path = '/results';

    if (paging?.afterCursor?.isNotEmpty ?? false) {
      path += '?afterCursor=${paging!.afterCursor}';
    }

    RESTApi.poll.headerQuery(path);

    http.Response res = await http.get(
        RESTApi.poll.url,
        headers: ApiFormat.acceptAuth,
    ).timeout(Duration(seconds: kConst.networkTimeout));

    httpsResponse = checkHttpsResponse(path, res);
    return Future.value(httpsResponse);
  }
}