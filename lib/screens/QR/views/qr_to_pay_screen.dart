import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:qr_flutter/qr_flutter.dart';
import '../controllers/qr_bloc.dart';
import '../controllers/qr_event.dart';
import '../controllers/qr_state.dart';

class QRToPayScreen extends StatefulWidget {
  const QRToPayScreen({Key? key}) : super(key: key);

  @override
  State<QRToPayScreen> createState() => _QRToPayScreenState();
}

class _QRToPayScreenState extends State<QRToPayScreen> {
  @override
  void initState() {
    super.initState();
    // Generate QR when screen opens
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<QRBloc>().add(const QRGenerateToPay());
    });
  }

  @override
  void dispose() {
    // Clear QR data when leaving
    context.read<QRBloc>().add(const QRClear());
    super.dispose();
  }

  void _startSubscription(String token) {
    context.read<QRBloc>().add(QRSubscribeToPay(token));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        title: const Text('QR to Pay', style: TextStyle(color: Colors.black)),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.black),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: BlocConsumer<QRBloc, QRState>(
        listener: (context, state) {
          if (state.hasError) {
        //     ScaffoldMessenger.of(context).showSnackBar(
        //       SnackBar(content: Text(state.errorMessage ?? 'An error occurred'), backgroundColor: Colors.red),
        //     );
          }

          // Auto-start subscription when QR is generated
          if (state.isGenerated && state.qrToPay != null && !state.isSubscribed) {
            _startSubscription(state.qrToPay!.token);
          }
        },
        builder: (context, state) {
          if (state.isGenerating) {
            return const Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [CircularProgressIndicator(), SizedBox(height: 20), Text('Generating QR code...')],
              ),
            );
          }

          if (state.isGenerated && state.qrToPay != null) {
            return _buildQRDisplay(state);
          }

          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Text('Failed to generate QR code'),
                const SizedBox(height: 20),
                ElevatedButton(
                  onPressed: () {
                    context.read<QRBloc>().add(const QRGenerateToPay());
                  },
                  child: const Text('Retry'),
                ),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _buildQRDisplay(QRState state) {
    final token = state.qrToPay!.token;

    return Center(
      child: SingleChildScrollView(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const SizedBox(height: 20),

            // Status indicator
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              decoration: BoxDecoration(
                color: state.isListening ? Colors.green[100] : Colors.grey[200],
                borderRadius: BorderRadius.circular(20),
                border: Border.all(color: state.isListening ? Colors.green : Colors.grey),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(
                    state.isListening ? Icons.check_circle : Icons.info_outline,
                    color: state.isListening ? Colors.green : Colors.grey,
                    size: 16,
                  ),
                  const SizedBox(width: 8),
                  Text(
                    state.isListening ? 'Listening for payments...' : 'Connecting...',
                    style: TextStyle(
                      color: state.isListening ? Colors.green[900] : Colors.grey[700],
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 30),

            // Barcode (optional - for backward compatibility)
            Container(
              padding: const EdgeInsets.all(20),
              child: Image.network(
                'https://barcode.tec-it.com/barcode.ashx?data=$token&code=Code128',
                height: 80,
                errorBuilder:
                    (context, error, stackTrace) => Container(
                      height: 80,
                      width: 200,
                      color: Colors.grey[300],
                      child: const Center(child: Text('Barcode')),
                    ),
              ),
            ),

            const SizedBox(height: 20),

            // QR Code
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(12),
                boxShadow: [BoxShadow(color: Colors.grey.withOpacity(0.3), spreadRadius: 2, blurRadius: 5)],
              ),
              child: QrImageView(data: token, version: QrVersions.auto, size: 200.0),
            ),

            const SizedBox(height: 20),

            // App branding
            const Text('flypay', style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: Colors.blue)),

            const SizedBox(height: 10),

            // Instructions
            Container(
              margin: const EdgeInsets.symmetric(horizontal: 40),
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(color: Colors.blue[50], borderRadius: BorderRadius.circular(8)),
              child: const Text(
                'Show this QR code to the cashier to receive payment',
                textAlign: TextAlign.center,
                style: TextStyle(fontSize: 14, color: Colors.black87),
              ),
            ),

            const SizedBox(height: 30),

            // Refresh button
            ElevatedButton.icon(
              onPressed: () {
                context.read<QRBloc>().add(const QRClear());
                context.read<QRBloc>().add(const QRGenerateToPay());
              },
              icon: const Icon(Icons.refresh),
              label: const Text('Generate New QR'),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.blue,
                padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
              ),
            ),

            const SizedBox(height: 20),

            // Note about subscription
            if (state.isListening)
              Text(
                'We will notify you when payment is received',
                style: TextStyle(fontSize: 12, color: Colors.grey[600], fontStyle: FontStyle.italic),
              ),
          ],
        ),
      ),
    );
  }
}
