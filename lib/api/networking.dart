import 'dart:convert';

import 'package:http/http.dart';
import 'package:mykronicle_mobile/main.dart';
import 'package:http/http.dart' as http;

class Service {
  final Map<String, String> body;
  final String loginURL;

  Service(this.loginURL, this.body);

  Future data() async {
    print(loginURL);
    
    print(jsonEncode(body));
    Response response = await post(Uri.parse(loginURL), body: jsonEncode(body));
    print(response.body);
    var status = jsonDecode(response.body);
    print('dasss' + status.toString());
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
    final response = await http.get(Uri.parse(url), headers: {
      'X-DEVICE-ID': await MyApp.getDeviceIdentity(),
      'X-TOKEN': MyApp.AUTH_TOKEN_VALUE,
    });
    print(url);
    MyApp.getDeviceIdentity().then((value) => print('deviceid' + value));
    print(MyApp.AUTH_TOKEN_VALUE);
    print(response.body);
    print(response.statusCode);
    var status = jsonDecode(response.body);
    print('heee' + status['Status'].toString());
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

class ServiceWithHeaderPost {
  final String url;

  ServiceWithHeaderPost(this.url);

  Future data() async {
    final response = await http.post(Uri.parse(url), headers: {
      'X-DEVICE-ID': await MyApp.getDeviceIdentity(),
      'X-TOKEN': MyApp.AUTH_TOKEN_VALUE,
    });
    print(url);
    MyApp.getDeviceIdentity().then((value) => print('deviceid' + value));
    print(MyApp.AUTH_TOKEN_VALUE);
    var status = jsonDecode(response.body);
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

class ServiceWithHeaderDataPost {
  final String url;
  final Map<String, dynamic> b;

  ServiceWithHeaderDataPost(this.url, this.b);

  Future data() async {
    print('post api called for...');
    print(jsonEncode(b));
    final response = await http.post(
      Uri.parse(url),
      headers: {
        'X-DEVICE-ID': await MyApp.getDeviceIdentity(),
        'X-TOKEN': MyApp.AUTH_TOKEN_VALUE,
      },
      body: jsonEncode(b),
    );
    print(url);
    MyApp.getDeviceIdentity().then((value) => print('deviceid' + value));
    print('authtoken' + MyApp.AUTH_TOKEN_VALUE);
    print('dataaa' + response.body.toString());
    var status = jsonDecode(response.body);
    if (status['Status'] == 'SUCCESS' || status['Status'] == 'Success') {
      String data = response.body;
      return jsonDecode(data);
    } else {
      return {
        "error": status['Message'],
      };
    }
  }
}
