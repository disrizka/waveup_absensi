import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:waveup_absensi/core/api_exception.dart';
import 'package:waveup_absensi/models/employee_schedule.dart';
import 'package:waveup_absensi/providers/schedule_provider.dart';

class MySchedulePage extends ConsumerWidget {
  const MySchedulePage({super.key});

  static const _teal = Color(0xFF00857F);
  static const _weekdays = ['Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat', 'Sun'];

  Future<void> _refresh(WidgetRef ref) async {
    ref.invalidate(mySchedulesProvider);
    try {
      await ref.read(mySchedulesProvider.future);
    } catch (_) {}
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final schedules = ref.watch(mySchedulesProvider);

    return Scaffold(
      backgroundColor: const Color(0xFFF5F7F8),
      appBar: AppBar(
        backgroundColor: _teal,
        foregroundColor: Colors.white,
        elevation: 0,
        title: const Text(
          'My Schedule',
          style: TextStyle(fontWeight: FontWeight.w700),
        ),
      ),
      body: RefreshIndicator(
        color: _teal,
        onRefresh: () => _refresh(ref),
        child: schedules.when(
          loading: () =>
              const Center(child: CircularProgressIndicator(color: _teal)),
          error: (e, _) => _Message(
            icon: Icons.error_outline,
            title: e is ApiException ? e.message : 'Failed to load schedule',
            action: TextButton.icon(
              onPressed: () => ref.invalidate(mySchedulesProvider),
              icon: const Icon(Icons.refresh, color: _teal),
              label: const Text('Try again', style: TextStyle(color: _teal)),
            ),
          ),
          data: (list) {
            if (list.isEmpty) {
              return const _Message(
                icon: Icons.event_busy_outlined,
                title: 'No schedule assigned',
                subtitle: 'Ask your admin to assign you a work schedule.',
              );
            }
            return ListView.separated(
              physics: const AlwaysScrollableScrollPhysics(),
              padding: const EdgeInsets.all(16),
              itemCount: list.length,
              separatorBuilder: (_, __) => const SizedBox(height: 12),
              itemBuilder: (_, i) => _ScheduleCard(schedule: list[i]),
            );
          },
        ),
      ),
    );
  }
}

class _ScheduleCard extends StatelessWidget {
  const _ScheduleCard({required this.schedule});

  final EmployeeSchedule schedule;

  static const _teal = Color(0xFF00857F);

  @override
  Widget build(BuildContext context) {
    final isToday = schedule.appliesTo(DateTime.now().weekday);

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: isToday ? Border.all(color: _teal, width: 1.5) : null,
        boxShadow: const [
          BoxShadow(
            color: Color(0x0F000000),
            blurRadius: 10,
            offset: Offset(0, 3),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: Text(
                  schedule.title.isEmpty ? 'Work schedule' : schedule.title,
                  style: const TextStyle(
                    fontSize: 17,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
              if (isToday)
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 10,
                    vertical: 4,
                  ),
                  decoration: BoxDecoration(
                    color: _teal,
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: const Text(
                    'Today',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 11,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ),
            ],
          ),
          const SizedBox(height: 12),
          Row(
            children: List.generate(7, (i) {
              final on = schedule.days.contains(i + 1);
              return Expanded(
                child: Container(
                  margin: EdgeInsets.only(right: i == 6 ? 0 : 6),
                  padding: const EdgeInsets.symmetric(vertical: 8),
                  decoration: BoxDecoration(
                    color: on ? _teal : const Color(0xFFF0F2F4),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Text(
                    MySchedulePage._weekdays[i],
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontSize: 11,
                      fontWeight: FontWeight.w600,
                      color: on ? Colors.white : const Color(0xFF9AA1A9),
                    ),
                  ),
                ),
              );
            }),
          ),
          const SizedBox(height: 14),
          _InfoRow(
            icon: Icons.access_time_rounded,
            text: '${schedule.startTime} – ${schedule.endTime}',
          ),
          _InfoRow(
            icon: Icons.location_on_outlined,
            text: schedule.requiredLocation
                ? 'Location required · within ${schedule.radius} m'
                : 'Location not required',
          ),
          _InfoRow(
            icon: Icons.photo_camera_outlined,
            text: schedule.requiredPhoto
                ? 'Photo required'
                : 'Photo not required',
          ),
          if (schedule.note.isNotEmpty)
            _InfoRow(icon: Icons.sticky_note_2_outlined, text: schedule.note),
        ],
      ),
    );
  }
}

class _InfoRow extends StatelessWidget {
  const _InfoRow({required this.icon, required this.text});

  final IconData icon;
  final String text;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(top: 8),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, size: 18, color: const Color(0xFF6B7280)),
          const SizedBox(width: 10),
          Expanded(
            child: Text(
              text,
              style: const TextStyle(fontSize: 13, color: Color(0xFF2B2B2B)),
            ),
          ),
        ],
      ),
    );
  }
}

class _Message extends StatelessWidget {
  const _Message({
    required this.icon,
    required this.title,
    this.subtitle,
    this.action,
  });

  final IconData icon;
  final String title;
  final String? subtitle;
  final Widget? action;

  @override
  Widget build(BuildContext context) {
    // ListView keeps pull-to-refresh working on empty / error states.
    return ListView(
      physics: const AlwaysScrollableScrollPhysics(),
      children: [
        SizedBox(height: MediaQuery.of(context).size.height * 0.25),
        Icon(icon, size: 56, color: const Color(0xFFB4BAC0)),
        const SizedBox(height: 12),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 32),
          child: Text(
            title,
            textAlign: TextAlign.center,
            style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
          ),
        ),
        if (subtitle != null)
          Padding(
            padding: const EdgeInsets.fromLTRB(32, 6, 32, 0),
            child: Text(
              subtitle!,
              textAlign: TextAlign.center,
              style: const TextStyle(fontSize: 13, color: Color(0xFF6B7280)),
            ),
          ),
        if (action != null) Center(child: action!),
      ],
    );
  }
}
