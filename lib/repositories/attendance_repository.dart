import 'dart:async';
import 'dart:convert';
import 'dart:io' show SocketException;

import 'package:flutter/foundation.dart' show kDebugMode, debugPrint;
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:http/http.dart' as http;

import '../core/api_config.dart';
import '../core/api_exception.dart';
import '../models/attendance.dart';
import '../providers/api_client.dart';

class AttendanceRepository {
  final http.Client _client; // AuthClient: otomatis Bearer + refresh token
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
      final msg = (body is Map && body['message'] != null)
          ? body['message'].toString()
          : 'Terjadi kesalahan ($appStatus)';
      if (kDebugMode && res.request != null) {
        debugPrint(
          'API ERROR [${res.request!.method} ${res.request!.url.path}] '
          '$appStatus: $msg',
        );
      }
      throw ApiException(msg, appStatus); // pesan persis dari API
    }
    return body;
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

  /// Cari idEmployeeSchedule yang berlaku hari ini.
  /// Jadwal dipilih bila `days` memuat hari ini (1 = Senin ... 7 = Minggu).
  /// Jika ada beberapa jadwal, utamakan yang daftar employee-nya memuat
  /// [userName]; jika tidak ada yang cocok, pakai jadwal pertama.
  Future<String> getTodayScheduleId({
    required String idBusiness,
    required DateTime today,
    String userName = '',
  }) {
    return _guard(() async {
      final res = await _client
          .get(
            _uri(ApiConfig.schedulePath(idBusiness), {
              'page': '1',
              'limit': '100',
            }),
          )
          .timeout(_timeout);
      final body = _decode(res);

      final data = body is Map ? body['data'] : null;
      if (data is! List || data.isEmpty) {
        throw ApiException('Belum ada jadwal kerja');
      }

      final todays = <Map<String, dynamic>>[];
      for (final e in data) {
        if (e is! Map) continue;
        final days = e['days'];
        if (days is List &&
            days.map((d) => d.toString()).contains('${today.weekday}')) {
          todays.add(Map<String, dynamic>.from(e));
        }
      }
      if (todays.isEmpty) {
        throw ApiException('Tidak ada jadwal kerja untuk hari ini');
      }

      Map<String, dynamic> pick = todays.first;
      final name = userName.trim().toLowerCase();
      if (name.isNotEmpty && todays.length > 1) {
        for (final sch in todays) {
          final emps = sch['employees'];
          if (emps is List &&
              emps.any(
                (x) =>
                    x is Map &&
                    (x['name'] ?? '').toString().trim().toLowerCase() == name,
              )) {
            pick = sch;
            break;
          }
        }
      }

      final id = (pick['idEmployeeSchedule'] ?? '').toString();
      if (id.isEmpty) throw ApiException('Jadwal hari ini tidak ditemukan');
      return id;
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

  /// Check-in & check-out memakai body dan response yang sama.
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
        throw ApiException('Response absensi tidak valid');
      }
      return Attendance.fromJson(Map<String, dynamic>.from(data));
    });
  }
}

final attendanceRepositoryProvider = Provider<AttendanceRepository>(
  (ref) => AttendanceRepository(ref.read(apiClientProvider)),
);
