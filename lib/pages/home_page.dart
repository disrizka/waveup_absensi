import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:waveup_absensi/core/api_exception.dart';
import 'package:waveup_absensi/models/attendance.dart';
import 'package:waveup_absensi/pages/attedance_history_page.dart';
import 'package:waveup_absensi/providers/attendance_provider.dart';
import 'package:waveup_absensi/providers/session_provider.dart';
import 'app_bottom_nav_bar.dart';
import 'leave_request_page.dart';
import 'menu_page.dart';

class HomePage extends ConsumerStatefulWidget {
  const HomePage({super.key});

  @override
  ConsumerState<HomePage> createState() => _HomePageState();
}

class _HomePageState extends ConsumerState<HomePage> {
  static const _teal = Color(0xFF00857F);
  static const _red = Color(0xFFD9432F);

  static const _days = [
    'Senin',
    'Selasa',
    'Rabu',
    'Kamis',
    'Jumat',
    'Sabtu',
    'Minggu',
  ];
  static const _months = [
    'January',
    'February',
    'March',
    'April',
    'May',
    'June',
    'July',
    'August',
    'September',
    'October',
    'November',
    'December',
  ];

  late DateTime _now;
  Timer? _timer;
  int _navIndex = 0;
  bool _checkingIn = false;
  bool _checkingOut = false;

  @override
  void initState() {
    super.initState();
    _now = DateTime.now();
    _timer = Timer.periodic(const Duration(seconds: 1), (_) {
      if (mounted) setState(() => _now = DateTime.now());
    });
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  String get _dateText =>
      '${_days[_now.weekday - 1]}, ${_now.day} ${_months[_now.month - 1]} ${_now.year}';

  String get _timeText {
    final h = _now.hour % 12 == 0 ? 12 : _now.hour % 12;
    final m = _now.minute.toString().padLeft(2, '0');
    final p = _now.hour < 12 ? 'AM' : 'PM';
    return '${h.toString().padLeft(2, '0')}:$m $p';
  }

  String _hhmm(DateTime? d) {
    if (d == null) return '--:--';
    final l = d.toLocal();
    return '${l.hour.toString().padLeft(2, '0')}:${l.minute.toString().padLeft(2, '0')}';
  }

  Future<void> _onCheckIn() async {
    if (_checkingIn) return;
    setState(() => _checkingIn = true);
    final messenger = ScaffoldMessenger.of(context);
    try {
      final a = await ref.read(attendanceProvider.notifier).checkIn();
      final late = a.lateMinutes > 0
          ? ' (terlambat ${a.lateMinutes} menit)'
          : '';
      messenger.showSnackBar(
        SnackBar(
          content: Text('Check-in berhasil pukul ${_hhmm(a.checkInAt)}$late'),
        ),
      );
    } on ApiException catch (e) {
      messenger.showSnackBar(SnackBar(content: Text(e.message)));
    } catch (e, st) {
      debugPrint('CHECK-IN ERROR: $e\n$st');
      messenger.showSnackBar(SnackBar(content: Text('Check-in gagal: $e')));
    } finally {
      if (mounted) setState(() => _checkingIn = false);
    }
  }

  Future<void> _onCheckOut() async {
    if (_checkingOut) return;
    setState(() => _checkingOut = true);
    final messenger = ScaffoldMessenger.of(context);
    try {
      final a = await ref.read(attendanceProvider.notifier).checkOut();
      final early = a.earlyLeaveMinutes > 0
          ? ' (pulang lebih awal ${a.earlyLeaveMinutes} menit)'
          : '';
      messenger.showSnackBar(
        SnackBar(
          content: Text(
            'Check-out berhasil pukul ${_hhmm(a.checkOutAt)}$early',
          ),
        ),
      );
    } on ApiException catch (e) {
      messenger.showSnackBar(SnackBar(content: Text(e.message)));
    } catch (e, st) {
      debugPrint('CHECK-OUT ERROR: $e\n$st');
      messenger.showSnackBar(SnackBar(content: Text('Check-out gagal: $e')));
    } finally {
      if (mounted) setState(() => _checkingOut = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final attendance = ref.watch(attendanceProvider).valueOrNull;
    final session = ref.watch(sessionProvider).valueOrNull;
    if (session == null) return const SizedBox.shrink();
    final user = session.user;

    return Scaffold(
      backgroundColor: Colors.white,
      bottomNavigationBar: AppBottomNavBar(
        currentIndex: _navIndex,
        onTap: (i) => setState(() => _navIndex = i),
      ),
      body: _navIndex == 1
          ? LeaveRequestPage(onBack: () => setState(() => _navIndex = 0))
          : _navIndex == 2
          ? const MenuPage()
          : Column(
              children: [
                _Header(
                  name: user.fullName,
                  role: user.userRoleName,
                  photoPath: user.photoPath,
                  dateText: _dateText,
                  timeText: _timeText,
                ),
                Expanded(
                  child: Transform.translate(
                    offset: const Offset(0, -24),
                    child: Container(
                      width: double.infinity,
                      decoration: const BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.vertical(
                          top: Radius.circular(24),
                        ),
                      ),
                      child: SingleChildScrollView(
                        padding: const EdgeInsets.fromLTRB(16, 24, 16, 16),
                        child: Column(
                          children: [
                            _checkInButton(attendance),
                            const SizedBox(height: 8),
                            _checkOutButton(attendance),
                            const SizedBox(height: 20),
                            _attendanceSummary(attendance),
                            const SizedBox(height: 16),
                            TextButton(
                              onPressed: () => Navigator.of(context).push(
                                MaterialPageRoute(
                                  builder: (_) => const AttendanceHistoryPage(),
                                ),
                              ),
                              child: const Text(
                                'Check history attendance',
                                style: TextStyle(
                                  color: _teal,
                                  fontSize: 16,
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                            ),
                            const Divider(height: 32),
                            const _AnnouncementCard(
                              title: 'Announcement Title',
                              description:
                                  'This is description on the announcement card, '
                                  'and will show when the HR upload by HR App',
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            ),
    );
  }

  Widget _checkInButton(Attendance? a) {
    final done = a?.hasCheckedIn ?? false;
    return SizedBox(
      width: double.infinity,
      height: 48,
      child: ElevatedButton(
        onPressed: (done || _checkingIn) ? null : _onCheckIn,
        style: ElevatedButton.styleFrom(
          backgroundColor: _teal,
          foregroundColor: Colors.white,
          disabledBackgroundColor: done
              ? const Color(0xFF8CCBC8)
              : const Color(0xFFE9ECEF),
          disabledForegroundColor: done
              ? Colors.white
              : const Color(0xFFB4BAC0),
          elevation: 0,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
        ),
        child: _checkingIn
            ? const SizedBox(
                width: 22,
                height: 22,
                child: CircularProgressIndicator(
                  strokeWidth: 2.5,
                  color: Colors.white,
                ),
              )
            : Text(
                done ? 'Sudah Check in' : 'Check in Time',
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w700,
                ),
              ),
      ),
    );
  }

  Widget _checkOutButton(Attendance? a) {
    final checkedIn = a?.hasCheckedIn ?? false;
    final done = a?.hasCheckedOut ?? false;
    final enabled = checkedIn && !done && !_checkingOut;
    return SizedBox(
      width: double.infinity,
      height: 48,
      child: ElevatedButton(
        onPressed: enabled ? _onCheckOut : null,
        style: ElevatedButton.styleFrom(
          backgroundColor: _red,
          foregroundColor: Colors.white,
          disabledBackgroundColor: done
              ? const Color(0xFFE9A89F)
              : const Color(0xFFE9ECEF),
          disabledForegroundColor: done
              ? Colors.white
              : const Color(0xFFB4BAC0),
          elevation: 0,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
        ),
        child: _checkingOut
            ? const SizedBox(
                width: 22,
                height: 22,
                child: CircularProgressIndicator(
                  strokeWidth: 2.5,
                  color: Colors.white,
                ),
              )
            : Text(
                done ? 'Sudah Check out' : 'Check out Time',
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w700,
                ),
              ),
      ),
    );
  }

  Widget _attendanceSummary(Attendance? a) {
    return IntrinsicHeight(
      child: Row(
        children: [
          Expanded(
            child: _timeColumn(
              icon: Icons.history,
              color: const Color(0xFF1B8A4B),
              time: _hhmm(a?.checkInAt),
              label: 'Check in time',
            ),
          ),
          const VerticalDivider(width: 1, thickness: 1),
          Expanded(
            child: _timeColumn(
              icon: Icons.update,
              color: _red,
              time: _hhmm(a?.checkOutAt),
              label: 'Check out time',
            ),
          ),
        ],
      ),
    );
  }

  Widget _timeColumn({
    required IconData icon,
    required Color color,
    required String time,
    required String label,
  }) {
    return Column(
      children: [
        Icon(icon, size: 30, color: color),
        const SizedBox(height: 8),
        Text(
          time,
          style: TextStyle(
            color: color,
            fontSize: 17,
            fontWeight: FontWeight.w700,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          label,
          style: const TextStyle(fontSize: 12, color: Color(0xFF2B2B2B)),
        ),
      ],
    );
  }
}

class _Header extends StatelessWidget {
  const _Header({
    required this.name,
    required this.role,
    required this.photoPath,
    required this.dateText,
    required this.timeText,
  });

  final String name;
  final String role;
  final String photoPath;
  final String dateText;
  final String timeText;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.fromLTRB(16, 0, 16, 48),
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [Color(0xFF0FA9A4), Color(0xFF2CC6BE)],
        ),
      ),
      child: SafeArea(
        bottom: false,
        child: Column(
          children: [
            const SizedBox(height: 12),
            Row(
              children: [
                CircleAvatar(
                  radius: 20,
                  backgroundColor: Colors.white24,
                  backgroundImage: photoPath.isNotEmpty
                      ? NetworkImage(photoPath)
                      : null,
                  child: photoPath.isEmpty
                      ? const Icon(Icons.person, color: Colors.white)
                      : null,
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        name,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 16,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                      Text(
                        role,
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 13,
                        ),
                      ),
                    ],
                  ),
                ),
                Image.asset(
                  'assets/logo/waveup.png',
                  height: 36,
                  fit: BoxFit.contain,
                  errorBuilder: (_, __, ___) => const Icon(
                    Icons.waves_rounded,
                    color: Colors.white,
                    size: 32,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 40),
            Text(
              dateText,
              style: const TextStyle(color: Colors.white, fontSize: 16),
            ),
            const SizedBox(height: 8),
            Text(
              timeText,
              style: const TextStyle(
                color: Colors.white,
                fontSize: 48,
                fontWeight: FontWeight.w700,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _AnnouncementCard extends StatelessWidget {
  const _AnnouncementCard({required this.title, required this.description});

  final String title;
  final String description;

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          width: 48,
          height: 48,
          decoration: BoxDecoration(
            color: const Color(0xFF1ED3D8),
            borderRadius: BorderRadius.circular(12),
          ),
          child: const Icon(Icons.campaign_rounded, color: Color(0xFF0B3B3D)),
        ),
        const SizedBox(width: 16),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                description,
                style: const TextStyle(
                  fontSize: 12,
                  height: 1.5,
                  color: Color(0xFF6B7280),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}
