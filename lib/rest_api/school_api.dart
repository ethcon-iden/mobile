// import 'package:path_provider/path_provider.dart';

import 'dart:convert';
import 'package:http/http.dart' as http;

import '../model/school.dart';
import '../model/session.dart';
import '../resource/kConstant.dart';
import '../rest_api/api_resources.dart';
import '../controller/state_controller.dart';

class SchoolApi {
  SchoolApi();

  static Future<dynamic> getSearch(String school, Paging? paging) async {
    HttpsResponse httpsResponse;

    RESTApi.searchSchool.headerQuery('?name=$school');

    if (paging != null) {
      if (paging.pageCursor != null) {
        if (paging.pageCursor == PageCursor.before) {
          if (paging.beforeCursor != null) {
            RESTApi.searchSchool.headerQuery(
                '?name=$school&beforeCursor=${paging.beforeCursor}');
          }
        } else {
          if (paging.afterCursor != null) {
            RESTApi.searchSchool.headerQuery(
                '?name=$school&afterCursor=${paging.afterCursor}');
          }
        }
      }
    }

    http.Response res = await http.get(
        RESTApi.searchSchool.url,
        headers: RESTApi.searchSchool.header,
    ).timeout(Duration(seconds: kConst.networkTimeout));

    final statusCode = res.statusCode;
    print('---> SchoolApi postSearch > status code: $statusCode');
    final decodedData = utf8.decode(res.bodyBytes);
    print('---> SchoolApi postSearch > decoded data: $decodedData');

    dynamic response;
    if (decodedData.isNotEmpty) {
      response = json.decode(decodedData);
    }

    StatusType statusType;
    dynamic result;
    if (200 <= statusCode && statusCode <= 299) {  // return success
      if (response != null) {
        statusType = StatusType.success;
        result = response;
      } else {
        statusType = StatusType.empty;
        result = response;
      }
    } else {  // return error
      statusType = StatusType.error;
      result = ErrorResponse.fromJson(response);
    }

    httpsResponse = HttpsResponse(
        statusCode: statusCode,
        statusType: statusType,
        body: result);
    return Future.value(httpsResponse);
  }
}