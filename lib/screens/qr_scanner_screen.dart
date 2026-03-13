import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:mobile_scanner/mobile_scanner.dart';

class QrScannerScreen extends StatefulWidget {
  const QrScannerScreen({super.key});

  @override
  State<QrScannerScreen> createState() => _QrScannerScreenState();
}

class _QrScannerScreenState extends State<QrScannerScreen> {
  final TextEditingController _manualController = TextEditingController();
  final MobileScannerController _controller = MobileScannerController(
    autoStart: true,
    detectionSpeed: DetectionSpeed.noDuplicates,
    facing: CameraFacing.back,
  );
  bool _sent = false;

  @override
  void dispose() {
    _manualController.dispose();
    _controller.dispose();
    super.dispose();
  }

  void _submitManual() {
    if (_sent) {
      return;
    }
    final String value = _manualController.text.trim();
    if (value.isEmpty) {
      return;
    }
    _sent = true;
    Navigator.of(context).pop(value);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Scan QR Code')),
      body: Column(
        children: <Widget>[
          if (kIsWeb)
            const Padding(
              padding: EdgeInsets.fromLTRB(16, 12, 16, 0),
              child: Text(
                'Allow camera permission to scan. If camera is not available, you can still enter QR manually below.',
                textAlign: TextAlign.center,
                style: TextStyle(color: Colors.black54),
              ),
            ),
          Expanded(
            child: Stack(
              children: <Widget>[
                MobileScanner(
                  controller: _controller,
                  onDetect: (BarcodeCapture capture) {
                    if (_sent || capture.barcodes.isEmpty) {
                      return;
                    }
                    final String? value = capture.barcodes.first.rawValue;
                    if (value == null || value.isEmpty) {
                      return;
                    }
                    _sent = true;
                    Navigator.of(context).pop(value);
                  },
                ),
                Align(
                  alignment: Alignment.bottomCenter,
                  child: Container(
                    color: Colors.black54,
                    padding: const EdgeInsets.all(16),
                    child: Row(
                      children: <Widget>[
                        Expanded(
                          child: TextField(
                            controller: _manualController,
                            style: const TextStyle(color: Colors.white),
                            decoration: const InputDecoration(
                              hintText: 'Manual QR value',
                              hintStyle: TextStyle(color: Colors.white70),
                              filled: true,
                              fillColor: Color(0x22111111),
                            ),
                          ),
                        ),
                        const SizedBox(width: 10),
                        FilledButton(
                          onPressed: _submitManual,
                          child: const Text('Use'),
                        ),
                      ],
                    ),
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
