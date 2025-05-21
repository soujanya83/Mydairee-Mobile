import 'dart:convert';

import 'package:flutter/cupertino.dart';
import 'package:http/http.dart';
import 'package:mykronicle_mobile/main.dart';
import 'package:http/http.dart' as http;

class Service {
  final Map<String, String> body;
  final String loginURL;

  Service(this.loginURL, this.body);

  Future data() async {
    debugPrint(loginURL);
    debugPrint('post api called for...data');
    debugPrint(jsonEncode(body));
    Response response = await post(Uri.parse(loginURL), body: jsonEncode(body));
    debugPrint(response.body);
    var status = jsonDecode(response.body);
    debugPrint('dasss' + status.toString());
    if (status['Status'] == 'SUCCESS') {
      String data = response.body;
      return jsonDecode(data);
    } else {
      return {
        "error": status['Message'],
      };
    }
  }
}

class ServiceWithHeader {
  final String url;

  ServiceWithHeader(this.url);

  Future data() async {
    print('get api called for...');
    final response = await http.get(Uri.parse(url), headers: {
      'X-DEVICE-ID': await MyApp.getDeviceIdentity(),
      'X-TOKEN': MyApp.AUTH_TOKEN_VALUE,
    });
    print(url);
    MyApp.getDeviceIdentity().then((value) => print('deviceid' + value));
    debugPrint(MyApp.AUTH_TOKEN_VALUE);
    debugPrint(response.body);
    debugPrint(response.statusCode.toString());
    String cleanedJson = cleanJson(response.body);
    var status = jsonDecode(cleanedJson);
    debugPrint('heee' + status['Status'].toString());
    if (status['Status'] == 'SUCCESS') {
      return jsonDecode(cleanedJson);
    } else {
      return {
        "error": status['Message'],
      };
    }
  }
}

class ServiceWithHeaderPost {
  final String url;

  ServiceWithHeaderPost(this.url);

  Future data() async {
    print('post api called for...without body');
    final response = await http.post(
      Uri.parse(url),
      headers: {
        'X-DEVICE-ID': await MyApp.getDeviceIdentity(),
        'X-TOKEN': MyApp.AUTH_TOKEN_VALUE,
      },
    );
    debugPrint(url);
    MyApp.getDeviceIdentity().then((value) => print('deviceid' + value));
    debugPrint(MyApp.AUTH_TOKEN_VALUE);
    var status = jsonDecode(response.body);
    if (status['Status'] == 'SUCCESS'){
      String data = response.body;
      return jsonDecode(data);
    } else {
      return {
        "error": status['Message'],
      };
    }
  }
}

class ServiceWithHeaderDataPost {
  final String url;
  final Map<String, dynamic> b;

  ServiceWithHeaderDataPost(this.url, this.b);

  Future data() async {
    print('post api called for...');
    debugPrint(jsonEncode(b));
    final response = await http.post(
      Uri.parse(url),
      headers: {
        'X-DEVICE-ID': await MyApp.getDeviceIdentity(),
        'X-TOKEN': MyApp.AUTH_TOKEN_VALUE, 
      },
      body: jsonEncode(b),
    );
    print('after post api...........');
    debugPrint(url);
    debugPrint(b.toString());
    print({
      'X-DEVICE-ID': await MyApp.getDeviceIdentity(),
      'X-TOKEN': MyApp.AUTH_TOKEN_VALUE,
    });
    MyApp.getDeviceIdentity().then((value) => print('deviceid' + value));
    debugPrint('authtoken' + MyApp.AUTH_TOKEN_VALUE);
    debugPrint('status code ' + response.statusCode.toString());
    debugPrint('dataaa' + response.body.toString());
    String cleanedJson = cleanJson(response.body);
    debugPrint('clean response'+ cleanedJson);
    var status = jsonDecode(cleanedJson);
    if (status['Status'] == 'SUCCESS' ||
        status['Status'] == 'Success' ||
        status['Status'] == true ||
        status['status'] == true ||
        status['status'] == 'success' ||
        status['success'] == true ||
        status['Success'] == true) {
      // String data = response.body;
      return jsonDecode(cleanedJson);
    } else {
      return {
        "error": status['Message'],
      };
    }
  }
}

String cleanJson(String responseBody) {
  int startIndex = responseBody.indexOf('{');
  int endIndex = responseBody.lastIndexOf('}');

  if (startIndex != -1 && endIndex != -1) {
    return responseBody.substring(startIndex, endIndex + 1);
  } else {
    throw FormatException('Invalid JSON format');
  }
}
