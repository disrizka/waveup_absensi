import 'dart:async';
import 'dart:convert';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

import '../core/api_exception.dart';
import '../models/attendance.dart';
import '../models/employee_schedule.dart';
import '../repositories/attendance_repository.dart';
import '../services/location_service.dart';
import 'session_provider.dart';

String _todayStr([DateTime? d]) {
  final n = d ?? DateTime.now();
  return '${n.year}-${n.month.toString().padLeft(2, '0')}-${n.day.toString().padLeft(2, '0')}';
}

/// State: null = not checked in today.
class AttendanceNotifier extends AsyncNotifier<Attendance?> {
  final _storage = const FlutterSecureStorage();
  String _uid = '';

  // Stored per user, so another account on the same device never sees it.
  String get _key => 'waveup_attendance_today_$_uid';

  @override
  Future<Attendance?> build() async {
    _uid =
        ref.watch(sessionProvider.select((s) => s.valueOrNull?.user.idUser)) ??
        '';
    if (_uid.isEmpty) return null;
    try {
      final raw = await _storage.read(key: _key);
      if (raw == null) return null;
      final a = Attendance.fromJson(jsonDecode(raw));
      return a.date == _todayStr() ? a : null; // drop data from other days
    } catch (_) {
      return null;
    }
  }

  Future<void> _save(Attendance a) async {
    await _storage.write(key: _key, value: jsonEncode(a.toJson()));
    state = AsyncData(a);
  }

  /// Finds today's schedule id from GET waveup/my-schedule.
  Future<String> _todaysScheduleId(AttendanceRepository repo) async {
    final schedules = await repo.getMySchedules();
    if (schedules.isEmpty) {
      throw ApiException('No work schedule has been assigned to you');
    }
    final today = EmployeeSchedule.forDay(schedules);
    if (today == null) {
      throw ApiException('You have no work schedule today');
    }
    return today.idEmployeeSchedule;
  }

  /// Flow: today's schedule -> location -> POST check-in.
  /// Throws [ApiException] on failure (caught by the UI, message shown as-is).
  Future<Attendance> checkIn() async {
    final repo = ref.read(attendanceRepositoryProvider);
    final current = state.valueOrNull;

    final scheduleId = await _todaysScheduleId(repo);
    final pos = await LocationService.current();

    try {
      final result = await repo.checkIn(
        idEmployeeSchedule: scheduleId,
        latitude: pos.latitude,
        longitude: pos.longitude,
      );
      await _save(result);
      return result;
    } on ApiException catch (e) {
      // Server says it is already checked in (done elsewhere): sync the UI.
      if (e.message.toLowerCase().contains('already checked in')) {
        await _save(
          Attendance(
            idEmployeeAttendance: current?.idEmployeeAttendance ?? '',
            idEmployee: current?.idEmployee ?? '',
            idEmployeeSchedule: scheduleId,
            date: _todayStr(),
            checkInAt: current?.checkInAt,
            assumedCheckedIn: true,
          ),
        );
      }
      rethrow; // show the API message as-is
    }
  }

  /// Flow: location -> (schedule id from check-in) -> POST check-out.
  Future<Attendance> checkOut() async {
    final repo = ref.read(attendanceRepositoryProvider);
    final current = state.valueOrNull;

    final scheduleId =
        (current != null && current.idEmployeeSchedule.isNotEmpty)
        ? current.idEmployeeSchedule
        : await _todaysScheduleId(repo);
    final pos = await LocationService.current();

    try {
      final result = await repo.checkOut(
        idEmployeeSchedule: scheduleId,
        latitude: pos.latitude,
        longitude: pos.longitude,
      );
      await _save(result);
      return result;
    } on ApiException catch (e) {
      final msg = e.message.toLowerCase();
      final alreadyOut = msg.contains('already checked out');
      // Check-in exists on the server (we only know it from "Already checked
      // in") but there is no active one -> today was already checked out.
      final noActive =
          msg.contains('no active check-in') &&
          current != null &&
          current.assumedCheckedIn;
      if (alreadyOut || noActive) {
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
      }
      rethrow; // show the API message as-is
    }
  }

  Future<void> clear() async {
    if (_uid.isNotEmpty) await _storage.delete(key: _key);
    state = const AsyncData(null);
  }
}

final attendanceProvider =
    AsyncNotifierProvider<AttendanceNotifier, Attendance?>(
      AttendanceNotifier.new,
    );
