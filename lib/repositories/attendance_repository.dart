import 'dart:async';
import 'dart:convert';
import 'dart:io' show SocketException;

import 'package:flutter/foundation.dart' show kDebugMode, debugPrint;
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:http/http.dart' as http;

import '../core/api_config.dart';
import '../core/api_exception.dart';
import '../models/attendance.dart';
import '../models/employee_schedule.dart';
import '../providers/api_client.dart';

class AttendanceRepository {
  final http.Client _client; // AuthClient: adds auth headers + token refresh
  static const _timeout = Duration(seconds: 20);

  AttendanceRepository(this._client);

  Uri _uri(String path, [Map<String, String>? query]) =>
      Uri.parse('${ApiConfig.baseUrl}$path').replace(queryParameters: query);

  dynamic _decode(http.Response res) {
    dynamic body;
    try {
      body = jsonDecode(utf8.decode(res.bodyBytes));
    } catch (_) {
      body = null;
    }
    final ok = res.statusCode >= 200 && res.statusCode < 300;
    final appStatus = (body is Map && body['status'] is int)
        ? body['status'] as int
        : res.statusCode;

    if (!ok || appStatus < 200 || appStatus >= 300) {
      // The message is shown exactly as returned by the API.
      final msg = (body is Map && body['message'] != null)
          ? body['message'].toString()
          : 'Something went wrong ($appStatus)';
      if (kDebugMode && res.request != null) {
        debugPrint(
          'API ERROR [${res.request!.method} ${res.request!.url.path}] '
          '$appStatus: $msg',
        );
      }
      throw ApiException(msg, appStatus);
    }
    return body;
  }

  Future<T> _guard<T>(Future<T> Function() action) async {
    try {
      return await action();
    } on TimeoutException {
      throw ApiException('Connection timed out, please try again');
    } on SocketException {
      throw ApiException('Unable to connect to the server');
    } on http.ClientException {
      throw ApiException('Unable to connect to the server');
    }
  }

  /// GET waveup/my-schedule — schedules assigned to the logged-in user.
  Future<List<EmployeeSchedule>> getMySchedules() {
    return _guard(() async {
      final res = await _client
          .get(_uri(ApiConfig.mySchedulePath))
          .timeout(_timeout);
      final body = _decode(res);
      final data = body is Map ? body['data'] : null;
      if (data is! List) return <EmployeeSchedule>[];
      return data
          .whereType<Map>()
          .map((e) => EmployeeSchedule.fromJson(Map<String, dynamic>.from(e)))
          .toList();
    });
  }

  Future<Attendance> checkIn({
    required String idEmployeeSchedule,
    required double latitude,
    required double longitude,
    String photo = '',
  }) => _attend(
    ApiConfig.checkInPath,
    idEmployeeSchedule,
    latitude,
    longitude,
    photo,
  );

  Future<Attendance> checkOut({
    required String idEmployeeSchedule,
    required double latitude,
    required double longitude,
    String photo = '',
  }) => _attend(
    ApiConfig.checkOutPath,
    idEmployeeSchedule,
    latitude,
    longitude,
    photo,
  );

  /// Check-in and check-out share the same request body and response.
  Future<Attendance> _attend(
    String path,
    String idEmployeeSchedule,
    double latitude,
    double longitude,
    String photo,
  ) {
    return _guard(() async {
      final res = await _client
          .post(
            _uri(path),
            headers: {'Content-Type': 'application/json'},
            body: jsonEncode({
              'idEmployeeSchedule': idEmployeeSchedule,
              'latitude': latitude,
              'longitude': longitude,
              'photo': photo,
            }),
          )
          .timeout(_timeout);

      final body = _decode(res);
      final data = body is Map ? body['data'] : null;
      if (data is! Map) {
        throw ApiException('Invalid attendance response');
      }
      return Attendance.fromJson(Map<String, dynamic>.from(data));
    });
  }
}

final attendanceRepositoryProvider = Provider<AttendanceRepository>(
  (ref) => AttendanceRepository(ref.read(apiClientProvider)),
);