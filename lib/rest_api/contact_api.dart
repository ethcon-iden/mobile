import 'dart:convert';
import 'package:http/http.dart' as http;

import '../../model/contact.dart';
import '../model/session.dart';
import '../resource/kConstant.dart';
import '../rest_api/api_resources.dart';

class ContactApi {
  ContactApi();

  static Future<dynamic> postContact(List<MyContact> contacts) async {
    HttpsResponse httpsResponse;

    List<Map<String, String?>> dataset = [];

    if (contacts.isNotEmpty) {
      for (var e in contacts) {
        if (e.phones != null && e.phones!.isNotEmpty) {
          for (var d in e.phones!) {
            dataset.add({
              'displayName': e.displayName,
              'phoneNumber': d,
            });
          }
        }
      }
    }

    final body = jsonEncode({
      'contacts': dataset
    });

    print('---> contact body: $body');

    http.Response res = await http.post(
        RESTApi.contact.url,
        headers: RESTApi.contact.header,
        body: body
    ).timeout(Duration(seconds: kConst.networkTimeout));

    httpsResponse = checkHttpsResponse('postContact', res);
    return Future.value(httpsResponse);
  }
}