import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:mobile_scanner/mobile_scanner.dart';
import 'package:permission_handler/permission_handler.dart';
import '../controllers/qr_bloc.dart';
import '../controllers/qr_event.dart';
import '../controllers/qr_state.dart';
import '../../Transfer/views/transfer_confirmation_screen.dart';
import '../../Transfer/controllers/transfer_bloc.dart';
import '../../Transfer/controllers/transfer_event.dart';

class ScanToReceiveScreen extends StatefulWidget {
  const ScanToReceiveScreen({Key? key}) : super(key: key);

  @override
  State<ScanToReceiveScreen> createState() => _ScanToReceiveScreenState();
}

class _ScanToReceiveScreenState extends State<ScanToReceiveScreen> {
  final MobileScannerController cameraController = MobileScannerController();
  bool hasScanned = false;
  bool hasPermission = false;
  bool permissionChecked = false;

  @override
  void initState() {
    super.initState();
    // Check permission after first frame
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _checkCameraPermission();
    });
  }

  Future<void> _checkCameraPermission() async {
    try {
      // Request camera permission
      final status = await Permission.camera.request();
      setState(() {
        hasPermission = status.isGranted;
        permissionChecked = true;
      });
      
      if (hasPermission && mounted) {
        // Wait a bit for the widget to be fully built before starting camera
        await Future.delayed(const Duration(milliseconds: 200));
        if (mounted) {
          // Start camera after permission is granted and widget is ready
          try {
            await cameraController.start();
            print('✅ Camera started successfully');
          } catch (e) {
            print('❌ Error starting camera: $e');
            // Try to restart
            if (mounted) {
              await Future.delayed(const Duration(milliseconds: 300));
              await cameraController.start();
            }
          }
        }
      } else {
        // Show error if permission denied
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Camera permission is required to scan QR codes'),
              backgroundColor: Colors.red,
            ),
          );
        }
      }
    } catch (e) {
      print('❌ Camera permission error: $e');
      setState(() {
        permissionChecked = true;
      });
    }
  }

  @override
  void dispose() {
    cameraController.dispose();
    super.dispose();
  }

  void _handleScannedQR(String qrData) {
    if (hasScanned) return;
    
    setState(() {
      hasScanned = true;
    });

    cameraController.stop();
    
    // Process the scanned token
    context.read<QRBloc>().add(QRScanToReceive(qrData));
  }

  @override
  Widget build(BuildContext context) {
    return BlocListener<QRBloc, QRState>(
      listener: (context, state) {
        if (state.hasError) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(state.errorMessage ?? 'Failed to process QR'),
              backgroundColor: Colors.red,
            ),
          );
          
          // Reset for another scan
          setState(() {
            hasScanned = false;
          });
          if (mounted) {
            cameraController.start();
          }
        }

        if (state.isScanned && state.scannedData != null) {
          final data = state.scannedData!;
          
          // Set the recipient in TransferBloc before navigating
          context.read<TransferBloc>().add(TransferPrepareByAccountNumber(data.toAccountNumber));
          
          // Wait a bit for the recipient to be set, then navigate
          Future.delayed(const Duration(milliseconds: 300), () {
            if (mounted) {
              // Navigate to transfer confirmation with pre-filled data
              Navigator.pushReplacement(
                context,
                MaterialPageRoute(
                  builder: (context) => TransferConfirmationScreen(
                    recipientAccount: data.toAccountNumber,
                    recipientName: data.toName.isNotEmpty ? data.toName : 'Recipient',
                    prefilledAmount: data.amount.toInt(),
                    prefilledNote: data.note,
                    isQRPayment: true, // Flag to disable editing
                  ),
                ),
              );
            }
          });
        }
      },
      child: Scaffold(
        backgroundColor: Colors.black,
        appBar: AppBar(
          backgroundColor: Colors.black,
          title: const Text(
            'Scan QR to Receive',
            style: TextStyle(color: Colors.white),
          ),
          leading: IconButton(
            icon: const Icon(Icons.arrow_back, color: Colors.white),
            onPressed: () {
              context.read<QRBloc>().add(const QRClear());
              Navigator.pop(context);
            },
          ),
        ),
        body: Stack(
          children: [
            // Camera view
            if (permissionChecked && hasPermission)
              MobileScanner(
                controller: cameraController,
                fit: BoxFit.cover,
                onDetect: (capture) {
                  if (!hasScanned) {
                    final List<Barcode> barcodes = capture.barcodes;
                    for (final barcode in barcodes) {
                      if (barcode.rawValue != null) {
                        _handleScannedQR(barcode.rawValue!);
                        break;
                      }
                    }
                  }
                },
              )
            else if (permissionChecked && !hasPermission)
              Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Icon(Icons.camera_alt_outlined, size: 64, color: Colors.white54),
                    const SizedBox(height: 16),
                    const Text(
                      'Camera permission required',
                      style: TextStyle(color: Colors.white, fontSize: 16),
                    ),
                    const SizedBox(height: 8),
                    ElevatedButton(
                      onPressed: _checkCameraPermission,
                      child: const Text('Grant Permission'),
                    ),
                  ],
                ),
              )
            else
              const Center(
                child: CircularProgressIndicator(color: Colors.white),
              ),

            // Scanning frame
            Center(
              child: Container(
                width: 250,
                height: 250,
                decoration: BoxDecoration(
                  border: Border.all(color: Colors.yellow, width: 2),
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
            ),

            // Instructions
            Positioned(
              top: 50,
              left: 0,
              right: 0,
              child: Center(
                child: Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 20,
                    vertical: 10,
                  ),
                  decoration: BoxDecoration(
                    color: Colors.black54,
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: const Text(
                    'Scan the QR code to receive payment',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 14,
                    ),
                  ),
                ),
              ),
            ),

            // Loading indicator when processing
            if (hasScanned)
              Container(
                color: Colors.black54,
                child: const Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      CircularProgressIndicator(color: Colors.white),
                      SizedBox(height: 20),
                      Text(
                        'Processing QR code...',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 16,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }
}