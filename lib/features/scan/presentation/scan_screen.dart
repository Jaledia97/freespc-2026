import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:mobile_scanner/mobile_scanner.dart';
import 'scan_action_dialog.dart';

class ScanScreen extends StatefulWidget {
  const ScanScreen({super.key});

  @override
  State<ScanScreen> createState() => _ScanScreenState();
}

class _ScanScreenState extends State<ScanScreen> {
  final MobileScannerController controller = MobileScannerController(
    detectionSpeed: DetectionSpeed.noDuplicates,
    facing: CameraFacing.front,
    formats: [BarcodeFormat.qrCode],
  );
  bool _isProcessing = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Scan Beacon'),
        actions: [
          IconButton(
            icon: const Icon(Icons.flash_on),
            onPressed: () => controller.toggleTorch(),
          ),
          IconButton(
            icon: const Icon(Icons.cameraswitch),
            onPressed: () => controller.switchCamera(),
          ),
        ],
      ),
      body: MobileScanner(
        controller: controller,
        onDetect: (capture) async {
          if (_isProcessing) return;
          final List<Barcode> barcodes = capture.barcodes;
          
          for (final barcode in barcodes) {
            final String? code = barcode.rawValue;
            if (code != null && code.isNotEmpty) {
              setState(() {
                _isProcessing = true;
              });
              controller.stop(); // Pause camera logic
              
              await showDialog(
                context: context,
                barrierDismissible: false,
                builder: (context) => ScanActionDialog(
                  content: code!, 
                  onResumeCamera: () { },
                ),
              ).then((_) {
                 // Resume when dialog closes
                if (mounted) {
                    setState(() {
                      _isProcessing = false;
                    });
                    controller.start();
                }
              });
              break; // Only process first code
            } else {
               // Invalid/Empty code
               // Feedback provided here if needed, but scanning usually happens fast. 
            }
          }
        },
      ),
    );
  }

  @override
  void dispose() {
    controller.dispose();
    super.dispose();
  }
}
