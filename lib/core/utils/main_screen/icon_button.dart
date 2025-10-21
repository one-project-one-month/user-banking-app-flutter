import 'package:flutter/material.dart';

class MainScreenIcon extends StatelessWidget {
  final IconData icon;
  final VoidCallback onPressed;
  final String title;
  const MainScreenIcon({
    super.key,
    required this.icon,
    required this.onPressed,
    required this.title,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        SizedBox(
          width: MediaQuery.of(context).size.width * 0.17,
          height: MediaQuery.of(context).size.width * 0.15,
          child: IconButton(
            padding: EdgeInsets.zero,
            onPressed: onPressed,
            icon: Icon(
              icon,
              size: MediaQuery.of(context).size.width * 0.08,
              color: Colors.white,
            ),
            style: IconButton.styleFrom(
              backgroundColor: Color(0xff0A3D62),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8),
              ),
            ),
          ),
        ),
        SizedBox(height: 5),
        Text(
          title,
          style: TextStyle(
            fontSize: 12,
            fontWeight: FontWeight.bold,
            color: Color(0xff0A3D62),
          ),
        ),
      ],
    );
  }
}