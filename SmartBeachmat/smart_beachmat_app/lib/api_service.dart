import 'dart:convert';
import 'dart:io';

import 'package:device_info/device_info.dart';
import 'package:http/http.dart';

import 'package:smart_beachmat_app/api_exception.dart';
import 'package:smart_beachmat_app/models/secure_storage_provider.dart';
import 'package:smart_beachmat_app/models/user.dart';

// Singleton
class ApiService {
  static final ApiService _apiService = ApiService._();

  final String _scheme = 'http';
  final String _host = '192.168.1.110';
  final int _version = 1;

  factory ApiService() {
    return _apiService;
  }

  ApiService._(); // Constructor.

  bool _isSuccess(int statusCode) {
    return statusCode >= 200 && statusCode < 300;
  }

  Future<Response> _post(
      String url, Map<String, String> headers, Map<String, String> body) async {
    try {
      final Response response = await post(url, headers: headers, body: body);
      if (!_isSuccess(response.statusCode)) {
        throw ApiException.fromJson(json.decode(response.body));
      }
      return response;
    } on SocketException catch (_) {
      throw ApiException('Could not connect to internet.');
    }
  }

  Future<Response> _get(String url, Map<String, String> headers) async {
    try {
      final Response response = await get(url, headers: headers);
      if (!_isSuccess(response.statusCode)) {
        throw ApiException.fromJson(json.decode(response.body));
      }
      return response;
    } on SocketException catch (_) {
      throw ApiException('Could not connect to internet.');
    }
  }

  Future<Response> createToken({String email, String password}) async {
    DeviceInfoPlugin deviceInfo = DeviceInfoPlugin();
    String deviceId;
    String deviceName;

    if (Platform.isIOS) {
      IosDeviceInfo iosInfo = await deviceInfo.iosInfo;
      deviceId = iosInfo.identifierForVendor;
      deviceName = iosInfo.name;
    } else if (Platform.isAndroid) {
      AndroidDeviceInfo androidInfo = await deviceInfo.androidInfo;
      deviceId = androidInfo.androidId;
      deviceName = androidInfo.model;
    }

    return _post(
      '$_scheme://$_host/v$_version/tokens',
      {
        HttpHeaders.acceptHeader: 'application/json',
        HttpHeaders.contentTypeHeader: 'application/x-www-form-urlencoded',
      },
      {
        'email': email,
        'password': password,
        'device_id': deviceId,
        'device_name': deviceName,
      },
    );
  }

  Future<void> createAccount({String email, String password}) async {
    await _post(
      '$_scheme://$_host/v$_version/accounts',
      {
        HttpHeaders.acceptHeader: 'application/json',
        HttpHeaders.contentTypeHeader: 'application/x-www-form-urlencoded',
      },
      {
        'email': email,
        'password': password,
      },
    );
  }

  Future<void> createUser(User user) async {
    String token = await SecureStorageProvider.getToken();

    await _post(
      '$_scheme://$_host/v$_version/users',
      {
        HttpHeaders.acceptHeader: 'application/json',
        HttpHeaders.contentTypeHeader: 'application/x-www-form-urlencoded',
        HttpHeaders.authorizationHeader: token,
      },
      {
        'name': user.name,
        'skin_type': user.skinType.toString(),
        'dob': user.dob,
        'gender': user.gender,
      },
    );
  }

  Future<Response> readUsers() async {
    String token = await SecureStorageProvider.getToken();

    return _get(
      '$_scheme://$_host/v$_version/users',
      {
        HttpHeaders.acceptHeader: 'application/json',
        HttpHeaders.authorizationHeader: token,
      },
    );
  }
}
