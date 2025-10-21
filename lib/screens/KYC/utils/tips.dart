import 'package:flutter/material.dart';

class Tips extends StatelessWidget {
  final VoidCallback? onNext;
  final bool showNextButton;
  final bool isLoading;

  const Tips({
    super.key,
    this.onNext,
    this.showNextButton = false,
    this.isLoading = false,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.fromLTRB(8, 0, 0, 0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const SizedBox(height: 20),
          const Text(
            'Tips for a good photo:',
            style: TextStyle(
              color: Colors.white,
              fontSize: 16,
              fontWeight: FontWeight.bold,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 10),
          const Text(
            '- Ensure all corners are visible',
            textAlign: TextAlign.center,
            style: TextStyle(color: Colors.white),
          ),
          const Text(
            '- Avoid glare and shadows',
            textAlign: TextAlign.center,
            style: TextStyle(color: Colors.white),
          ),
          const Text(
            '- Make sure text is readable',
            textAlign: TextAlign.center,
            style: TextStyle(color: Colors.white),
          ),
          const Text(
            '- Photo should be clear and in focus',
            textAlign: TextAlign.center,
            style: TextStyle(color: Colors.white),
          ),
          const SizedBox(height: 20),
          if (showNextButton)
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: isLoading ? null : onNext,
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 15),
                  foregroundColor: const Color(0xFF0A3D62),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
                child: isLoading
                    ? const SizedBox(
                        height: 20,
                        width: 20,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          valueColor:
                              AlwaysStoppedAnimation<Color>(Color(0xFF0A3D62)),
                        ),
                      )
                    : const Text(
                        'Next',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
              ),
            ),
        ],
      ),
    );
  }
}