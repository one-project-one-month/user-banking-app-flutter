import 'package:banking_app/Routes/app_routes.dart';
import 'package:banking_app/screens/KYC/document/controllers/upload/upload_bloc.dart';
import 'package:banking_app/screens/KYC/document/controllers/upload/upload_event.dart';
import 'package:banking_app/screens/KYC/document/controllers/upload/upload_state.dart';
import 'package:banking_app/screens/KYC/document/utils/scan.dart';
import 'package:banking_app/screens/KYC/document/utils/tips.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:image_picker/image_picker.dart';

class UploadDocumentPp extends StatefulWidget {
  const UploadDocumentPp({super.key});

  @override
  _UploadDocumentPpState createState() => _UploadDocumentPpState();
}

class _UploadDocumentPpState extends State<UploadDocumentPp>
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

  Future<void> _pickImage() async {
    final XFile? image = await _picker.pickImage(source: ImageSource.camera);
    if (image != null) {
      context.read<UploadBloc>().add(PassportImagePicked(image.path));
    }
  }

  void _submitImage() {
    context.read<UploadBloc>().add(PassportImageSubmitted());
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
      body: Stack(
        children: [
          Container(
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
          ),
          SafeArea(
            child: BlocConsumer<UploadBloc, UploadState>(
              listener: (context, state) {
                if (state is PassportUploadSuccessState) {
               
                   AppRoutes.navigateTo(context, AppRoutes.documentVerification);
                } else if (state is PassportUploadErrorState) {
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
                                  svgAssetPath: 'assets/svg/Passport.svg',
                                  text: 'Upload your Passport',
                                  imagePath: state.passportImagePath,
                                  onPickImage: _pickImage,
                                ),
                                const SizedBox(height: 20),
                                Tips(
                                  showNextButton:
                                      state.passportImagePath != null &&
                                      state.passportImagePath!.isNotEmpty,
                                  isLoading: state.isLoading,
                                  onNext: _submitImage,
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
        ],
      ),
    );
  }
}
