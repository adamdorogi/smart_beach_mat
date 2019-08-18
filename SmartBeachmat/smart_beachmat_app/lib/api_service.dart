import 'dart:convert';
import 'dart:io';

import 'package:http/http.dart';

import 'package:smart_beachmat_app/api_exception.dart';

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

  Future<void> createAccount({String email, String password}) async {
    final Response response = await post(
      '$_scheme://$_host/v$_version/accounts',
      headers: {
        HttpHeaders.acceptHeader: 'application/json',
        HttpHeaders.contentTypeHeader: 'application/x-www-form-urlencoded',
      },
      body: {
        'email': email,
        'password': password,
      },
    );

    if (!_isSuccess(response.statusCode)) {
      throw ApiException.fromJson(json.decode(response.body));
    }
  }
}
