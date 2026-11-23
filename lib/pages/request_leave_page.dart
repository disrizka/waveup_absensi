import 'package:flutter/material.dart';

class RequestLeavePage extends StatefulWidget {
  const RequestLeavePage({super.key});

  @override
  State<RequestLeavePage> createState() => _RequestLeavePageState();
}

class _RequestLeavePageState extends State<RequestLeavePage> {
  static const _teal = Color(0xFF00857F);
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
  static const _reasons = [
    'Sick leave',
    'Annual leave',
    'Personal leave',
    'Other',
  ];

  DateTime _start = DateTime.now();
  DateTime _end = DateTime.now();
  String _reason = _reasons.first;

  String _fmt(DateTime d) => '${d.day} ${_months[d.month - 1]}, ${d.year}';

  Future<void> _pickDate({required bool isStart}) async {
    final picked = await showDatePicker(
      context: context,
      initialDate: isStart ? _start : _end,
      firstDate: isStart ? DateTime(2020) : _start,
      lastDate: DateTime(2100),
    );
    if (picked == null) return;
    setState(() {
      if (isStart) {
        _start = picked;
        if (_end.isBefore(_start)) _end = _start;
      } else {
        _end = picked;
      }
    });
  }

  void _submit() {
    // TODO: kirim ke API (start, end, reason, attachment).
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(const SnackBar(content: Text('Permintaan cuti dikirim')));
    Navigator.of(context).pop();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        scrolledUnderElevation: 0,
        titleSpacing: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Color(0xFF1C1C1E)),
          onPressed: () => Navigator.of(context).pop(),
        ),
        title: const Text(
          'Request Leave Days',
          style: TextStyle(
            color: Color(0xFF1C1C1E),
            fontSize: 18,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          _label('Start Leave Days'),
          _dateField(_fmt(_start), () => _pickDate(isStart: true)),
          const SizedBox(height: 16),
          _label('End Leave Days'),
          _dateField(_fmt(_end), () => _pickDate(isStart: false)),
          const SizedBox(height: 16),
          _label('Reason Leave Days'),
          _reasonField(),
          const SizedBox(height: 16),
          _uploadBox(),
          const SizedBox(height: 16),
          SizedBox(
            height: 44,
            child: ElevatedButton(
              onPressed: _submit,
              style: ElevatedButton.styleFrom(
                backgroundColor: _teal,
                foregroundColor: Colors.white,
                elevation: 0,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(6),
                ),
              ),
              child: const Text(
                'Request Form',
                style: TextStyle(fontWeight: FontWeight.w600),
              ),
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

  BoxDecoration get _fieldDecoration => BoxDecoration(
    color: const Color(0xFFF7F8F9),
    borderRadius: BorderRadius.circular(4),
    border: Border.all(color: const Color(0xFFD5D9DD)),
  );

  Widget _dateField(String text, VoidCallback onTap) {
    return InkWell(
      onTap: onTap,
      child: Container(
        height: 40,
        padding: const EdgeInsets.symmetric(horizontal: 12),
        decoration: _fieldDecoration,
        child: Row(
          children: [
            Expanded(child: Text(text, style: const TextStyle(fontSize: 13))),
            const Icon(Icons.calendar_month, size: 16, color: _teal),
          ],
        ),
      ),
    );
  }

  Widget _reasonField() {
    return Container(
      height: 40,
      padding: const EdgeInsets.symmetric(horizontal: 12),
      decoration: _fieldDecoration,
      child: DropdownButtonHideUnderline(
        child: DropdownButton<String>(
          value: _reason,
          isExpanded: true,
          icon: const Icon(Icons.keyboard_arrow_down, size: 20),
          style: const TextStyle(fontSize: 13, color: Color(0xFF1C1C1E)),
          items: _reasons
              .map((r) => DropdownMenuItem(value: r, child: Text(r)))
              .toList(),
          onChanged: (v) => setState(() => _reason = v ?? _reason),
        ),
      ),
    );
  }

  Widget _uploadBox() {
    return CustomPaint(
      painter: _DashedRectPainter(),
      child: InkWell(
        onTap: () {
          // TODO: pilih file JPG/PNG (mis. pakai image_picker / file_picker).
        },
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 20),
          child: Row(
            children: [
              Container(
                width: 36,
                height: 40,
                decoration: BoxDecoration(
                  color: const Color(0xFFCDEBEA),
                  borderRadius: BorderRadius.circular(4),
                ),
                child: const Icon(Icons.upload_file, color: _teal, size: 22),
              ),
              const SizedBox(width: 16),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: const [
                  Text(
                    'Upload Attachment',
                    style: TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.w500,
                      color: _teal,
                    ),
                  ),
                  SizedBox(height: 4),
                  Text(
                    'Format JPG, PNG',
                    style: TextStyle(fontSize: 10, color: Color(0xFF9AA0A6)),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _DashedRectPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = const Color(0xFFD5D9DD)
      ..strokeWidth = 1
      ..style = PaintingStyle.stroke;

    final path = Path()
      ..addRRect(
        RRect.fromRectAndRadius(Offset.zero & size, const Radius.circular(6)),
      );

    const dash = 5.0;
    const gap = 4.0;
    for (final metric in path.computeMetrics()) {
      double d = 0;
      while (d < metric.length) {
        canvas.drawPath(metric.extractPath(d, d + dash), paint);
        d += dash + gap;
      }
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
