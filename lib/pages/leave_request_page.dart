import 'package:flutter/material.dart';

import 'leave_detail_page.dart';
import 'request_leave_page.dart';

/// Konten tab Leave Request (tanpa Scaffold, dipakai di dalam HomePage).
class LeaveRequestPage extends StatelessWidget {
  const LeaveRequestPage({super.key, this.onBack});

  /// Dipanggil saat tombol back ditekan (mis. kembali ke tab Home).
  final VoidCallback? onBack;

  static const _teal = Color(0xFF00857F);

  // TODO: ganti dengan data dari API.
  static const _history = <_LeaveHistory>[
    _LeaveHistory('Leave Days - 005', Icons.note_add_outlined),
    _LeaveHistory('Leave Days - 004', Icons.description_outlined),
    _LeaveHistory('Leave Days - 003', Icons.description_outlined),
    _LeaveHistory('Leave Days - 002', Icons.note_add_outlined),
    _LeaveHistory('Leave Days - 001', Icons.note_add_outlined),
  ];

  @override
  Widget build(BuildContext context) {
    return Container(
      color: const Color(0xFFFAFAFA),
      child: SafeArea(
        bottom: false,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(4, 8, 16, 8),
              child: Row(
                children: [
                  IconButton(
                    icon: const Icon(Icons.arrow_back),
                    onPressed: onBack,
                  ),
                  const Text(
                    'Leave Days',
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600),
                  ),
                ],
              ),
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 8, 16, 0),
              child: Row(
                children: const [
                  Expanded(
                    child: _AllowanceCard(
                      days: '5 Days',
                      label: 'Work Leave Allowance',
                    ),
                  ),
                  SizedBox(width: 12),
                  Expanded(
                    child: _AllowanceCard(
                      days: '5 Days',
                      label: 'Used Leave Allowance',
                    ),
                  ),
                ],
              ),
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 20, 16, 16),
              child: SizedBox(
                width: double.infinity,
                height: 44,
                child: OutlinedButton(
                  onPressed: () => Navigator.of(context).push(
                    MaterialPageRoute(builder: (_) => const RequestLeavePage()),
                  ),
                  style: OutlinedButton.styleFrom(
                    foregroundColor: _teal,
                    side: const BorderSide(color: _teal),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(6),
                    ),
                  ),
                  child: const Text(
                    'Request Leave Days',
                    style: TextStyle(fontWeight: FontWeight.w500),
                  ),
                ),
              ),
            ),
            const Divider(height: 1, thickness: 6, color: Color(0xFFF0F0F0)),
            const Padding(
              padding: EdgeInsets.fromLTRB(16, 16, 16, 8),
              child: Text(
                'History',
                style: TextStyle(fontSize: 15, fontWeight: FontWeight.w600),
              ),
            ),
            Expanded(
              child: ListView.separated(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                itemCount: _history.length,
                separatorBuilder: (_, __) => const SizedBox(height: 12),
                itemBuilder: (_, i) => InkWell(
                  onTap: () => Navigator.of(context).push(
                    MaterialPageRoute(
                      builder: (_) => LeaveDetailPage(title: _history[i].title),
                    ),
                  ),
                  child: _HistoryTile(item: _history[i]),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _AllowanceCard extends StatelessWidget {
  const _AllowanceCard({required this.days, required this.label});

  final String days;
  final String label;

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 88,
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: const Color(0xFF00C2C2),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Container(
            width: 24,
            height: 24,
            decoration: const BoxDecoration(
              color: Colors.white,
              shape: BoxShape.circle,
            ),
            child: const Icon(
              Icons.insert_drive_file_outlined,
              size: 14,
              color: Color(0xFF00857F),
            ),
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                days,
                style: const TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w700,
                  color: Color(0xFF0B3B3D),
                ),
              ),
              const SizedBox(height: 2),
              Text(
                label,
                style: const TextStyle(fontSize: 9, color: Color(0xFF0B3B3D)),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _LeaveHistory {
  const _LeaveHistory(this.title, this.icon);
  final String title;
  final IconData icon;
}

class _HistoryTile extends StatelessWidget {
  const _HistoryTile({required this.item});

  final _LeaveHistory item;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Container(
          width: 40,
          height: 40,
          decoration: const BoxDecoration(
            color: Color(0xFF00857F),
            shape: BoxShape.circle,
          ),
          child: Icon(item.icon, size: 20, color: Colors.white),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                item.title,
                style: const TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.w600,
                ),
              ),
              const SizedBox(height: 2),
              const Text(
                'Your request was accepted',
                style: TextStyle(fontSize: 11, color: Color(0xFF9AA0A6)),
              ),
            ],
          ),
        ),
        Column(
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            const Text(
              '19:00 PM',
              style: TextStyle(fontSize: 9, color: Color(0xFF9AA0A6)),
            ),
            const SizedBox(height: 4),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 3),
              decoration: BoxDecoration(
                color: const Color(0xFF22C55E),
                borderRadius: BorderRadius.circular(3),
              ),
              child: const Text(
                'Accepted',
                style: TextStyle(
                  fontSize: 9,
                  fontWeight: FontWeight.w600,
                  color: Colors.white,
                ),
              ),
            ),
          ],
        ),
      ],
    );
  }
}
