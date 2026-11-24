import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:waveup_absensi/models/attendance.dart';
import 'package:waveup_absensi/models/business.dart';
import 'package:waveup_absensi/models/employee_schedule.dart';
import 'package:waveup_absensi/models/user_data.dart';
import 'package:waveup_absensi/pages/attedance_history_page.dart';
import 'package:waveup_absensi/pages/my_schedule_page.dart';
import 'package:waveup_absensi/providers/attendance_provider.dart';
import 'package:waveup_absensi/providers/schedule_provider.dart';
import 'package:waveup_absensi/providers/session_provider.dart';

/// Content of the Menu tab (no Scaffold, used inside HomePage).
class MenuPage extends ConsumerWidget {
  const MenuPage({super.key});

  static const _teal = Color(0xFF00857F);
  static const _red = Color(0xFFD9432F);

  Future<void> _confirmLogout(BuildContext context, WidgetRef ref) async {
    final ok = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: const Text('Log out'),
        content: const Text(
          'Are you sure you want to log out of this account?',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(ctx, true),
            child: const Text('Log out', style: TextStyle(color: _red)),
          ),
        ],
      ),
    );
    if (ok == true) {
      await ref.read(sessionProvider.notifier).logout();
    }
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final session = ref.watch(sessionProvider).valueOrNull;
    if (session == null) return const SizedBox.shrink();
    final user = session.user;
    final attendance = ref.watch(attendanceProvider).valueOrNull;
    final schedules = ref.watch(mySchedulesProvider).valueOrNull;
    final today = schedules == null ? null : EmployeeSchedule.forDay(schedules);

    return ListView(
      padding: EdgeInsets.zero,
      children: [
        _ProfileHeader(user: user),
        Transform.translate(
          offset: const Offset(0, -24),
          child: Container(
            width: double.infinity,
            decoration: const BoxDecoration(
              color: Color(0xFFF5F7F8),
              borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
            ),
            padding: const EdgeInsets.fromLTRB(16, 20, 16, 16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _TodayCard(attendance: attendance, schedule: today),
                const SizedBox(height: 20),
                const _SectionTitle('Account'),
                _Card(
                  children: [
                    _InfoTile(
                      icon: Icons.alternate_email,
                      label: 'Username',
                      value: user.username,
                    ),
                    _InfoTile(
                      icon: Icons.mail_outline,
                      label: 'Email',
                      value: user.email,
                    ),
                    if (user.phone.isNotEmpty)
                      _InfoTile(
                        icon: Icons.phone_outlined,
                        label: 'Phone',
                        value: user.phone,
                      ),
                  ],
                ),
                if (session.businesses.isNotEmpty) ...[
                  const SizedBox(height: 20),
                  _SectionTitle(
                    session.businesses.length > 1 ? 'Businesses' : 'Business',
                  ),
                  _Card(
                    children: [
                      for (final b in session.businesses)
                        _BusinessTile(business: b),
                    ],
                  ),
                ],
                const SizedBox(height: 20),
                const _SectionTitle('Attendance'),
                _Card(
                  children: [
                    _NavTile(
                      icon: Icons.calendar_month_outlined,
                      title: 'My Schedule',
                      subtitle: 'Your work days, hours and rules',
                      onTap: () => Navigator.of(context).push(
                        MaterialPageRoute(
                          builder: (_) => const MySchedulePage(),
                        ),
                      ),
                    ),
                    _NavTile(
                      icon: Icons.history_rounded,
                      title: 'Attendance History',
                      subtitle: 'Your check-in and check-out records',
                      onTap: () => Navigator.of(context).push(
                        MaterialPageRoute(
                          builder: (_) => const AttendanceHistoryPage(),
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 20),
                const _SectionTitle('Other'),
                _Card(
                  children: [
                    _NavTile(
                      icon: Icons.info_outline,
                      title: 'About WaveUp',
                      subtitle: 'App information',
                      onTap: () => showAboutDialog(
                        context: context,
                        applicationName: 'WaveUp Attendance',
                        applicationLegalese: '© WaveUp',
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 24),
                SizedBox(
                  width: double.infinity,
                  height: 48,
                  child: OutlinedButton.icon(
                    onPressed: () => _confirmLogout(context, ref),
                    icon: const Icon(Icons.logout, color: _red),
                    label: const Text(
                      'Log out',
                      style: TextStyle(
                        color: _red,
                        fontSize: 16,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    style: OutlinedButton.styleFrom(
                      side: const BorderSide(color: _red),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }
}

class _ProfileHeader extends StatelessWidget {
  const _ProfileHeader({required this.user});

  final UserData user;

  @override
  Widget build(BuildContext context) {
    final initial = user.fullName.isNotEmpty
        ? user.fullName[0].toUpperCase()
        : '?';
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
            const SizedBox(height: 16),
            const Align(
              alignment: Alignment.centerLeft,
              child: Text(
                'Menu',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 20,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ),
            const SizedBox(height: 20),
            CircleAvatar(
              radius: 42,
              backgroundColor: Colors.white,
              child: CircleAvatar(
                radius: 39,
                backgroundColor: const Color(0xFF0B8C87),
                backgroundImage: user.photoPath.isNotEmpty
                    ? NetworkImage(user.photoPath)
                    : null,
                child: user.photoPath.isEmpty
                    ? Text(
                        initial,
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 30,
                          fontWeight: FontWeight.w700,
                        ),
                      )
                    : null,
              ),
            ),
            const SizedBox(height: 12),
            Text(
              user.fullName,
              textAlign: TextAlign.center,
              style: const TextStyle(
                color: Colors.white,
                fontSize: 20,
                fontWeight: FontWeight.w700,
              ),
            ),
            if (user.userRoleName.isNotEmpty) ...[
              const SizedBox(height: 6),
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 12,
                  vertical: 4,
                ),
                decoration: BoxDecoration(
                  color: Colors.white24,
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Text(
                  user.userRoleName,
                  style: const TextStyle(color: Colors.white, fontSize: 12),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}

class _TodayCard extends StatelessWidget {
  const _TodayCard({required this.attendance, required this.schedule});

  final Attendance? attendance;
  final EmployeeSchedule? schedule;

  static const _teal = Color(0xFF00857F);

  String _hhmm(DateTime? d) {
    if (d == null) return '--:--';
    final l = d.toLocal();
    return '${l.hour.toString().padLeft(2, '0')}:${l.minute.toString().padLeft(2, '0')}';
  }

  @override
  Widget build(BuildContext context) {
    final a = attendance;
    final checkedIn = a?.hasCheckedIn ?? false;
    final out = a?.hasCheckedOut ?? false;

    late final String status;
    late final Color color;
    late final IconData icon;
    if (out) {
      status = 'Completed for today';
      color = _teal;
      icon = Icons.check_circle_rounded;
    } else if (checkedIn) {
      status = a?.checkInAt != null
          ? 'Checked in at ${_hhmm(a!.checkInAt)}'
          : 'Checked in';
      color = const Color(0xFF1B8A4B);
      icon = Icons.login_rounded;
    } else {
      status = 'Not checked in yet';
      color = const Color(0xFF6B7280);
      icon = Icons.radio_button_unchecked;
    }

    return _Card(
      children: [
        Padding(
          padding: const EdgeInsets.all(14),
          child: Row(
            children: [
              Container(
                width: 44,
                height: 44,
                decoration: BoxDecoration(
                  color: const Color(0xFFF1FAF9),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(icon, color: color),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      "Today's attendance",
                      style: TextStyle(fontSize: 12, color: Color(0xFF6B7280)),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      status,
                      style: TextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.w700,
                        color: color,
                      ),
                    ),
                    if (schedule != null) ...[
                      const SizedBox(height: 2),
                      Text(
                        '${schedule!.title} · ${schedule!.startTime} – ${schedule!.endTime}',
                        style: const TextStyle(
                          fontSize: 12,
                          color: Color(0xFF6B7280),
                        ),
                      ),
                    ],
                  ],
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

class _SectionTitle extends StatelessWidget {
  const _SectionTitle(this.text);

  final String text;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(left: 4, bottom: 8),
      child: Text(
        text,
        style: const TextStyle(
          fontSize: 13,
          fontWeight: FontWeight.w700,
          color: Color(0xFF6B7280),
        ),
      ),
    );
  }
}

class _Card extends StatelessWidget {
  const _Card({required this.children});

  final List<Widget> children;

  @override
  Widget build(BuildContext context) {
    final items = <Widget>[];
    for (var i = 0; i < children.length; i++) {
      items.add(children[i]);
      if (i != children.length - 1) {
        items.add(const Divider(height: 1, indent: 56));
      }
    }
    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        boxShadow: const [
          BoxShadow(
            color: Color(0x0D000000),
            blurRadius: 8,
            offset: Offset(0, 2),
          ),
        ],
      ),
      clipBehavior: Clip.antiAlias,
      child: Column(children: items),
    );
  }
}

class _InfoTile extends StatelessWidget {
  const _InfoTile({
    required this.icon,
    required this.label,
    required this.value,
  });

  final IconData icon;
  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      child: Row(
        children: [
          Icon(icon, size: 22, color: MenuPage._teal),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label,
                  style: const TextStyle(
                    fontSize: 12,
                    color: Color(0xFF6B7280),
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  value.isEmpty ? '-' : value,
                  style: const TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _BusinessTile extends StatelessWidget {
  const _BusinessTile({required this.business});

  final Business business;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      child: Row(
        children: [
          CircleAvatar(
            radius: 18,
            backgroundColor: const Color(0xFFE6F4F3),
            backgroundImage: business.logoPath.isNotEmpty
                ? NetworkImage(business.logoPath)
                : null,
            child: business.logoPath.isEmpty
                ? const Icon(
                    Icons.storefront_outlined,
                    size: 18,
                    color: MenuPage._teal,
                  )
                : null,
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  business.name,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                if (business.userRoleName.isNotEmpty)
                  Text(
                    business.userRoleName,
                    style: const TextStyle(
                      fontSize: 12,
                      color: Color(0xFF6B7280),
                    ),
                  ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _NavTile extends StatelessWidget {
  const _NavTile({
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.onTap,
  });

  final IconData icon;
  final String title;
  final String subtitle;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        child: Row(
          children: [
            Icon(icon, size: 24, color: MenuPage._teal),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: const TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    subtitle,
                    style: const TextStyle(
                      fontSize: 12,
                      color: Color(0xFF6B7280),
                    ),
                  ),
                ],
              ),
            ),
            const Icon(Icons.chevron_right, color: Color(0xFFB4BAC0)),
          ],
        ),
      ),
    );
  }
}
