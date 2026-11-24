import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../models/employee_schedule.dart';
import '../repositories/attendance_repository.dart';
import 'session_provider.dart';

/// Schedules assigned to the logged-in user (GET waveup/my-schedule).
/// Re-fetched automatically when the logged-in user changes.
final mySchedulesProvider =
    FutureProvider.autoDispose<List<EmployeeSchedule>>((ref) async {
      ref.watch(sessionProvider.select((s) => s.valueOrNull?.user.idUser));
      return ref.read(attendanceRepositoryProvider).getMySchedules();
    });