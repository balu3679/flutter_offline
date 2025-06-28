import 'dart:convert';
import 'dart:developer';

import 'package:http/http.dart' as http;
import 'package:regres/utils/constants.dart';

class Userservice {
  Uri getlink(url) {
    final urllink = url + '&api_key=$apiKey';
    log(urllink);
    return Uri.parse(urllink);
  }

  Future<dynamic> getusers({required int page}) async {
    try {
      final resp = await http.get(getlink('$baseURL?page=$page'));
      if (resp.statusCode == 200) {
        final body = json.decode(resp.body);
        return body;
      }
      throw Exception('Failed to fetch api with ${resp.statusCode}');
    } catch (e) {
      throw Exception(e);
    }
  }
}
