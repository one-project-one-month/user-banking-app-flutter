import 'package:equatable/equatable.dart';
import '../model/face_analysis_response.dart';

abstract class FaceAuthState extends Equatable {
  const FaceAuthState();
  @override
  List<Object?> get props => [];
}

class FaceAuthInitial extends FaceAuthState {}

class FaceAuthLoading extends FaceAuthState {}

class FaceAuthCameraError extends FaceAuthState {
  final String message;
  const FaceAuthCameraError(this.message);
  @override
  List<Object?> get props => [message];
}

class FaceAuthInProgress extends FaceAuthState {
  final String instruction;
  final int currentStep;
  final int totalSteps;

  const FaceAuthInProgress({
    required this.instruction,
    required this.currentStep,
    required this.totalSteps,
  });

  @override
  List<Object?> get props => [instruction, currentStep, totalSteps];
}

class FaceAuthSuccess extends FaceAuthState {}

class FaceAuthFailure extends FaceAuthState {
  final String message;
  const FaceAuthFailure(this.message);
  @override
  List<Object?> get props => [message];
}