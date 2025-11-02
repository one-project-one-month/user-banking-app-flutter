class FaceAnalysisResponse {
  final String? detectedPose;
  final int? currentStep;
  final int? totalSteps;
  final String? currentPoseRequired;
  final bool? loginFinished;

  FaceAnalysisResponse({
    this.detectedPose,
    this.currentStep,
    this.totalSteps,
    this.currentPoseRequired,
    this.loginFinished,
  });

  factory FaceAnalysisResponse.fromJson(Map<String, dynamic> json) {
    return FaceAnalysisResponse(
      detectedPose: json['detected_pose'] as String?,
      currentStep: json['current_step'] as int?,
      totalSteps: json['total_steps'] as int?,
      currentPoseRequired: json['current_pose_required'] as String?,
      loginFinished: json['login_finished'] as bool?,
    );
  }
}