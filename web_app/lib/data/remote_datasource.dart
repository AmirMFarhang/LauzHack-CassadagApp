import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;

import '../config/core/http_exception_helper.dart';
import '../config/core/services/event_bus.dart';
import '../config/core/services/locator.dart';
import 'local_datasource.dart';

class API {
  var client = http.Client();
  Bus eventbus = locator<Bus>();

  final LocalDataSource localDB = locator<LocalDataSource>();

  void printWrapped(String text) {
    final pattern = RegExp('.{1,800}');
    pattern.allMatches(text).forEach((match) {
      if (kDebugMode) {
        print(match.group(0));
      }
    });
  }

  dynamic _response(http.Response response) {
    switch (response.statusCode) {
      case 200:
        var responseJson = json.decode(response.body.toString());
        // printWrapped(response.body);

        return responseJson;
      case 400:
        throw BadRequestException(response.body.toString());
      case 404:
        Map<String, dynamic> responseMap =
            json.decode(response.body.toString());
        throw BadRequestException(response.body.toString());
      case 403:
        throw UnauthorisedException(response.body.toString());
      default:
        throw FetchDataException(
            'Internal server error: ${response.statusCode}');
    }
  }

}
