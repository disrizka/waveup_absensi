import 'dart:async';
import 'dart:convert';
import 'dart:io' show Platform, SocketException;

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:http/http.dart' as http;

import '../core/api_config.dart';
import '../core/api_exception.dart';
import '../models/session.dart';

final authHttpProvider = Provider<http.Client>((ref) {
  final client = http.Client();
  ref.onDispose(client.close);
  return client;
});

class AuthRepository {
  final http.Client _client;
  static const _timeout = Duration(seconds: 20);

  AuthRepository(this._client);

  Uri _uri(String path) => Uri.parse('${ApiConfig.baseUrl}$path');

  Map<String, dynamic> _decode(http.Response res) {
    dynamic body;
    try {
      body = jsonDecode(utf8.decode(res.bodyBytes));
    } catch (_) {
      body = null;
    }

    if (res.statusCode < 200 || res.statusCode >= 300) {
      final msg = (body is Map && body['message'] != null)
          ? body['message'].toString()
          : 'Terjadi kesalahan (${res.statusCode})';
      throw ApiException(msg, res.statusCode);
    }
    if (body is! Map) {
      throw ApiException('Response tidak valid dari server', res.statusCode);
    }
    return Map<String, dynamic>.from(body);
  }

  Future<T> _guard<T>(Future<T> Function() action) async {
    try {
      return await action();
    } on TimeoutException {
      throw ApiException('Koneksi timeout, coba lagi');
    } on SocketException {
      throw ApiException('Tidak dapat terhubung ke server');
    } on http.ClientException {
      throw ApiException('Tidak dapat terhubung ke server');
    }
  }

  Future<Session> login({
    required String user,
    required String password,
    required String deviceId,
    required String deviceName,
    required String fcmToken,
  }) {
    return _guard(() async {
      final res = await _client
          .post(
            _uri(ApiConfig.loginPath),
            headers: {
              'Content-Type': 'application/json',
              'Authorization': ApiConfig.basicAuth,
            },
            body: jsonEncode({
              'user': user,
              'password': password,
              'app': ApiConfig.app,
              'client': ApiConfig.client,
              'os': Platform.isIOS ? 'ios' : 'android',
              'device_id': deviceId,
              'device_name': deviceName,
              'fcm_token': fcmToken,
            }),
          )
          .timeout(_timeout);

      final body = _decode(res);
      if (body['status'] != 200) {
        throw ApiException(body['message']?.toString() ?? 'Login gagal');
      }
      return Session.fromJson(body);
    });
  }

  Future<String> refreshToken(String refreshToken) {
    return _guard(() async {
      final res = await _client.get(
        _uri(ApiConfig.refreshPath),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': ApiConfig.basicAuth,
          'Refresh-Token': refreshToken,
        },
      ).timeout(_timeout);

      final body = _decode(res);
      final token = body['access_token'] as String?;
      if (body['status'] != 200 || token == null || token.isEmpty) {
        throw ApiException('Refresh token gagal', body['status'] as int?);
      }
      return token;
    });
  }
}

final authRepositoryProvider =
    Provider<AuthRepository>((ref) => AuthRepository(ref.read(authHttpProvider)));