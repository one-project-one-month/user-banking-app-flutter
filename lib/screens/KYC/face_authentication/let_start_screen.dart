import 'package:banking_app/screens/KYC/face_authentication/widgets/check_circle_success.dart';
import 'package:flutter/material.dart';

class LetsStartScreen extends StatelessWidget {
  const LetsStartScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: const SizedBox(), // hide back button if not needed
        // optional: add a title
        // title: const Text('Welcome', style: TextStyle(color: Colors.black)),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // Inside the Column of LetsStartScreen
            CheckCircleSuccess(),
            const SizedBox(height: 40),

            // -------------------------------------------------
            // 2. Success message
            // -------------------------------------------------
            const Text(
              'Your account is completely set up.',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.w500, color: Colors.black87),
              textAlign: TextAlign.center,
            ),

            const SizedBox(height: 120),

            // -------------------------------------------------
            // 3. Full-width “Lets Start” button
            // -------------------------------------------------
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 40),
              child: SizedBox(
                width: double.infinity,
                height: 56,
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF0A3D62),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                    elevation: 0,
                  ),
                  onPressed: () {
                    // TODO: Navigate to your main app home
                    // Navigator.pushReplacement(context, MaterialPageRoute(builder: (_) => HomeScreen()));
                  },
                  child: const Text(
                    "Lets Start",
                    style: TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.w600),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
