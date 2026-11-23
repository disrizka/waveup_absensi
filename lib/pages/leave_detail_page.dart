import 'package:flutter/material.dart';

class LeaveDetailPage extends StatelessWidget {
  const LeaveDetailPage({
    super.key,
    required this.title,
    // TODO: ganti default di bawah dengan data dari API.
    this.submittedAt = '22 January 2023, 19:00 PM',
    this.status = 'Accepted',
    this.startDate = '11 January, 2023',
    this.endDate = '13 January, 2023',
    this.reason = 'Sick leave',
  });

  final String title;
  final String submittedAt;
  final String status;
  final String startDate;
  final String endDate;
  final String reason;

  Color get _statusColor => switch (status) {
    'Accepted' => const Color(0xFF22C55E),
    'Rejected' => const Color(0xFFD9262C),
    _ => const Color(0xFFF59E0B), // Pending
  };

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFFAFAFA),
      appBar: AppBar(
        backgroundColor: const Color(0xFFFAFAFA),
        elevation: 0,
        scrolledUnderElevation: 0,
        titleSpacing: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Color(0xFF1C1C1E)),
          onPressed: () => Navigator.of(context).pop(),
        ),
        title: const Text(
          'Detail Leave Days',
          style: TextStyle(
            color: Color(0xFF1C1C1E),
            fontSize: 18,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 16, 16, 16),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        title,
                        style: const TextStyle(
                          fontSize: 13,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                      const SizedBox(height: 6),
                      Text(
                        submittedAt,
                        style: const TextStyle(
                          fontSize: 11,
                          color: Color(0xFF9AA0A6),
                        ),
                      ),
                    ],
                  ),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 8,
                    vertical: 5,
                  ),
                  decoration: BoxDecoration(
                    color: _statusColor,
                    borderRadius: BorderRadius.circular(3),
                  ),
                  child: Text(
                    status,
                    style: const TextStyle(
                      fontSize: 10,
                      fontWeight: FontWeight.w600,
                      color: Colors.white,
                    ),
                  ),
                ),
              ],
            ),
          ),
          const Divider(height: 1, thickness: 6, color: Color(0xFFF0F0F0)),
          Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _label('Start Leave Days'),
                _readOnlyField(startDate, Icons.calendar_month),
                const SizedBox(height: 16),
                _label('End Leave Days'),
                _readOnlyField(endDate, Icons.calendar_month),
                const SizedBox(height: 16),
                _label('Reason Leave Days'),
                _readOnlyField(reason, Icons.arrow_drop_down),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _label(String text) => Padding(
    padding: const EdgeInsets.only(bottom: 6),
    child: Text(
      text,
      style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w600),
    ),
  );

  Widget _readOnlyField(String text, IconData icon) {
    return Container(
      height: 40,
      padding: const EdgeInsets.symmetric(horizontal: 12),
      decoration: BoxDecoration(
        color: const Color(0xFFDFE2E7),
        borderRadius: BorderRadius.circular(4),
      ),
      child: Row(
        children: [
          Expanded(
            child: Text(
              text,
              style: const TextStyle(fontSize: 13, color: Color(0xFF8A9099)),
            ),
          ),
          Icon(
            icon,
            size: icon == Icons.arrow_drop_down ? 24 : 16,
            color: const Color(0xFF8A9099),
          ),
        ],
      ),
    );
  }
}
