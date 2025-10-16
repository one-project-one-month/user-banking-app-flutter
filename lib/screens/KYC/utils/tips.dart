import 'package:flutter/material.dart';

class Tips extends StatelessWidget {
  const Tips({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.fromLTRB(8, 0, 0, 0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(height: 20),
          Text(
            'Tips for a good photo:',
            style: TextStyle(
              color: Colors.white,
              fontSize: 16,
              fontWeight: FontWeight.bold,
            ),
            textAlign: TextAlign.center,
          ),
          SizedBox(height: 10),
          Text(
            '- Ensure all corners are visible',
            textAlign: TextAlign.center,
            style: TextStyle(color: Colors.white),
          ),
          Text(
            '- Avoid glare and shadows',
            textAlign: TextAlign.center,
            style: TextStyle(color: Colors.white),
          ),
          Text(
            '- Make sure text is readable',
            textAlign: TextAlign.center,
            style: TextStyle(color: Colors.white),
          ),
          Text(
            '- Photo should be clear and in focus',
            textAlign: TextAlign.center,
            style: TextStyle(color: Colors.white),
          ),
          SizedBox(height: 20),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: () {},
              child: Text('Next'),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.white,
                padding: EdgeInsets.symmetric(vertical: 15),
                foregroundColor: Color(0xFF0A3D62),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
