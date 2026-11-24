class EmployeeSchedule {
  final String idEmployeeSchedule;
  final String title;
  final List<int> days; // 1 = Senin ... 7 = Minggu
  final String startTime;
  final String endTime;
  final bool requiredLocation;
  final bool requiredPhoto;
  final String note;

  const EmployeeSchedule({
    required this.idEmployeeSchedule,
    required this.title,
    required this.days,
    required this.startTime,
    required this.endTime,
    required this.requiredLocation,
    required this.requiredPhoto,
    required this.note,
  });

  bool appliesTo(int weekday) => days.contains(weekday);

  factory EmployeeSchedule.fromJson(Map<String, dynamic> j) => EmployeeSchedule(
    idEmployeeSchedule: (j['idEmployeeSchedule'] ?? '').toString(),
    title: (j['title'] ?? '').toString(),
    days: ((j['days'] ?? []) as List)
        .map((e) => int.tryParse(e.toString()) ?? 0)
        .toList(),
    startTime: (j['startTime'] ?? '').toString(),
    endTime: (j['endTime'] ?? '').toString(),
    requiredLocation: j['requiredLocation'] == true,
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
    'requiredPhoto': requiredPhoto,
    'note': note,
  };
}
