import 'package:equatable/equatable.dart';
import 'package:camera/camera.dart';

abstract class FaceAuthEvent extends Equatable {
  const FaceAuthEvent();
  @override
  List<Object?> get props => [];
}

class FaceAuthStarted extends FaceAuthEvent {}

class FaceAuthStopped extends FaceAuthEvent {}

class FaceAuthFrameCaptured extends FaceAuthEvent {
  final XFile image;
  const FaceAuthFrameCaptured(this.image);
  @override
  List<Object?> get props => [image];
}

class FaceAuthRetryCamera extends FaceAuthEvent {}