abstract class VerificationState {
  final bool isLoading;
  final bool isVerified;
  final String? errorMessage;
  final double progress;

  const VerificationState({
    this.isLoading = false,
    this.isVerified = false,
    this.errorMessage,
    this.progress = 0.0,
  });
}

// Initial state
class VerificationInitial extends VerificationState {
  const VerificationInitial();
}

// Verifying documents
class VerifyingDocuments extends VerificationState {
  const VerifyingDocuments({required double progress})
      : super(isLoading: true, progress: progress);
}

// Verification successful
class VerificationSuccess extends VerificationState {
  const VerificationSuccess() : super(isVerified: true, progress: 1.0);
}

// Verification failed
class VerificationError extends VerificationState {
  const VerificationError({required String error})
      : super(errorMessage: error, progress: 0.0);
}