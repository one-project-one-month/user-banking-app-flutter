import 'package:banking_app/Routes/app_routes.dart';
import 'package:banking_app/screens/KYC/face_authentication/let_start_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import 'controller/face_auth_bloc.dart';
import 'controller/face_auth_event.dart';
import 'controller/face_auth_state.dart';
import 'service/face_auth_service.dart';
import 'widgets/camera_preview_widget.dart';
import 'widgets/instruction_widget.dart';
import 'widgets/face_progress_ring.dart';
import 'widgets/action_buttons_row.dart';

class FaceAuthenticationScreen extends StatelessWidget {
  const FaceAuthenticationScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => FaceAuthBloc(FaceAuthService())..add(FaceAuthRetryCamera()),
      child: const _FaceAuthView(),
    );
  }
}

class _FaceAuthView extends StatelessWidget {
  const _FaceAuthView();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.black),
          onPressed: () => Navigator.pop(context),
        ),
        centerTitle: true,
        title: const Text(
          'Face Authentication',
          style: TextStyle(color: const Color(0xFF0A3D62), fontSize: 18, fontWeight: FontWeight.w600),
        ),
      ),
      body: BlocConsumer<FaceAuthBloc, FaceAuthState>(
        listener: (context, state) {
          if (state is FaceAuthFailure) {
            ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(state.message)));
          }
        },
        builder: (context, state) {
          if (state is FaceAuthCameraError) {
            return _buildError(state.message, context);
          }
          if (state is FaceAuthLoading) {
            return _buildLoading();
          }
          if (state is FaceAuthSuccess) {
            return _buildSuccess(context);
          }
          if (state is FaceAuthInProgress) {
            return _buildCapture(context, state);
          }
          return _buildInitial(context);
        },
      ),
    );
  }

  // ---------- INITIAL ----------
  Widget _buildInitial(BuildContext context) {
    return _buildCapture(
      context,
      const FaceAuthInProgress(instruction: 'Hold still and look at the camera', currentStep: 0, totalSteps: 4),
    );
  }

  Widget _buildError(String message, BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(Icons.error_outline, color: Colors.red, size: 60),
          const SizedBox(height: 20),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 40),
            child: Text(message, style: const TextStyle(fontSize: 16), textAlign: TextAlign.center),
          ),
          const SizedBox(height: 20),
          ElevatedButton(
            onPressed: () => context.read<FaceAuthBloc>().add(FaceAuthRetryCamera()),
            child: const Text('Retry'),
          ),
        ],
      ),
    );
  }

  // ---------- LOADING ----------
  Widget _buildLoading() => const Center(
    child: Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        CircularProgressIndicator(color: Color(0xFF0A3D62)),
        SizedBox(height: 20),
        Text('Initializing camera...', style: TextStyle(fontSize: 16)),
      ],
    ),
  );

  Widget _buildSuccess(BuildContext context) => Center(
    child: Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Container(
          width: 100,
          height: 100,
          decoration: const BoxDecoration(shape: BoxShape.circle, color: Color(0xFF0A3D62)),
          child: const Icon(Icons.check, color: Colors.white, size: 50),
        ),
        const SizedBox(height: 30),
        const Text(
          'Authentication complete!',
          style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600),
          textAlign: TextAlign.center,
        ),
        const SizedBox(height: 100),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 40),
          child: SizedBox(
            width: double.infinity,
            height: 50,
            child: ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF0A3D62),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
              ),
              onPressed: () {
                // Navigate to "Let's Start" screen
                AppRoutes.navigateTo(context, AppRoutes.faceAuthLetStart);
              },
              child: const Text(
                "Completed",
                style: TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.w600),
              ),
            ),
          ),
        ),
      ],
    ),
  );

  Widget _buildCapture(BuildContext context, FaceAuthInProgress state) {
    final bloc = context.read<FaceAuthBloc>();
    final isRunning = state.currentStep > 0;
    //Only show camera when initialized
    final cameraController = bloc.cameraController;
    if (cameraController == null || !cameraController.value.isInitialized) {
      return const Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            CircularProgressIndicator(color: Color(0xFF0A3D62)),
            SizedBox(height: 20),
            Text('Initializing camera...', style: TextStyle(fontSize: 16)),
          ],
        ),
      );
    }
    return Stack(
      children: [
        Container(color: Colors.white),
        Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.start,
            children: [
              const SizedBox(height: 50),
              FaceProgressRing(
                controller: bloc.cameraController!,
                currentStep: state.currentStep,
                totalSteps: state.totalSteps,
                isCompleted: state.currentStep >= state.totalSteps,
              ),
              const SizedBox(height: 50),

              InstructionWidget(text: state.instruction),
            ],
          ),
        ),
        Positioned(
          bottom: 40,
          left: 0,
          right: 0,
          child: ActionButtonsRow(
            isAuthenticating: isRunning,
            onStartStop: () => isRunning ? bloc.add(FaceAuthStopped()) : bloc.add(FaceAuthStarted()),
            onCancel: isRunning ? () => bloc.add(FaceAuthStopped()) : null,
            onInfo: () => _showInfoDialog(context),
          ),
        ),
      ],
    );
  }

  void _showInfoDialog(BuildContext context) {
    showDialog(
      context: context,
      builder:
          (_) => AlertDialog(
            title: const Text('Instructions'),
            content: const Text(
              'Follow the sequence:\n\n'
              '1. Look Left\n'
              '2. Look Right\n'
              '3. Look Up\n'
              '4. Smile\n\n'
              'Hold each pose for 1 second.',
            ),
            actions: [TextButton(onPressed: () => Navigator.pop(context), child: const Text('Got it'))],
          ),
    );
  }
}
