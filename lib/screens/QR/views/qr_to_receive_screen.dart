import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:qr_flutter/qr_flutter.dart';
import '../controllers/qr_bloc.dart';
import '../controllers/qr_event.dart';
import '../controllers/qr_state.dart';

class QRToReceiveScreen extends StatefulWidget {
  const QRToReceiveScreen({Key? key}) : super(key: key);

  @override
  State<QRToReceiveScreen> createState() => _QRToReceiveScreenState();
}

class _QRToReceiveScreenState extends State<QRToReceiveScreen> {
  final TextEditingController _amountController = TextEditingController();
  final TextEditingController _noteController = TextEditingController();
  final _formKey = GlobalKey<FormState>();

  @override
  void dispose() {
    _amountController.dispose();
    _noteController.dispose();
    super.dispose();
  }

  void _generateQR() {
    if (_formKey.currentState!.validate()) {
      final amount = double.tryParse(_amountController.text) ?? 0;

      print('🎯 Generating QR with:');
      print('   Amount: $amount');
      print('   Note: ${_noteController.text.trim()}');

      context.read<QRBloc>().add(QRGenerateToReceive(amount: amount, note: _noteController.text.trim()));
    }
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
          onPressed: () {
            // Clear QR when going back
            context.read<QRBloc>().add(const QRClear());
            Navigator.pop(context);
          },
        ),
      ),
      body: BlocConsumer<QRBloc, QRState>(
        listener: (context, state) {
          if (state.hasError) {
            print('❌ QR Generation Error: ${state.errorMessage}');

            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(state.errorMessage ?? 'Failed to generate QR'),
                backgroundColor: Colors.red,
                duration: const Duration(seconds: 4),
                action: SnackBarAction(label: 'Retry', textColor: Colors.white, onPressed: _generateQR),
              ),
            );
          }

          if (state.isGenerated && state.qrToReceive != null) {
            print('✅ QR Generated successfully!');
            print('   Token: ${state.qrToReceive!.token}');
          }
        },
        builder: (context, state) {
          // Show QR display if generated
          if (state.isGenerated && state.qrToReceive != null) {
            return _buildQRDisplay(state.qrToReceive!.token, state.qrToReceive!.amount, state.qrToReceive!.note);
          }

          // Show form
          return _buildForm(state);
        },
      ),
    );
  }

  Widget _buildForm(QRState state) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(20),
      child: Form(
        key: _formKey,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            const SizedBox(height: 20),

            // Amount field
            TextFormField(
              controller: _amountController,
              keyboardType: TextInputType.number,
              decoration: const InputDecoration(
                labelText: 'Amount',
                border: OutlineInputBorder(),
                prefixText: 'Ks ',
                helperText: 'Enter the amount you want to receive',
              ),
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return 'Please enter an amount';
                }
                final amount = double.tryParse(value);
                if (amount == null || amount <= 0) {
                  return 'Please enter a valid amount';
                }
                return null;
              },
            ),

            const SizedBox(height: 20),

            // Note field
            TextFormField(
              controller: _noteController,
              decoration: InputDecoration(
                labelText: 'Note (Optional)',
                hintText: 'Add a note for this payment',
                helperText: '${30 - _noteController.text.length} characters left',
                border: const OutlineInputBorder(),
              ),
              maxLines: 3,
              maxLength: 30,
              onChanged: (value) => setState(() {}),
            ),

            const SizedBox(height: 30),

            // Generate button
            ElevatedButton(
              onPressed: state.isGenerating ? null : _generateQR,
              style: ElevatedButton.styleFrom(
                padding: const EdgeInsets.symmetric(vertical: 15),
                backgroundColor: Colors.blue,
                disabledBackgroundColor: Colors.blue.shade200,
              ),
              child:
                  state.isGenerating
                      ? const SizedBox(
                        height: 20,
                        width: 20,
                        child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white),
                      )
                      : const Text('Generate QR Code', style: TextStyle(fontSize: 16, color: Colors.white)),
            ),

            const SizedBox(height: 20),

            // Instructions
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.blue[50],
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: Colors.blue.shade200),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Icon(Icons.info_outline, color: Colors.blue[700], size: 20),
                      const SizedBox(width: 8),
                      Text('How it works', style: TextStyle(fontWeight: FontWeight.bold, color: Colors.blue[900])),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Text(
                    '1. Enter the amount you want to receive\n'
                    '2. Add an optional note\n'
                    '3. Generate the QR code\n'
                    '4. Show it to the person who will pay you',
                    style: TextStyle(fontSize: 13, color: Colors.blue[900], height: 1.5),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildQRDisplay(String token, double amount, String note) {
    return Center(
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const SizedBox(height: 20),

            // Success message
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              decoration: BoxDecoration(
                color: Colors.green[100],
                borderRadius: BorderRadius.circular(20),
                border: Border.all(color: Colors.green),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(Icons.check_circle, color: Colors.green[700], size: 20),
                  const SizedBox(width: 8),
                  Text('QR Code Generated', style: TextStyle(color: Colors.green[900], fontWeight: FontWeight.w600)),
                ],
              ),
            ),

            const SizedBox(height: 30),

            const Text('Show this QR code to the payer', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w500)),

            const SizedBox(height: 30),

            // QR Code
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(12),
                boxShadow: [BoxShadow(color: Colors.grey.withOpacity(0.3), spreadRadius: 2, blurRadius: 5)],
              ),
              child: QrImageView(data: token, version: QrVersions.auto, size: 250.0, backgroundColor: Colors.white),
            ),

            const SizedBox(height: 30),

            // Amount display
            Text(
              'Amount: ${amount.toStringAsFixed(0)} Ks',
              style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: Colors.black87),
            ),

            // Note display
            if (note.isNotEmpty) ...[
              const SizedBox(height: 15),
              Container(
                padding: const EdgeInsets.all(12),
                margin: const EdgeInsets.symmetric(horizontal: 40),
                decoration: BoxDecoration(
                  color: Colors.grey[100],
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: Colors.grey[300]!),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Note',
                      style: TextStyle(fontWeight: FontWeight.bold, fontSize: 12, color: Colors.black54),
                    ),
                    const SizedBox(height: 5),
                    Text(note, style: const TextStyle(fontSize: 14)),
                  ],
                ),
              ),
            ],

            const SizedBox(height: 30),

            // Action buttons
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                ElevatedButton.icon(
                  onPressed: () {
                    // TODO: Implement share functionality
                    ScaffoldMessenger.of(
                      context,
                    ).showSnackBar(const SnackBar(content: Text('Share functionality coming soon')));
                  },
                  icon: const Icon(Icons.share),
                  label: const Text('Share'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.blue,
                    padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                  ),
                ),
                ElevatedButton.icon(
                  onPressed: () {
                    // TODO: Implement save functionality
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('QR code saved to gallery'), backgroundColor: Colors.green),
                    );
                  },
                  icon: const Icon(Icons.download),
                  label: const Text('Save'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.blue,
                    padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                  ),
                ),
              ],
            ),

            const SizedBox(height: 20),

            // Generate new QR button
            TextButton.icon(
              onPressed: () {
                context.read<QRBloc>().add(const QRClear());
                _amountController.clear();
                _noteController.clear();
              },
              icon: const Icon(Icons.refresh),
              label: const Text('Generate New QR'),
              style: TextButton.styleFrom(padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12)),
            ),

            const SizedBox(height: 20),
          ],
        ),
      ),
    );
  }
}
