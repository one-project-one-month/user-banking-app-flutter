import 'package:flutter/material.dart';

class AdsContainer extends StatelessWidget {
  final String backgroundImage;
  const AdsContainer({super.key, required this.backgroundImage});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 5.0),
      height: MediaQuery.of(context).size.height * 0.14,
      decoration: BoxDecoration(borderRadius: BorderRadius.circular(8)),
      child: Image.asset(backgroundImage, fit: BoxFit.fill),
    );
  }
}
