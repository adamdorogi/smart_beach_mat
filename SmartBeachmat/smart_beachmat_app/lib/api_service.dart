import 'dart:convert';
import 'dart:io';

import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:http/http.dart';

import 'package:smart_beachmat_app/api_exception.dart';
import 'package:smart_beachmat_app/user.dart';

// Singleton
class ApiService {
  static final ApiService _apiService = ApiService._internal();

  final String _scheme = 'http';
  final String _host = 'localhost';
  final int _version = 1;

  factory ApiService() {
    return _apiService;
  }

  ApiService._internal(); // Constructor.

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

  Future<Response> createToken({String email, String password}) async {
    return _post(
      '$_scheme://$_host/v$_version/tokens',
      {
        HttpHeaders.acceptHeader: 'application/json',
        HttpHeaders.contentTypeHeader: 'application/x-www-form-urlencoded',
      },
      {
        'email': email,
        'password': password,
        'ip_address': '12.34.56.78',
        'device_id': '9ffbd91f-b710-42c6-9bef-6fd5d64b1592',
        'device_name': 'Test iPhone'
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
    FlutterSecureStorage storage = FlutterSecureStorage();
    String token = await storage.read(key: 'token');

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
}
