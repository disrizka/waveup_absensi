class ApiConfig {
  static const baseUrl = 'https://wave-api.eon.id/';
  static const loginPath = 'user/login';
  static const refreshPath = 'user/refresh-token';

  // ── Attendance ──────────────────────────────────────────────
  static const checkInPath = 'waveup/employee-attendance/check-in';
  static const checkOutPath = 'waveup/employee-attendance/check-out';

  /// GET — schedules assigned to the logged-in user.
  static const mySchedulePath = 'waveup/my-schedule';

  static const basicAuth =
      'Basic bWFudWFsX2FwcDpkZGY0YjY1OTE2NTc2N2E2Mjc4NGY5NGM0ZWU1NmQwNzVkYjEwYzk0NTBkYTVjZjgxYjZhZjdiOWY1NmYxZWY3';

  static const app = 'WAVEUP';
  static const client = 'app';
}
