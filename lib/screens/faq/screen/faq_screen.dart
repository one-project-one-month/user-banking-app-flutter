import 'package:banking_app/core/AppStyles/app_styles.dart';
import 'dart:math' as math;
import 'package:banking_app/screens/nickname/styles/style.dart';
import 'package:flutter/material.dart';

class FaqScreen extends StatelessWidget {
  FaqScreen({super.key});

  final TextEditingController _faqInputController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          onPressed: () => Navigator.of(context).pop(),
          icon: const Icon(Icons.arrow_back, color: Colors.white),
        ),
        backgroundColor: AppStyles.primary,
        title: Text(
          'FAQs',
          style: titleTextStyle(context: context, color: Colors.white),
        ),
        centerTitle: true,
      ),
      body: Column(
        children: [
          Expanded(child: Container()),
          Divider(),
          SafeArea(
            minimum: EdgeInsets.only(bottom: 10),
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 8.0, vertical: 5),
              child: Row(
                children: [
                  Expanded(
                    child: TextField(
                      controller: _faqInputController,
                      decoration: InputDecoration(
                        border: OutlineInputBorder(borderSide: BorderSide.none),
                        hintText: 'Write a message.....',
                        hintStyle: TextStyle(
                          color: AppStyles.primary,
                          fontSize: 17,
                        ),
                      ),
                    ),
                  ),
                  Center(
                    child: Transform.rotate(
                      angle: 340 * ( math.pi / 180 ),
                      child: IconButton(
                        iconSize: 25,
                        padding: EdgeInsets.all(15),
                        style: ButtonStyle(
                          backgroundColor: WidgetStatePropertyAll(
                            AppStyles.primary,
                          ),
                        ),
                        onPressed: () {},
                        icon: Icon(Icons.send, color: Colors.white,),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
