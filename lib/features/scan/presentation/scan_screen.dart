import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:mobile_scanner/mobile_scanner.dart';
import '../data/qr_parser.dart';

class ScanScreen extends StatefulWidget {
  const ScanScreen({super.key});

  @override
  State<ScanScreen> createState() => _ScanScreenState();
}

class _ScanScreenState extends State<ScanScreen> {
  final MobileScannerController _controller = MobileScannerController(
    formats: const [BarcodeFormat.qrCode],
  );
  bool _isProcessing = false;

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _onDetect(BarcodeCapture capture) {
    if (_isProcessing) return;
    
    final List<Barcode> barcodes = capture.barcodes;
    if (barcodes.isEmpty || barcodes.first.rawValue == null) return;
    
    final rawValue = barcodes.first.rawValue!;
    
    setState(() => _isProcessing = true);
    
    final payload = QrParser.parse(rawValue);
    
    if (payload == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('This is not a valid payment QR code.'),
          backgroundColor: Colors.red,
        ),
      );
      // Wait a bit before allowing another scan
      Future.delayed(const Duration(seconds: 2), () {
        if (mounted) setState(() => _isProcessing = false);
      });
      return;
    }
    
    // Valid QR, navigate to pay screen with query params
    final uri = Uri(
      path: '/pay',
      queryParameters: {
        'vpa': payload.vpa,
        if (payload.name != null) 'name': payload.name,
        if (payload.amountPaise != null) 'amount': payload.amountPaise.toString(),
      },
    );
    
    context.pushReplacement(uri.toString());
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Scan & Pay'),
        backgroundColor: Colors.transparent,
      ),
      extendBodyBehindAppBar: true,
      body: Stack(
        children: [
          MobileScanner(
            controller: _controller,
            onDetect: _onDetect,
            errorBuilder: (context, error, child) {
              return Center(
                child: Padding(
                  padding: const EdgeInsets.all(24.0),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Icon(Icons.error_outline, color: Colors.red, size: 64),
                      const SizedBox(height: 16),
                      Text(
                        'Camera is needed to scan payment QR codes',
                        textAlign: TextAlign.center,
                        style: Theme.of(context).textTheme.titleMedium,
                      ),
                      const SizedBox(height: 24),
                      ElevatedButton(
                        onPressed: () {
                          // In a real app we'd openAppSettings() from permission_handler here
                          _controller.start();
                        },
                        child: const Text('Retry / Open Settings'),
                      ),
                    ],
                  ),
                ),
              );
            },
          ),
          
          // Scanner Overlay
          Center(
            child: Container(
              width: 250,
              height: 250,
              decoration: BoxDecoration(
                border: Border.all(color: Colors.white, width: 2),
                borderRadius: BorderRadius.circular(16),
              ),
              child: _isProcessing 
                  ? const Center(child: CircularProgressIndicator(color: Colors.white))
                  : null,
            ),
          ),
          
          Positioned(
            bottom: 48,
            left: 0,
            right: 0,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                IconButton(
                  icon: const Icon(Icons.flash_on, color: Colors.white),
                  iconSize: 32,
                  onPressed: () => _controller.toggleTorch(),
                  tooltip: 'Toggle Torch',
                ),
                const SizedBox(width: 32),
                IconButton(
                  icon: const Icon(Icons.cameraswitch, color: Colors.white),
                  iconSize: 32,
                  onPressed: () => _controller.switchCamera(),
                  tooltip: 'Switch Camera',
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
