import 'dart:convert';
import 'package:http/http.dart' as http;

import '../controller/state_controller.dart';
import '../model/session.dart';
import '../resource/kConstant.dart';

class RESTApi {
  // user
  static ApiFormat mobileOTP = ApiFormat(   // request sms code
    address: '${kConst.domain}/user/send-verification-code',
    headerType: _HeaderType.acceptContent
  );
  static ApiFormat verifySmsCode = ApiFormat(   // send sms code for verification
    address: '${kConst.domain}/user/verify-phone-number',
    headerType: _HeaderType.acceptContent,
  );
  static ApiFormat userMe = ApiFormat(
      address: '${kConst.domain}/user/me',
      headerType: _HeaderType.acceptAuth
  );
  static ApiFormat user = ApiFormat(
      address: '${kConst.domain}/user',
      headerType: _HeaderType.acceptAuth
  );
  static ApiFormat userRegister = ApiFormat(
      address: '${kConst.domain}/user/register',
      headerType: {'accept': 'application/json', 'Content-Type': 'multipart/form-data'}
  );
  static ApiFormat userMeUpdate = ApiFormat(
      address: '${kConst.domain}/user/me',
      headerType: _HeaderType.patchUser
  );
  /// school
  static ApiFormat searchSchool = ApiFormat(
    address: '${kConst.domain}/school',
    headerType: _HeaderType.accept
  );
  /// card
  static ApiFormat card = ApiFormat(
      address: '${kConst.domain}/card',
      headerType: _HeaderType.acceptAuth
  );
  static ApiFormat cardVote = ApiFormat(
      address: '${kConst.domain}/card',
      headerType: _HeaderType.acceptContentAuth
  );
  // relationship
  static ApiFormat relationship = ApiFormat(
      address: '${kConst.domain}/relationship',
      headerType: _HeaderType.acceptContentAuth
  );
  // cookie
  static ApiFormat cookie = ApiFormat(
      address: '${kConst.domain}/cookie',
      headerType: {'accept': '*/*'}
  );
  // payment
  static ApiFormat payment = ApiFormat(
      address: '${kConst.domain}/payment/omg-pass',
      headerType: _HeaderType.acceptContentAuth
  );
  // item
  static ApiFormat item = ApiFormat(
      address: '${kConst.domain}/item',
      headerType: _HeaderType.acceptAuth
  );
  // contact
  static ApiFormat contact = ApiFormat(
      address: '${kConst.domain}/contact',
      headerType: _HeaderType.acceptContentAuth
  );
  // poll
  static ApiFormat poll = ApiFormat(
      address: '${kConst.domain}/poll',
      headerType: _HeaderType.acceptAuth
  );
  // notification
  static ApiFormat notification = ApiFormat(
      address: '${kConst.domain}/notification',
      headerType: _HeaderType.acceptAuth
  );
}

class ApiFormat {
  String address;
  dynamic headerType;

  ApiFormat({
    required this.address,
    required this.headerType,
  });

  static dynamic accept = {'accept': 'application/json'};
  static dynamic acceptContent = {'accept': 'application/json', 'Content-Type': 'application/json'};
  static dynamic acceptAuth = {'accept': 'application/json', 'Authorization': 'Bearer ${service.accessToken.value}'};
  static dynamic acceptContentAuth = {'accept': 'application/json', 'Content-Type': 'application/json',
    'Authorization': 'Bearer ${service.accessToken.value}'};
  static dynamic patchUser = {'accept': 'application/json', 'Content-Type': 'multipart/form-data',
    'Authorization': 'Bearer ${service.accessToken.value}'};

  // set path parameters and get
  String _newAddress = '';
  void headerQuery(String query) {
    _newAddress = address + query;
  }
  Uri get url {
    Uri out;
    if (_newAddress.isNotEmpty) {
      out = Uri.parse(_newAddress);
    } else {
      out = Uri.parse(address);
    }
    return out;
  }
  // get header
  dynamic get header {
    dynamic out;
    if (headerType == _HeaderType.accept) {
      out = accept;
    } else if (headerType == _HeaderType.acceptAuth) {
      out = acceptAuth;
    } else if (headerType == _HeaderType.acceptContent) {
      out = acceptContent;
    } else if (headerType == _HeaderType.patchUser) {
      out = patchUser;
    } else {
      out = acceptContentAuth;
    }
    return out;
  }
}

enum _HeaderType {
  accept,
  acceptContent,
  acceptAuth,
  acceptContentAuth,
  patchUser
}

HttpsResponse checkHttpsResponse(String path, http.Response res) {
  final statusCode = res.statusCode;
  print('---> _checkResponse ($path) > status code: $statusCode');
  final responseBody = res.body;
  print('---> _checkResponse ($path) > responseBody: $responseBody');

  dynamic body;
  if (responseBody.isNotEmpty) {
    body = json.decode(responseBody);
  }

  StatusType statusType;
  dynamic result;
  if (200 <= statusCode && statusCode <= 299) {  // return success
    result = body;

    if (body != null) {
      statusType = StatusType.success;
    } else {
      statusType = StatusType.empty;
    }

  } else {  // return error
    statusType = StatusType.error;
    result = ErrorResponse.fromJson(body);
  }

  HttpsResponse httpsResponse = HttpsResponse(
      statusCode: statusCode,
      statusType: statusType,
      body: result
  );
  return httpsResponse;
}