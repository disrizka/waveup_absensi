import 'package:flutter/material.dart';

enum AttendanceStatus { present, late, overtime }

class AttendanceRecord {
  const AttendanceRecord({
    required this.day,
    required this.weekday,
    required this.start,
    required this.end,
    required this.duration,
    required this.status,
  });

  final String day;
  final String weekday;
  final String start;
  final String end;
  final String duration;
  final AttendanceStatus status;
}

class AttendanceHistoryPage extends StatefulWidget {
  const AttendanceHistoryPage({super.key});

  @override
  State<AttendanceHistoryPage> createState() => _AttendanceHistoryPageState();
}

class _AttendanceHistoryPageState extends State<AttendanceHistoryPage> {
  static const _teal = Color(0xFF00857F);
  static const _filters = ['All', 'Weekly', 'Monthly', 'Custom'];

  int _filter = 0;

  // TODO: ganti dengan data dari API.
  static const _records = <AttendanceRecord>[
    AttendanceRecord(
      day: '01',
      weekday: 'Mon',
      start: '09:00',
      end: '18:00',
      duration: '8 hrs',
      status: AttendanceStatus.present,
    ),
    AttendanceRecord(
      day: '02',
      weekday: 'Mon',
      start: '09:00',
      end: '18:00',
      duration: '7 mnt',
      status: AttendanceStatus.late,
    ),
    AttendanceRecord(
      day: '03',
      weekday: 'Mon',
      start: '09:00',
      end: '18:00',
      duration: '8 hrs',
      status: AttendanceStatus.present,
    ),
    AttendanceRecord(
      day: '04',
      weekday: 'Mon',
      start: '09:00',
      end: '18:00',
      duration: '8 hrs',
      status: AttendanceStatus.present,
    ),
    AttendanceRecord(
      day: '08',
      weekday: 'Mon',
      start: '09:00',
      end: '18:00',
      duration: '1 hrs',
      status: AttendanceStatus.overtime,
    ),
    AttendanceRecord(
      day: '09',
      weekday: 'Mon',
      start: '09:00',
      end: '18:00',
      duration: '8 hrs',
      status: AttendanceStatus.present,
    ),
    AttendanceRecord(
      day: '11',
      weekday: 'Mon',
      start: '09:00',
      end: '18:00',
      duration: '7 mnt',
      status: AttendanceStatus.late,
    ),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF3F4F6),
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        scrolledUnderElevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Color(0xFF1C1C1E)),
          onPressed: () => Navigator.of(context).pop(),
        ),
        title: const Text(
          'Attendance History',
          style: TextStyle(
            color: Color(0xFF1C1C1E),
            fontSize: 18,
            fontWeight: FontWeight.w600,
          ),
        ),
        titleSpacing: 0,
      ),
      body: Column(
        children: [
          Container(
            width: double.infinity,
            color: Colors.white,
            padding: const EdgeInsets.fromLTRB(16, 8, 16, 12),
            child: Wrap(
              spacing: 8,
              children: List.generate(_filters.length, (i) {
                final selected = i == _filter;
                return GestureDetector(
                  onTap: () => setState(() => _filter = i),
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 12,
                      vertical: 6,
                    ),
                    decoration: BoxDecoration(
                      color: selected ? _teal : Colors.white,
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(
                        color: selected ? _teal : const Color(0xFFB4BAC0),
                      ),
                    ),
                    child: Text(
                      _filters[i],
                      style: TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                        color: selected
                            ? Colors.white
                            : const Color(0xFF9AA0A6),
                      ),
                    ),
                  ),
                );
              }),
            ),
          ),
          Expanded(
            child: ListView.separated(
              padding: const EdgeInsets.all(16),
              itemCount: _records.length,
              separatorBuilder: (_, __) => const SizedBox(height: 8),
              itemBuilder: (_, i) => _AttendanceTile(record: _records[i]),
            ),
          ),
        ],
      ),
    );
  }
}

class _AttendanceTile extends StatelessWidget {
  const _AttendanceTile({required this.record});

  final AttendanceRecord record;

  Color get _color => switch (record.status) {
    AttendanceStatus.present => const Color(0xFF1B8A4B),
    AttendanceStatus.late => const Color(0xFFD9262C),
    AttendanceStatus.overtime => const Color(0xFFB11DB5),
  };

  String get _label => switch (record.status) {
    AttendanceStatus.present => 'Present',
    AttendanceStatus.late => 'Late',
    AttendanceStatus.overtime => 'Overtime',
  };

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(4),
      ),
      child: Row(
        children: [
          Container(
            width: 44,
            height: 44,
            decoration: BoxDecoration(
              color: const Color(0xFF1ED3D8),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  record.day,
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w700,
                    color: Color(0xFF0B3B3D),
                  ),
                ),
                Text(
                  record.weekday,
                  style: const TextStyle(
                    fontSize: 11,
                    color: Color(0xFF0B3B3D),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    const _Dot(color: Color(0xFF1B8A4B)),
                    const Expanded(child: _DashedLine()),
                    const _Dot(color: Color(0xFFD9262C)),
                  ],
                ),
                const SizedBox(height: 6),
                Text(
                  '${record.start} to ${record.end}',
                  style: const TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w700,
                    color: Color(0xFF2B2B2B),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: 12),
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(
                record.duration,
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w700,
                  color: _color,
                ),
              ),
              Text(_label, style: TextStyle(fontSize: 11, color: _color)),
            ],
          ),
        ],
      ),
    );
  }
}

class _Dot extends StatelessWidget {
  const _Dot({required this.color});
  final Color color;

  @override
  Widget build(BuildContext context) => Container(
    width: 8,
    height: 8,
    decoration: BoxDecoration(color: color, shape: BoxShape.circle),
  );
}

class _DashedLine extends StatelessWidget {
  const _DashedLine();

  @override
  Widget build(BuildContext context) {
    return SizedBox(height: 1, child: CustomPaint(painter: _DashedPainter()));
  }
}

class _DashedPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = const Color(0xFF2B2B2B)
      ..strokeWidth = 1;
    const dash = 3.0;
    const gap = 2.0;
    double x = 0;
    while (x < size.width) {
      canvas.drawLine(Offset(x, 0), Offset(x + dash, 0), paint);
      x += dash + gap;
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
