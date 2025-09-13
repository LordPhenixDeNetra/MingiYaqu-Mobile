import 'package:flutter/material.dart';
import 'package:mobile_scanner/mobile_scanner.dart';
import '../constants/app_colors.dart';
import '../constants/app_styles.dart';

class BarcodeScannerScreen extends StatefulWidget {
  const BarcodeScannerScreen({super.key});

  @override
  State<BarcodeScannerScreen> createState() => _BarcodeScannerScreenState();
}

class _BarcodeScannerScreenState extends State<BarcodeScannerScreen> {
  MobileScannerController cameraController = MobileScannerController();
  bool _isFlashOn = false;
  bool _isFrontCamera = false;
  String? _scannedCode;

  @override
  void dispose() {
    cameraController.dispose();
    super.dispose();
  }

  void _onDetect(BarcodeCapture capture) {
    final List<Barcode> barcodes = capture.barcodes;
    if (barcodes.isNotEmpty && _scannedCode == null) {
      final barcode = barcodes.first;
      if (barcode.rawValue != null) {
        setState(() {
          _scannedCode = barcode.rawValue;
        });
        
        // Vibrer pour indiquer la détection
        _showResultDialog(barcode.rawValue!);
      }
    }
  }

  void _showResultDialog(String code) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        return AlertDialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(AppStyles.radiusL),
          ),
          title: Row(
            children: [
              Icon(
                Icons.qr_code_scanner,
                color: AppColors.primary,
                size: 28,
              ),
              const SizedBox(width: AppStyles.paddingM),
              const Text(
                'Code scanné',
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Code-barres détecté :',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w500,
                ),
              ),
              const SizedBox(height: AppStyles.paddingM),
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(AppStyles.paddingM),
                decoration: BoxDecoration(
                  color: AppColors.surface,
                  borderRadius: BorderRadius.circular(AppStyles.radiusM),
                  border: Border.all(color: AppColors.outline),
                ),
                child: SelectableText(
                  code,
                  style: const TextStyle(
                    fontSize: 16,
                    fontFamily: 'monospace',
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
                _resetScanner();
              },
              child: const Text('Scanner à nouveau'),
            ),
            ElevatedButton(
              onPressed: () {
                Navigator.of(context).pop();
                Navigator.of(context).pop(code);
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primary,
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(AppStyles.radiusM),
                ),
              ),
              child: const Text('Utiliser ce code'),
            ),
          ],
        );
      },
    );
  }

  void _resetScanner() {
    setState(() {
      _scannedCode = null;
    });
  }

  void _toggleFlash() {
    setState(() {
      _isFlashOn = !_isFlashOn;
    });
    cameraController.toggleTorch();
  }

  void _switchCamera() {
    setState(() {
      _isFrontCamera = !_isFrontCamera;
    });
    cameraController.switchCamera();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        backgroundColor: Colors.black,
        foregroundColor: Colors.white,
        title: const Text(
          'Scanner le code-barres',
          style: TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.bold,
          ),
        ),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => Navigator.of(context).pop(),
        ),
        actions: [
          IconButton(
            icon: Icon(
              _isFlashOn ? Icons.flash_on : Icons.flash_off,
              color: _isFlashOn ? Colors.yellow : Colors.white,
            ),
            onPressed: _toggleFlash,
          ),
          IconButton(
            icon: Icon(
              _isFrontCamera ? Icons.camera_front : Icons.camera_rear,
              color: Colors.white,
            ),
            onPressed: _switchCamera,
          ),
        ],
      ),
      body: Stack(
        children: [
          // Scanner Camera
          MobileScanner(
            controller: cameraController,
            onDetect: _onDetect,
          ),
          
          // Overlay avec cadre de scan
          _buildScanOverlay(),
          
          // Instructions en bas
          _buildInstructions(),
        ],
      ),
    );
  }

  Widget _buildScanOverlay() {
    return Container(
      decoration: ShapeDecoration(
        shape: _ScannerOverlayShape(),
      ),
    );
  }

  Widget _buildInstructions() {
    return Positioned(
      bottom: 100,
      left: 0,
      right: 0,
      child: Container(
        margin: const EdgeInsets.symmetric(horizontal: AppStyles.paddingXL),
        padding: const EdgeInsets.all(AppStyles.paddingL),
        decoration: BoxDecoration(
          color: Colors.black.withOpacity(0.7),
          borderRadius: BorderRadius.circular(AppStyles.radiusL),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              Icons.qr_code_scanner,
              color: Colors.white,
              size: 32,
            ),
            const SizedBox(height: AppStyles.paddingM),
            const Text(
              'Placez le code-barres dans le cadre',
              style: TextStyle(
                color: Colors.white,
                fontSize: 16,
                fontWeight: FontWeight.w500,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: AppStyles.paddingS),
            const Text(
              'Le scan se fera automatiquement',
              style: TextStyle(
                color: Colors.white70,
                fontSize: 14,
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }
}

class _ScannerOverlayShape extends ShapeBorder {
  const _ScannerOverlayShape();

  @override
  EdgeInsetsGeometry get dimensions => const EdgeInsets.all(0);

  @override
  Path getInnerPath(Rect rect, {TextDirection? textDirection}) {
    return Path()
      ..fillType = PathFillType.evenOdd
      ..addPath(getOuterPath(rect), Offset.zero);
  }

  @override
  Path getOuterPath(Rect rect, {TextDirection? textDirection}) {
    Path path = Path()..addRect(rect);
    
    // Créer le rectangle de scan au centre
    const double scanAreaWidth = 250.0;
    const double scanAreaHeight = 250.0;
    
    final scanRect = Rect.fromCenter(
      center: rect.center,
      width: scanAreaWidth,
      height: scanAreaHeight,
    );
    
    path.addRRect(RRect.fromRectAndRadius(
      scanRect,
      const Radius.circular(12),
    ));
    
    return path;
  }

  @override
  void paint(Canvas canvas, Rect rect, {TextDirection? textDirection}) {
    const double scanAreaWidth = 250.0;
    const double scanAreaHeight = 250.0;
    
    final scanRect = Rect.fromCenter(
      center: rect.center,
      width: scanAreaWidth,
      height: scanAreaHeight,
    );
    
    // Peindre l'overlay sombre
    final paint = Paint()
      ..color = Colors.black.withOpacity(0.5)
      ..style = PaintingStyle.fill;
    
    Path overlayPath = Path()
      ..addRect(rect)
      ..addRRect(RRect.fromRectAndRadius(
        scanRect,
        const Radius.circular(12),
      ))
      ..fillType = PathFillType.evenOdd;
    
    canvas.drawPath(overlayPath, paint);
    
    // Dessiner le cadre de scan
    final borderPaint = Paint()
      ..color = AppColors.primary
      ..style = PaintingStyle.stroke
      ..strokeWidth = 3.0;
    
    canvas.drawRRect(
      RRect.fromRectAndRadius(
        scanRect,
        const Radius.circular(12),
      ),
      borderPaint,
    );
    
    // Dessiner les coins du cadre
    final cornerPaint = Paint()
      ..color = AppColors.primary
      ..style = PaintingStyle.stroke
      ..strokeWidth = 4.0
      ..strokeCap = StrokeCap.round;
    
    const double cornerLength = 20.0;
    
    // Coin supérieur gauche
    canvas.drawLine(
      Offset(scanRect.left, scanRect.top + cornerLength),
      Offset(scanRect.left, scanRect.top),
      cornerPaint,
    );
    canvas.drawLine(
      Offset(scanRect.left, scanRect.top),
      Offset(scanRect.left + cornerLength, scanRect.top),
      cornerPaint,
    );
    
    // Coin supérieur droit
    canvas.drawLine(
      Offset(scanRect.right - cornerLength, scanRect.top),
      Offset(scanRect.right, scanRect.top),
      cornerPaint,
    );
    canvas.drawLine(
      Offset(scanRect.right, scanRect.top),
      Offset(scanRect.right, scanRect.top + cornerLength),
      cornerPaint,
    );
    
    // Coin inférieur gauche
    canvas.drawLine(
      Offset(scanRect.left, scanRect.bottom - cornerLength),
      Offset(scanRect.left, scanRect.bottom),
      cornerPaint,
    );
    canvas.drawLine(
      Offset(scanRect.left, scanRect.bottom),
      Offset(scanRect.left + cornerLength, scanRect.bottom),
      cornerPaint,
    );
    
    // Coin inférieur droit
    canvas.drawLine(
      Offset(scanRect.right - cornerLength, scanRect.bottom),
      Offset(scanRect.right, scanRect.bottom),
      cornerPaint,
    );
    canvas.drawLine(
      Offset(scanRect.right, scanRect.bottom - cornerLength),
      Offset(scanRect.right, scanRect.bottom),
      cornerPaint,
    );
  }

  @override
  ShapeBorder scale(double t) => _ScannerOverlayShape();
}