import 'package:flutter/material.dart';

class HttpsResponse {
  int statusCode;
  StatusType? statusType;
  dynamic body;

  HttpsResponse({
    required this.statusCode,
    this.body,
    this.statusType
  });
}

class ErrorResponse {
  ErrorResponse({
    this.error,
    this.message,
    this.code,
    this.statusCode
  });

  String? error;
  String? message;
  String? code;
  int? statusCode;

  factory ErrorResponse.fromJson(Map<String, dynamic> data) {
    return ErrorResponse(
        error: data['error'],
        message: data['message'],
        code: data['code'],
        statusCode: data['statusCode']
    );
  }

  void printOut() {
    debugPrint('----------- ErrorResponse ------------');
    debugPrint('---> error: $error');
    debugPrint('---> message: $message');
    debugPrint('---> code: $code');
    debugPrint('---> statusCode: $statusCode');
    debugPrint('-------------    end    -------------');
  }

  void reset() {
    error = null;
    message = null;
    statusCode = null;
    code = null;
  }
}

enum StatusType {
  success,
  error,
  empty,
}
