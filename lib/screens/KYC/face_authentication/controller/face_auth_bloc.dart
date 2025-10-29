import 'dart:async';
import 'package:bloc/bloc.dart';
import 'package:camera/camera.dart';
import '../service/face_auth_service.dart';
import '../model/face_analysis_response.dart';
import 'face_auth_event.dart';
import 'face_auth_state.dart';

class FaceAuthBloc extends Bloc<FaceAuthEvent, FaceAuthState> {
  final FaceAuthService _service;
  CameraController? _cameraController;
  Timer? _frameTimer;

  FaceAuthBloc(this._service) : super(FaceAuthInitial()) {
    on<FaceAuthStarted>(_onStarted);
    on<FaceAuthStopped>(_onStopped);
    on<FaceAuthFrameCaptured>(_onFrameCaptured);
    on<FaceAuthRetryCamera>(_onRetryCamera);
  }

  Future<void> _onStarted(FaceAuthStarted event, Emitter<FaceAuthState> emit) async {
    emit(FaceAuthLoading());
    try {
      await _service.reset();
      emit(const FaceAuthInProgress(
        instruction: 'Keep your face centered',
        currentStep: 0,
        totalSteps: 4,
      ));
      _startFrameCapture();
    } catch (e) {
      emit(FaceAuthFailure(e.toString()));
    }
  }

  void _onStopped(FaceAuthStopped event, Emitter<FaceAuthState> emit) {
    _frameTimer?.cancel();
    emit(const FaceAuthInProgress(
      instruction: 'Hold still and look at the camera',
      currentStep: 0,
      totalSteps: 4,
    ));
  }

  Future<void> _onFrameCaptured(
    FaceAuthFrameCaptured event,
    Emitter<FaceAuthState> emit,
  ) async {
    if (state is! FaceAuthInProgress) return;

    try {
      final response = await _service.analyzeFrame(event.image);
      if (response.loginFinished == true) {
        _frameTimer?.cancel();
        emit(FaceAuthSuccess());
      } else {
        emit(FaceAuthInProgress(
          instruction: response.currentPoseRequired ?? 'Keep face centered',
          currentStep: response.currentStep ?? 0,
          totalSteps: response.totalSteps ?? 4,
        ));
      }
    } catch (e) {
      // Don't break flow on single frame error
      print('Frame analysis failed: $e');
    }
  }

  Future<void> _onRetryCamera(FaceAuthRetryCamera event, Emitter<FaceAuthState> emit) async {
    emit(FaceAuthLoading());
    await _initializeCamera();
    if (_cameraController?.value.isInitialized == true) {
      emit(const FaceAuthInProgress(
        instruction: 'Hold still and look at the camera',
        currentStep: 0,
        totalSteps: 4,
      ));
    } else {
      emit(const FaceAuthCameraError('Failed to initialize camera'));
    }
  }

 
  Future<void> _initializeCamera() async {
    try {
      final cameras = await availableCameras();
      if (cameras.isEmpty) throw Exception('No cameras found');

      final front = cameras.firstWhere(
        (c) => c.lensDirection == CameraLensDirection.front,
        orElse: () => cameras.first,
      );

      _cameraController?.dispose();
      _cameraController = CameraController(front, ResolutionPreset.medium, enableAudio: false);
      await _cameraController!.initialize();
    } catch (e) {
      rethrow;
    }
  }

  void _startFrameCapture() {
    _frameTimer?.cancel();
    _frameTimer = Timer.periodic(const Duration(milliseconds: 500), (_) async {
      if (_cameraController == null || !(_cameraController!.value.isInitialized)) return;
      try {
        final img = await _cameraController!.takePicture();
        add(FaceAuthFrameCaptured(img));
      } catch (e) {
        print('Capture failed: $e');
      }
    });
  }

  @override
  Future<void> close() {
    _frameTimer?.cancel();
    _cameraController?.dispose();
    return super.close();
  }

  // Public getter for UI
  CameraController? get cameraController => _cameraController;
}