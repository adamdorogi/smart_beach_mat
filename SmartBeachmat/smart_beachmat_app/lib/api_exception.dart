import 'dart:io';

class ApiException implements IOException {
  final String message;
  final int statusCode;

  const ApiException(this.message, {this.statusCode});

  factory ApiException.fromJson(Map<String, dynamic> json) {
    return ApiException(
      json['error']['message'],
      statusCode: json['error']['status'],
    );
  }

  @override
  String toString() => 'ApiException: $statusCode: $message';
}
