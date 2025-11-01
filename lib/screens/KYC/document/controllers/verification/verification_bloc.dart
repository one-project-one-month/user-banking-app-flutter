import 'package:banking_app/screens/KYC/document/controllers/verification/verification_event.dart';
import 'package:banking_app/screens/KYC/document/controllers/verification/verification_state.dart';
import 'package:bloc/bloc.dart';

class VerificationBloc extends Bloc<VerificationEvent, VerificationState> {
  VerificationBloc() : super(const VerificationInitial()) {
    on<StartDocumentVerification>(_onStartVerification);
    on<VerificationCompleted>(_onVerificationCompleted);
    on<VerificationFailed>(_onVerificationFailed);
    on<RetryVerification>(_onRetryVerification);
  }

  Future<void> _onStartVerification(
    StartDocumentVerification event,
    Emitter<VerificationState> emit,
  ) async {
    try {
      // Emit progress states to show loading animation
      for (double progress = 0.0; progress <= 1.0; progress += 0.1) {
        emit(VerifyingDocuments(progress: progress));
        await Future.delayed(const Duration(milliseconds: 300));
      }

      // TODO: Implement actual document verification API call
      // Example:
      // final result = await verificationService.verifyDocuments();
      // if (result.success) {
      //   add(VerificationCompleted());
      // } else {
      //   add(VerificationFailed(result.error));
      // }

      // Simulate verification completion
      await Future.delayed(const Duration(milliseconds: 500));
      add(VerificationCompleted());
    } catch (e) {
      add(VerificationFailed(e.toString()));
    }
  }

  void _onVerificationCompleted(
    VerificationCompleted event,
    Emitter<VerificationState> emit,
  ) {
    emit(const VerificationSuccess());
  }

  void _onVerificationFailed(
    VerificationFailed event,
    Emitter<VerificationState> emit,
  ) {
    emit(VerificationError(error: event.error));
  }

  void _onRetryVerification(
    RetryVerification event,
    Emitter<VerificationState> emit,
  ) {
    add(StartDocumentVerification());
  }
}