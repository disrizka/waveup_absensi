import 'dart:async';
import 'dart:convert';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

import '../core/api_exception.dart';
import '../models/attendance.dart';
import '../repositories/attendance_repository.dart';
import 'session_provider.dart';
import '../services/location_service.dart';

String _todayStr([DateTime? d]) {
  final n = d ?? DateTime.now();
  return '${n.year}-${n.month.toString().padLeft(2, '0')}-${n.day.toString().padLeft(2, '0')}';
}

/// State: null = belum check-in hari ini.
class AttendanceNotifier extends AsyncNotifier<Attendance?> {
  static const _key = 'waveup_attendance_today';
  final _storage = const FlutterSecureStorage();

  @override
  Future<Attendance?> build() async {
    try {
      final raw = await _storage.read(key: _key);
      if (raw == null) return null;
      final a = Attendance.fromJson(jsonDecode(raw));
      return a.date == _todayStr() ? a : null; // data hari lain dibuang
    } catch (_) {
      return null;
    }
  }

  /// Tentukan idEmployeeSchedule untuk hari ini.
  Future<String> _scheduleId(AttendanceRepository repo) async {
    final session = ref.read(sessionProvider).valueOrNull;

    // 1) Utama: jadwal yang dikirim server saat login (milik akun ini).
    final mine = session?.schedules ?? const [];
    if (mine.isNotEmpty) {
      final today = DateTime.now().weekday; // 1 = Senin ... 7 = Minggu
      for (final sch in mine) {
        if (sch.appliesTo(today) && sch.idEmployeeSchedule.isNotEmpty) {
          return sch.idEmployeeSchedule;
        }
      }
      throw ApiException('Tidak ada jadwal kerja untuk hari ini');
    }

    // 2) Cadangan (sesi lama tanpa data jadwal): ambil dari API per bisnis.
    final ids = (session?.businesses ?? [])
        .map((b) => b.idBusiness)
        .where((id) => id.isNotEmpty)
        .toList();
    if (ids.isEmpty) {
      throw ApiException('Data bisnis tidak ditemukan, silakan login ulang');
    }

    ApiException? lastError;
    for (final id in ids) {
      try {
        return await repo.getTodayScheduleId(
          idBusiness: id,
          today: DateTime.now(),
          userName: session?.user.fullName ?? '',
        );
      } on ApiException catch (e) {
        lastError = e; // coba bisnis berikutnya
      }
    }
    throw lastError!;
  }

  /// Alur: lokasi -> ambil jadwal hari ini -> POST check-in.
  /// Melempar ApiException jika gagal (ditangkap UI).
  Future<Attendance> checkIn() async {
    final repo = ref.read(attendanceRepositoryProvider);

    final pos = await LocationService.current();
    final scheduleId = await _scheduleId(repo);

    try {
      final result = await repo.checkIn(
        idEmployeeSchedule: scheduleId,
        latitude: pos.latitude,
        longitude: pos.longitude,
      );
      await _save(result);
      return result;
    } on ApiException catch (e) {
      if (e.message.toLowerCase().contains('already checked in')) {
        await _save(
          Attendance(
            idEmployeeAttendance: '',
            idEmployee: '',
            idEmployeeSchedule: scheduleId,
            date: _todayStr(),
            assumedCheckedIn: true,
          ),
        );
        rethrow; // tampilkan pesan asli dari API
      }
      rethrow;
    }
  }

  Future<void> _save(Attendance a) async {
    await _storage.write(key: _key, value: jsonEncode(a.toJson()));
    state = AsyncData(a);
  }

  /// Alur: lokasi -> (pakai jadwal dari check-in tadi) -> POST check-out.
  Future<Attendance> checkOut() async {
    final repo = ref.read(attendanceRepositoryProvider);
    final current = state.valueOrNull;

    final pos = await LocationService.current();
    final scheduleId =
        (current != null && current.idEmployeeSchedule.isNotEmpty)
        ? current.idEmployeeSchedule
        : await _scheduleId(repo);

    try {
      final result = await repo.checkOut(
        idEmployeeSchedule: scheduleId,
        latitude: pos.latitude,
        longitude: pos.longitude,
      );
      await _save(result);
      return result;
    } on ApiException catch (e) {
      if (e.message.toLowerCase().contains('already checked out')) {
        await _save(
          Attendance(
            idEmployeeAttendance: current?.idEmployeeAttendance ?? '',
            idEmployee: current?.idEmployee ?? '',
            idEmployeeSchedule: scheduleId,
            date: _todayStr(),
            checkInAt: current?.checkInAt,
            assumedCheckedIn: true,
            assumedCheckedOut: true,
          ),
        );
        rethrow; // tampilkan pesan asli dari API
      }
      // Check-in tercatat di server (kita tahunya dari "Already checked in")
      // tapi tidak ada check-in aktif -> berarti hari ini sudah check out.
      if (e.message.toLowerCase().contains('no active check-in') &&
          current != null &&
          current.assumedCheckedIn) {
        await _save(
          Attendance(
            idEmployeeAttendance: current.idEmployeeAttendance,
            idEmployee: current.idEmployee,
            idEmployeeSchedule: scheduleId,
            date: _todayStr(),
            checkInAt: current.checkInAt,
            assumedCheckedIn: true,
            assumedCheckedOut: true,
          ),
        );
        rethrow; // tampilkan pesan asli dari API
      }
      rethrow;
    }
  }

  Future<void> clear() async {
    await _storage.delete(key: _key);
    state = const AsyncData(null);
  }
}

final attendanceProvider =
    AsyncNotifierProvider<AttendanceNotifier, Attendance?>(
      AttendanceNotifier.new,
    );
