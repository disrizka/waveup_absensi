class EmployeeSchedule {
  final String idEmployeeSchedule;
  final String title;
  final List<int> days; // 1 = Monday ... 7 = Sunday
  final String startTime;
  final String endTime;
  final bool requiredLocation;
  final double? latitude;
  final double? longitude;
  final int radius; // meters
  final bool requiredPhoto;
  final String note;

  const EmployeeSchedule({
    required this.idEmployeeSchedule,
    required this.title,
    required this.days,
    required this.startTime,
    required this.endTime,
    required this.requiredLocation,
    this.latitude,
    this.longitude,
    this.radius = 0,
    required this.requiredPhoto,
    required this.note,
  });

  bool appliesTo(int weekday) => days.contains(weekday);

  /// The schedule that applies on [weekday] (defaults to today), or null.
  static EmployeeSchedule? forDay(
    List<EmployeeSchedule> schedules, [
    int? weekday,
  ]) {
    final day = weekday ?? DateTime.now().weekday;
    for (final s in schedules) {
      if (s.idEmployeeSchedule.isNotEmpty && s.appliesTo(day)) return s;
    }
    return null;
  }

  factory EmployeeSchedule.fromJson(Map<String, dynamic> j) => EmployeeSchedule(
    idEmployeeSchedule: (j['idEmployeeSchedule'] ?? '').toString(),
    title: (j['title'] ?? '').toString(),
    days: ((j['days'] ?? []) as List)
        .map((e) => int.tryParse(e.toString()) ?? 0)
        .toList(),
    startTime: (j['startTime'] ?? '').toString(),
    endTime: (j['endTime'] ?? '').toString(),
    requiredLocation: j['requiredLocation'] == true,
    latitude: (j['latitude'] as num?)?.toDouble(),
    longitude: (j['longitude'] as num?)?.toDouble(),
    radius: (j['radius'] as num?)?.toInt() ?? 0,
    requiredPhoto: j['requiredPhoto'] == true,
    note: (j['note'] ?? '').toString(),
  );

  Map<String, dynamic> toJson() => {
    'idEmployeeSchedule': idEmployeeSchedule,
    'title': title,
    'days': days,
    'startTime': startTime,
    'endTime': endTime,
    'requiredLocation': requiredLocation,
    'latitude': latitude,
    'longitude': longitude,
    'radius': radius,
    'requiredPhoto': requiredPhoto,
    'note': note,
  };
}
