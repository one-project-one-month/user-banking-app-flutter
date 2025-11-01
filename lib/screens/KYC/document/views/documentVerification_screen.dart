import 'package:banking_app/Routes/app_routes.dart';
import 'package:banking_app/screens/KYC/document/controllers/verification/verification_state.dart';
import 'package:banking_app/screens/KYC/document/controllers/verification/verification_bloc.dart';
import 'package:banking_app/screens/KYC/document/controllers/verification/verification_event.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class DocumentVerificationScreen extends StatefulWidget {
  const DocumentVerificationScreen({super.key});

  @override
  State<DocumentVerificationScreen> createState() =>
      _DocumentVerificationScreenState();
}

class _DocumentVerificationScreenState
    extends State<DocumentVerificationScreen> {
  @override
  void initState() {
    super.initState();
    // Start verification when screen loads
    Future.delayed(const Duration(milliseconds: 500), () {
      context.read<VerificationBloc>().add(StartDocumentVerification());
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
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
          BlocConsumer<VerificationBloc, VerificationState>(
            listener: (context, state) {
              if (state is VerificationSuccess) {
                // Auto-navigate to face authentication after 1 second
                Future.delayed(const Duration(seconds: 1), () {
                  AppRoutes.navigateAndReplace(
                    context,
                    AppRoutes.faceAuthenticationNotice,
                  );
                });
              }
            },
            builder: (context, state) {
              return SafeArea(
                child: Center(
                  child: Padding(
                    padding: const EdgeInsets.all(24.0),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        // Title text at top
                        const Text(
                          'Verifying photo.....',
                          style: TextStyle(
                            fontSize: 16,
                            color: Colors.white,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                        const SizedBox(height: 60),
                        // Progress indicator - centered
                        Stack(
                          alignment: Alignment.center,
                          children: [
                            SizedBox(
                              width: 200,
                              height: 200,
                              child: CircularProgressIndicator(
                                value: state.progress,
                                strokeWidth: 8,
                                backgroundColor: Colors.white24,
                                valueColor: const AlwaysStoppedAnimation<Color>(
                                  Colors.white,
                                ),
                              ),
                            ),
                            Text(
                              '${(state.progress * 100).toInt()}%',
                              style: const TextStyle(
                                fontSize: 32,
                                fontWeight: FontWeight.w600,
                                color: Colors.white,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 40),
                        // Status text
                        Text(
                          _getStatusText(state),
                          style: const TextStyle(
                            fontSize: 15,
                            color: Colors.white70,
                            fontWeight: FontWeight.w500,
                          ),
                          textAlign: TextAlign.center,
                        ),
                        const SizedBox(height: 60),
                        // Error retry button
                        if (state is VerificationError)
                          SizedBox(
                            width: double.infinity,
                            child: ElevatedButton(
                              onPressed: () {
                                context.read<VerificationBloc>().add(
                                      RetryVerification(),
                                    );
                              },
                              style: ElevatedButton.styleFrom(
                                backgroundColor: Colors.white,
                                padding: const EdgeInsets.symmetric(vertical: 16),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(12),
                                ),
                              ),
                              child: const Text(
                                'Retry Verification',
                                style: TextStyle(
                                  fontSize: 16,
                                  color: Color(0xFF0A3D62),
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ),
                          ),
                      ],
                    ),
                  ),
                ),
              );
            },
          ),
        ],
      ),
    );
  }

  String _getStatusText(VerificationState state) {
    if (state is VerifyingDocuments) {
      return 'Please wait for a moment.';
    } else if (state is VerificationSuccess) {
      return 'Verification successful! Redirecting...';
    } else if (state is VerificationError) {
      return state.errorMessage ?? 'Verification failed. Please try again.';
    }
    return 'Please wait for a moment.';
  }
}