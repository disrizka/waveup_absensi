class Attendance {
  final String idEmployeeAttendance;
  final String idEmployee;
  final String idEmployeeSchedule;
  final String date;
  final DateTime? checkInAt;
  final double? checkInLatitude;
  final double? checkInLongitude;
  final double? checkInDistance;
  final int lateMinutes;
  final DateTime? checkOutAt;
  final int earlyLeaveMinutes;

  /// true bila server bilang sudah check in/out tapi data jamnya tidak kita punya
  final bool assumedCheckedIn;
  final bool assumedCheckedOut;

  const Attendance({
    required this.idEmployeeAttendance,
    required this.idEmployee,
    required this.idEmployeeSchedule,
    required this.date,
    this.checkInAt,
    this.checkInLatitude,
    this.checkInLongitude,
    this.checkInDistance,
    this.lateMinutes = 0,
    this.checkOutAt,
    this.earlyLeaveMinutes = 0,
    this.assumedCheckedIn = false,
    this.assumedCheckedOut = false,
  });

  bool get hasCheckedIn => checkInAt != null || assumedCheckedIn;
  bool get hasCheckedOut => checkOutAt != null || assumedCheckedOut;

  static DateTime? _dt(dynamic v) =>
      v is String && v.isNotEmpty ? DateTime.tryParse(v) : null;
  static double? _d(dynamic v) => v is num ? v.toDouble() : null;

  factory Attendance.fromJson(Map<String, dynamic> j) => Attendance(
    idEmployeeAttendance: (j['idEmployeeAttendance'] ?? '').toString(),
    idEmployee: (j['idEmployee'] ?? '').toString(),
    idEmployeeSchedule: (j['idEmployeeSchedule'] ?? '').toString(),
    date: (j['date'] ?? '').toString(),
    checkInAt: _dt(j['checkInAt']),
    checkInLatitude: _d(j['checkInLatitude']),
    checkInLongitude: _d(j['checkInLongitude']),
    checkInDistance: _d(j['checkInDistance']),
    lateMinutes: (j['lateMinutes'] as num?)?.toInt() ?? 0,
    checkOutAt: _dt(j['checkOutAt']),
    earlyLeaveMinutes: (j['earlyLeaveMinutes'] as num?)?.toInt() ?? 0,
    assumedCheckedIn: j['assumedCheckedIn'] == true,
    assumedCheckedOut: j['assumedCheckedOut'] == true,
  );

  Map<String, dynamic> toJson() => {
    'idEmployeeAttendance': idEmployeeAttendance,
    'idEmployee': idEmployee,
    'idEmployeeSchedule': idEmployeeSchedule,
    'date': date,
    'checkInAt': checkInAt?.toIso8601String(),
    'checkInLatitude': checkInLatitude,
    'checkInLongitude': checkInLongitude,
    'checkInDistance': checkInDistance,
    'lateMinutes': lateMinutes,
    'checkOutAt': checkOutAt?.toIso8601String(),
    'earlyLeaveMinutes': earlyLeaveMinutes,
    'assumedCheckedIn': assumedCheckedIn,
    'assumedCheckedOut': assumedCheckedOut,
  };
}
