import 'dart:io';

import 'package:banking_app/screens/KYC/controllers/upload_bloc.dart';
import 'package:banking_app/screens/KYC/controllers/upload_event.dart';
import 'package:banking_app/screens/KYC/controllers/upload_state.dart';
import 'package:banking_app/screens/KYC/utils/scan.dart';
import 'package:banking_app/screens/KYC/utils/tips.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:image_picker/image_picker.dart';

class UploadDocumentDl extends StatefulWidget {
  const UploadDocumentDl({super.key});

  @override
  _UploadDocumentDlState createState() => _UploadDocumentDlState();
}

class _UploadDocumentDlState extends State<UploadDocumentDl>
    with SingleTickerProviderStateMixin {
  final ImagePicker _picker = ImagePicker();

  late AnimationController _controller;
  late Animation<double> _titleFade;
  late Animation<double> _contentFade;
  late Animation<Offset> _titleSlide;
  late Animation<Offset> _contentSlide;

  @override
  void initState() {
    super.initState();

    _controller = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 2),
    );

    _titleFade = CurvedAnimation(
      parent: _controller,
      curve: const Interval(0.0, 0.4),
    );
    _contentFade = CurvedAnimation(
      parent: _controller,
      curve: const Interval(0.3, 0.7),
    );

    _titleSlide = Tween(begin: const Offset(0, 0.2), end: Offset.zero).animate(
      CurvedAnimation(parent: _controller, curve: const Interval(0.0, 0.4)),
    );
    _contentSlide = Tween(
      begin: const Offset(0, 0.2),
      end: Offset.zero,
    ).animate(
      CurvedAnimation(parent: _controller, curve: const Interval(0.3, 0.7)),
    );

    _controller.forward();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  Future<void> _pickImage(bool isFront) async {
    final XFile? image = await _picker.pickImage(source: ImageSource.camera);
    if (image != null) {
      if (isFront) {
        context.read<UploadBloc>().add(DLFrontImagePicked(image.path));
      } else {
        context.read<UploadBloc>().add(DLBackImagePicked(image.path));
      }
    }
  }

  void _submitImages() {
    context.read<UploadBloc>().add(DLImagesSubmitted());
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        iconTheme: const IconThemeData(color: Colors.white),
      ),
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            colors: [
              Color(0xFF227DBE),
              Color.fromARGB(255, 10, 89, 146),
              Color(0xFF0A3D62),
            ],
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
          ),
        ),
        child: SafeArea(
          child: BlocConsumer<UploadBloc, UploadState>(
            listener: (context, state) {
              if (state is DLUploadSuccessState) {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('Documents uploaded successfully!'),
                    backgroundColor: Colors.green,
                  ),
                );
                // Navigate to next screen or back
                // Navigator.pop(context);
              } else if (state is DLUploadErrorState) {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text(state.errorMessage ?? 'Upload failed'),
                    backgroundColor: Colors.red,
                  ),
                );
              }
            },
            builder: (context, state) {
              return SingleChildScrollView(
                padding: const EdgeInsets.all(16.0),
                child: ConstrainedBox(
                  constraints: const BoxConstraints(maxWidth: 600),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      FadeTransition(
                        opacity: _titleFade,
                        child: SlideTransition(
                          position: _titleSlide,
                          child: const Text(
                            'Upload Document',
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 24,
                              fontWeight: FontWeight.bold,
                            ),
                            textAlign: TextAlign.center,
                          ),
                        ),
                      ),
                      const SizedBox(height: 20),
                      FadeTransition(
                        opacity: _contentFade,
                        child: SlideTransition(
                          position: _contentSlide,
                          child: Column(
                            children: [
                              Scan(
                                svgAssetPath: 'assets/svg/Scan.svg',
                                text: 'Upload your front Driving License',
                                imagePath: state.dlFrontImagePath,
                                onPickImage: () => _pickImage(true),
                              ),
                              const SizedBox(height: 20),
                              Scan(
                                svgAssetPath: 'assets/svg/Scan.svg',
                                text: 'Upload your back Driving License',
                                imagePath: state.dlBackImagePath,
                                onPickImage: () => _pickImage(false),
                              ),
                              const Tips(),
                              const SizedBox(height: 20),
                              if (state.dlFrontImagePath != null &&
                                  state.dlBackImagePath != null)
                                ElevatedButton(
                                  onPressed:
                                      state.isLoading ? null : _submitImages,
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor: Colors.white,
                                    foregroundColor: const Color(0xFF227DBE),
                                    padding: const EdgeInsets.symmetric(
                                      horizontal: 40,
                                      vertical: 15,
                                    ),
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(30),
                                    ),
                                  ),
                                  child:
                                      state.isLoading
                                          ? const SizedBox(
                                            height: 20,
                                            width: 20,
                                            child: CircularProgressIndicator(
                                              strokeWidth: 2,
                                            ),
                                          )
                                          : const Text(
                                            'Submit Documents',
                                            style: TextStyle(
                                              fontSize: 16,
                                              fontWeight: FontWeight.bold,
                                            ),
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
            },
          ),
        ),
      ),
    );
  }
}
