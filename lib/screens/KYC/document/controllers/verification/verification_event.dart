abstract class VerificationEvent {}

// Start document verification
class StartDocumentVerification extends VerificationEvent {}

// Verification completed successfully
class VerificationCompleted extends VerificationEvent {}

// Verification failed
class VerificationFailed extends VerificationEvent {
  final String error;
  VerificationFailed(this.error);
}

// Retry verification
class RetryVerification extends VerificationEvent {}

// Navigate to face authentication
class NavigateToFaceAuth extends VerificationEvent {}