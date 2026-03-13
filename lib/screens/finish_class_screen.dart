import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:intl/intl.dart';

import '../models/attendance_record.dart';
import '../models/course_item.dart';
import '../services/attendance_storage_service.dart';
import '../services/location_service.dart';
import 'qr_scanner_screen.dart';

class FinishClassScreen extends StatefulWidget {
  const FinishClassScreen({super.key, this.course});

  final CourseItem? course;

  @override
  State<FinishClassScreen> createState() => _FinishClassScreenState();
}

class _FinishClassScreenState extends State<FinishClassScreen> {
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  final TextEditingController _learnedController = TextEditingController();
  final TextEditingController _feedbackController = TextEditingController();
  final TextEditingController _manualQrController = TextEditingController();

  Position? _position;
  bool _isSaving = false;

  @override
  void dispose() {
    _learnedController.dispose();
    _feedbackController.dispose();
    _manualQrController.dispose();
    super.dispose();
  }

  Future<void> _captureLocation() async {
    try {
      final Position position = await LocationService.getCurrentPosition();
      if (!mounted) {
        return;
      }
      setState(() {
        _position = position;
      });
    } catch (e) {
      if (!mounted) {
        return;
      }
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Location error: $e')),
      );
    }
  }

  Future<void> _scanQr() async {
    final String? value = await Navigator.of(context).push<String>(
      MaterialPageRoute<String>(builder: (_) => const QrScannerScreen()),
    );
    if (!mounted || value == null || value.isEmpty) {
      return;
    }
    _manualQrController.text = value;
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }
    if (_position == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please capture GPS location first.')),
      );
      return;
    }

    final String qrValue = _manualQrController.text.trim();
    if (qrValue.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please scan or enter QR code.')),
      );
      return;
    }

    setState(() {
      _isSaving = true;
    });

    final AttendanceRecord record = AttendanceRecord(
      type: RecordType.finishClass,
      timestamp: DateTime.now(),
      latitude: _position!.latitude,
      longitude: _position!.longitude,
      qrCode: qrValue,
      courseCode: widget.course?.code,
      courseTitle: widget.course?.title,
      learnedToday: _learnedController.text.trim(),
      feedback: _feedbackController.text.trim(),
    );

    await AttendanceStorageService.instance.insertRecord(record);

    if (!mounted) {
      return;
    }
    Navigator.of(context).pop(true);
  }

  @override
  Widget build(BuildContext context) {
    final DateFormat dateFormat = DateFormat('EEEE, MMM d');
    final DateFormat timeFormat = DateFormat('hh:mm a');

    return Scaffold(
      appBar: AppBar(title: const Text('Finish Class')),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: <Widget>[
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(20),
              gradient: const LinearGradient(
                colors: <Color>[Color(0xFF14345A), Color(0xFF22668C)],
              ),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                Text(
                  widget.course != null
                      ? '${widget.course!.code} ${widget.course!.title}'
                      : '1305216 Mobile Application Development',
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 19,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  dateFormat.format(DateTime.now()),
                  style: const TextStyle(color: Colors.white70),
                ),
                Text(
                  timeFormat.format(DateTime.now()),
                  style: const TextStyle(color: Colors.white70),
                ),
              ],
            ),
          ),
          const SizedBox(height: 14),
          _StepContainer(
            title: 'Step 1 (Auto)',
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: <Widget>[
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(14),
                    border: Border.all(color: const Color(0xFFD5DDE8)),
                  ),
                  child: Row(
                    children: <Widget>[
                      const Icon(Icons.location_on_outlined),
                      const SizedBox(width: 6),
                      Expanded(
                        child: Text(
                          _position == null
                              ? 'Location not captured yet'
                              : '${_position!.latitude.toStringAsFixed(5)}, ${_position!.longitude.toStringAsFixed(5)}',
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 10),
                Row(
                  children: <Widget>[
                    Expanded(
                      child: FilledButton.icon(
                        onPressed: _captureLocation,
                        icon: const Icon(Icons.gps_fixed),
                        label: const Text('Capture GPS'),
                      ),
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: FilledButton.tonalIcon(
                        onPressed: _scanQr,
                        icon: const Icon(Icons.qr_code_scanner),
                        label: const Text('Scan QR'),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 10),
                TextFormField(
                  controller: _manualQrController,
                  decoration: const InputDecoration(labelText: 'QR value'),
                ),
              ],
            ),
          ),
          const SizedBox(height: 12),
          Form(
            key: _formKey,
            child: _StepContainer(
              title: 'Step 2 (Reflection)',
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: <Widget>[
                  TextFormField(
                    controller: _learnedController,
                    minLines: 3,
                    maxLines: 5,
                    decoration: const InputDecoration(
                      labelText: 'What did you learn today?',
                    ),
                    validator: (String? value) {
                      if (value == null || value.trim().isEmpty) {
                        return 'Required';
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: 10),
                  TextFormField(
                    controller: _feedbackController,
                    minLines: 3,
                    maxLines: 5,
                    decoration: const InputDecoration(
                      labelText: 'Feedback for class/instructor',
                    ),
                    validator: (String? value) {
                      if (value == null || value.trim().isEmpty) {
                        return 'Required';
                      }
                      return null;
                    },
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 18),
          Container(
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(18),
              gradient: const LinearGradient(
                colors: <Color>[Color(0xFF3DCB7A), Color(0xFF1FA056)],
              ),
            ),
            child: FilledButton(
              style: FilledButton.styleFrom(
                backgroundColor: Colors.transparent,
                shadowColor: Colors.transparent,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(vertical: 16),
              ),
              onPressed: _isSaving ? null : _submit,
              child: Text(_isSaving ? 'Saving...' : 'Submit & Close Class'),
            ),
          ),
        ],
      ),
    );
  }
}

class _StepContainer extends StatelessWidget {
  const _StepContainer({
    required this.title,
    required this.child,
  });

  final String title;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: const Color(0xFFF6F8FC),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: const Color(0xFFDCE3EE)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Text(
            title,
            style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 18),
          ),
          const SizedBox(height: 10),
          child,
        ],
      ),
    );
  }
}
