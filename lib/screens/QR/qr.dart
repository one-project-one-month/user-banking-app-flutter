import 'package:flutter/material.dart';
import 'package:qr_flutter/qr_flutter.dart';
import 'package:mobile_scanner/mobile_scanner.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;

// Main QR Screen with bottom navigation
class QRScreen extends StatefulWidget {
  const QRScreen({Key? key}) : super(key: key);

  @override
  State<QRScreen> createState() => _QRScreenState();
}

class _QRScreenState extends State<QRScreen> {
  int _currentIndex = 0;

  final List<Widget> _screens = [
    const ScanToPayScreen(),
    const QRToPayScreen(),
    const QRToReceiveScreen(),
    const ScanToReceiveScreen(),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: _screens[_currentIndex],
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _currentIndex,
        onTap: (index) {
          setState(() {
            _currentIndex = index;
          });
        },
        type: BottomNavigationBarType.fixed,
        selectedItemColor: Colors.blue,
        unselectedItemColor: Colors.grey,
        items: const [
          BottomNavigationBarItem(icon: Icon(Icons.qr_code_scanner), label: 'Scan to pay'),
          BottomNavigationBarItem(icon: Icon(Icons.qr_code), label: 'QR to Pay'),
          BottomNavigationBarItem(icon: Icon(Icons.qr_code_2), label: 'QR to Receive'),
          BottomNavigationBarItem(icon: Icon(Icons.camera_alt), label: 'Scan to Receive'),
        ],
      ),
    );
  }
}

// API Service
class ApiService {
  static const String baseUrl = 'https://banking-dummy-backend.onrender.com/'; // Replace with your API URL

  static Future<String?> generateQRToPay(int fromAccountId) async {
    try {
      final response = await http.post(
        Uri.parse('$baseUrl/personal-banking/scan/qr-to-pay/generate'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({'fromAccountId': fromAccountId}),
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        return data['data']['token'];
      }
    } catch (e) {
      print('Error generating QR to pay: $e');
    }
    return null;
  }

  static Future<String?> generateQRToReceive(double amount, String note) async {
    try {
      final response = await http.post(
        Uri.parse('$baseUrl/personal-banking/scan/qr-to-receive/generate'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({'amount': amount, 'note': note}),
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        return data['data']['token'];
      }
    } catch (e) {
      print('Error generating QR to receive: $e');
    }
    return null;
  }
}

// 1. Scan to Pay Screen (Customer scans merchant's QR)
class ScanToPayScreen extends StatefulWidget {
  const ScanToPayScreen({Key? key}) : super(key: key);

  @override
  State<ScanToPayScreen> createState() => _ScanToPayScreenState();
}

class _ScanToPayScreenState extends State<ScanToPayScreen> {
  MobileScannerController cameraController = MobileScannerController();
  bool hasScanned = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        backgroundColor: Colors.black,
        title: const Text('Scan to Pay', style: TextStyle(color: Colors.white)),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: Stack(
        children: [
          MobileScanner(
            controller: cameraController,
            onDetect: (capture) {
              if (!hasScanned) {
                final List<Barcode> barcodes = capture.barcodes;
                for (final barcode in barcodes) {
                  if (barcode.rawValue != null) {
                    hasScanned = true;
                    _handleScannedQR(barcode.rawValue!);
                    break;
                  }
                }
              }
            },
          ),
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
          Positioned(
            top: 50,
            left: 0,
            right: 0,
            child: Center(
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                decoration: BoxDecoration(color: Colors.black54, borderRadius: BorderRadius.circular(20)),
                child: const Text(
                  'Place an QR at the center of your camera\nand the QR will be automatically scanned',
                  textAlign: TextAlign.center,
                  style: TextStyle(color: Colors.white, fontSize: 12),
                ),
              ),
            ),
          ),
          Positioned(
            bottom: 40,
            left: 0,
            right: 0,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [_buildBottomButton(Icons.image, 'Gallery'), _buildBottomButton(Icons.flashlight_on, 'Flash')],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildBottomButton(IconData icon, String label) {
    return Column(
      children: [
        CircleAvatar(radius: 30, backgroundColor: Colors.grey[800], child: Icon(icon, color: Colors.white)),
        const SizedBox(height: 5),
        Text(label, style: const TextStyle(color: Colors.white)),
      ],
    );
  }

  void _handleScannedQR(String qrData) {
    cameraController.stop();
    showDialog(
      context: context,
      barrierDismissible: false,
      builder:
          (context) => AlertDialog(
            title: const Text('QR Code Scanned'),
            content: Text('Data: $qrData\n\nProceed with payment?'),
            actions: [
              TextButton(
                onPressed: () {
                  Navigator.pop(context);
                  setState(() => hasScanned = false);
                  cameraController.start();
                },
                child: const Text('Cancel'),
              ),
              TextButton(
                onPressed: () {
                  Navigator.pop(context);
                  // Process payment here
                  ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Payment successful!')));
                  setState(() => hasScanned = false);
                  cameraController.start();
                },
                child: const Text('Pay Now'),
              ),
            ],
          ),
    );
  }

  @override
  void dispose() {
    cameraController.dispose();
    super.dispose();
  }
}

// 2. QR to Pay Screen (Merchant shows QR for customer to scan)
class QRToPayScreen extends StatefulWidget {
  const QRToPayScreen({Key? key}) : super(key: key);

  @override
  State<QRToPayScreen> createState() => _QRToPayScreenState();
}

class _QRToPayScreenState extends State<QRToPayScreen> {
  String? qrToken;
  bool isLoading = false;
  final TextEditingController _noteController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _generateQR();
  }

  Future<void> _generateQR() async {
    setState(() => isLoading = true);
    final token = await ApiService.generateQRToPay(0); // Replace 0 with actual account ID
    setState(() {
      qrToken = token;
      isLoading = false;
    });
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
      body: Center(
        child:
            isLoading
                ? const CircularProgressIndicator()
                : SingleChildScrollView(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const SizedBox(height: 20),
                      // Barcode
                      if (qrToken != null)
                        Container(
                          padding: const EdgeInsets.all(20),
                          child: Image.network(
                            'https://barcode.tec-it.com/barcode.ashx?data=$qrToken&code=Code128',
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
                      if (qrToken != null)
                        Container(
                          padding: const EdgeInsets.all(20),
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(12),
                            boxShadow: [BoxShadow(color: Colors.grey.withOpacity(0.3), spreadRadius: 2, blurRadius: 5)],
                          ),
                          child: QrImageView(data: qrToken!, version: QrVersions.auto, size: 200.0),
                        ),
                      const SizedBox(height: 20),
                      const Text('Update after 54s', style: TextStyle(color: Colors.blue, fontSize: 12)),
                      const SizedBox(height: 10),
                      const Text(
                        'flypay',
                        style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: Colors.blue),
                      ),
                      const SizedBox(height: 30),
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 40),
                        child: TextField(
                          controller: _noteController,
                          decoration: InputDecoration(
                            labelText: 'Note',
                            hintText: '${30 - _noteController.text.length} Characters Left',
                            border: const OutlineInputBorder(),
                          ),
                          maxLines: 3,
                          maxLength: 30,
                          onChanged: (value) => setState(() {}),
                        ),
                      ),
                      const SizedBox(height: 20),
                    ],
                  ),
                ),
      ),
    );
  }

  @override
  void dispose() {
    _noteController.dispose();
    super.dispose();
  }
}

// 3. QR to Receive Screen (Generate QR with amount)
class QRToReceiveScreen extends StatefulWidget {
  const QRToReceiveScreen({Key? key}) : super(key: key);

  @override
  State<QRToReceiveScreen> createState() => _QRToReceiveScreenState();
}

class _QRToReceiveScreenState extends State<QRToReceiveScreen> {
  final TextEditingController _amountController = TextEditingController();
  final TextEditingController _noteController = TextEditingController();
  String? qrToken;
  bool isLoading = false;

  Future<void> _generateQR() async {
    if (_amountController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Please enter an amount')));
      return;
    }

    setState(() => isLoading = true);
    final amount = double.tryParse(_amountController.text) ?? 0;
    final token = await ApiService.generateQRToReceive(amount, _noteController.text);
    setState(() {
      qrToken = token;
      isLoading = false;
    });

    if (token != null) {
      _showQRDialog();
    } else {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Failed to generate QR code')));
    }
  }

  void _showQRDialog() {
    showDialog(
      context: context,
      builder:
          (context) => Dialog(
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
            child: Padding(
              padding: const EdgeInsets.all(20),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Text('QR to Receive', style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
                  const SizedBox(height: 10),
                  const Text('XXX XXX 4643', style: TextStyle(color: Colors.grey)),
                  const SizedBox(height: 10),
                  const Text('Show this QR code to cashier', style: TextStyle(fontSize: 12, color: Colors.grey)),
                  const SizedBox(height: 20),
                  if (qrToken != null) QrImageView(data: qrToken!, version: QrVersions.auto, size: 200.0),
                  const SizedBox(height: 10),
                  const Text('Ko Aung Aung', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                  const SizedBox(height: 5),
                  if (_noteController.text.isNotEmpty)
                    Container(
                      padding: const EdgeInsets.all(10),
                      margin: const EdgeInsets.symmetric(vertical: 10),
                      decoration: BoxDecoration(color: Colors.grey[100], borderRadius: BorderRadius.circular(8)),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text('Note', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 12)),
                          const SizedBox(height: 5),
                          Text(_noteController.text, style: const TextStyle(fontSize: 14)),
                        ],
                      ),
                    ),
                  const SizedBox(height: 20),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: [
                      Column(
                        children: [
                          IconButton(
                            icon: const Icon(Icons.share, size: 30),
                            onPressed: () {
                              // Share functionality
                              ScaffoldMessenger.of(
                                context,
                              ).showSnackBar(const SnackBar(content: Text('Share functionality')));
                            },
                          ),
                          const Text('Share', style: TextStyle(fontSize: 12)),
                        ],
                      ),
                      Column(
                        children: [
                          IconButton(
                            icon: const Icon(Icons.download, size: 30),
                            onPressed: () {
                              // Save functionality
                              ScaffoldMessenger.of(
                                context,
                              ).showSnackBar(const SnackBar(content: Text('QR code saved')));
                            },
                          ),
                          const Text('Save', style: TextStyle(fontSize: 12)),
                        ],
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        title: const Text('QR to Receive', style: TextStyle(color: Colors.black)),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.black),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            const SizedBox(height: 20),
            TextField(
              controller: _amountController,
              keyboardType: TextInputType.number,
              decoration: const InputDecoration(labelText: 'Amount', border: OutlineInputBorder(), prefixText: '\$ '),
            ),
            const SizedBox(height: 20),
            TextField(
              controller: _noteController,
              decoration: InputDecoration(
                labelText: 'Note',
                hintText: '${30 - _noteController.text.length} Characters Left',
                border: const OutlineInputBorder(),
              ),
              maxLines: 3,
              maxLength: 30,
              onChanged: (value) => setState(() {}),
            ),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: isLoading ? null : _generateQR,
              style: ElevatedButton.styleFrom(
                padding: const EdgeInsets.symmetric(vertical: 15),
                backgroundColor: Colors.blue,
              ),
              child:
                  isLoading
                      ? const SizedBox(
                        height: 20,
                        width: 20,
                        child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white),
                      )
                      : const Text('Generate QR Code', style: TextStyle(fontSize: 16, color: Colors.white)),
            ),
          ],
        ),
      ),
    );
  }

  @override
  void dispose() {
    _amountController.dispose();
    _noteController.dispose();
    super.dispose();
  }
}

// 4. Scan to Receive Screen (Cashier scans customer's QR)
class ScanToReceiveScreen extends StatefulWidget {
  const ScanToReceiveScreen({Key? key}) : super(key: key);

  @override
  State<ScanToReceiveScreen> createState() => _ScanToReceiveScreenState();
}

class _ScanToReceiveScreenState extends State<ScanToReceiveScreen> {
  MobileScannerController cameraController = MobileScannerController();
  bool hasScanned = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        backgroundColor: Colors.black,
        title: const Text('Scan to Receive', style: TextStyle(color: Colors.white)),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: Stack(
        children: [
          MobileScanner(
            controller: cameraController,
            onDetect: (capture) {
              if (!hasScanned) {
                final List<Barcode> barcodes = capture.barcodes;
                for (final barcode in barcodes) {
                  if (barcode.rawValue != null) {
                    hasScanned = true;
                    _handleScannedQR(barcode.rawValue!);
                    break;
                  }
                }
              }
            },
          ),
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
          Positioned(
            top: 50,
            left: 0,
            right: 0,
            child: Center(
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                decoration: BoxDecoration(color: Colors.black54, borderRadius: BorderRadius.circular(20)),
                child: const Text(
                  'Scan customer\'s QR code to receive payment',
                  textAlign: TextAlign.center,
                  style: TextStyle(color: Colors.white, fontSize: 14),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  void _handleScannedQR(String qrData) {
    cameraController.stop();
    showDialog(
      context: context,
      barrierDismissible: false,
      builder:
          (context) => AlertDialog(
            title: const Text('Payment Received'),
            content: Text('Token: $qrData\n\nProcess payment?'),
            actions: [
              TextButton(
                onPressed: () {
                  Navigator.pop(context);
                  setState(() => hasScanned = false);
                  cameraController.start();
                },
                child: const Text('Cancel'),
              ),
              TextButton(
                onPressed: () {
                  // Process payment here
                  Navigator.pop(context);
                  ScaffoldMessenger.of(
                    context,
                  ).showSnackBar(const SnackBar(content: Text('Payment processed successfully')));
                  setState(() => hasScanned = false);
                  cameraController.start();
                },
                child: const Text('Confirm'),
              ),
            ],
          ),
    );
  }

  @override
  void dispose() {
    cameraController.dispose();
    super.dispose();
  }
}
