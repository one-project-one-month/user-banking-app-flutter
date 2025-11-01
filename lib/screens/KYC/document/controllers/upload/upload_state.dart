abstract class UploadState {
  final String? selectedIdentity;
  final String? dlFrontImagePath;
  final String? dlBackImagePath;
  final String? passportImagePath;
  final bool isLoading;
  final String? errorMessage;
  final bool isSubmitted;

  const UploadState({
    this.selectedIdentity,
    this.dlFrontImagePath,
    this.dlBackImagePath,
    this.passportImagePath,
    this.isLoading = false,
    this.errorMessage,
    this.isSubmitted = false,
  });
}

// Initial state
class UploadInitial extends UploadState {
  const UploadInitial();
}

// Identity selected state
class IdentitySelectedState extends UploadState {
  const IdentitySelectedState(String selectedIdentity)
      : super(selectedIdentity: selectedIdentity);
}

// Driving License states
class DLImagePickedState extends UploadState {
  const DLImagePickedState({
    required String? frontPath,
    required String? backPath,
  }) : super(
          selectedIdentity: 'driving_license',
          dlFrontImagePath: frontPath,
          dlBackImagePath: backPath,
        );
}

class DLUploadingState extends UploadState {
  const DLUploadingState({
    required String frontPath,
    required String backPath,
  }) : super(
          selectedIdentity: 'driving_license',
          dlFrontImagePath: frontPath,
          dlBackImagePath: backPath,
          isLoading: true,
        );
}

class DLUploadSuccessState extends UploadState {
  const DLUploadSuccessState()
      : super(
          selectedIdentity: 'driving_license',
          isSubmitted: true,
        );
}

class DLUploadErrorState extends UploadState {
  const DLUploadErrorState({
    required String error,
    String? frontPath,
    String? backPath,
  }) : super(
          selectedIdentity: 'driving_license',
          dlFrontImagePath: frontPath,
          dlBackImagePath: backPath,
          errorMessage: error,
        );
}

// Passport states
class PassportImagePickedState extends UploadState {
  const PassportImagePickedState({required String imagePath})
      : super(
          selectedIdentity: 'passport',
          passportImagePath: imagePath,
        );
}

class PassportUploadingState extends UploadState {
  const PassportUploadingState({required String imagePath})
      : super(
          selectedIdentity: 'passport',
          passportImagePath: imagePath,
          isLoading: true,
        );
}

class PassportUploadSuccessState extends UploadState {
  const PassportUploadSuccessState()
      : super(
          selectedIdentity: 'passport',
          isSubmitted: true,
        );
}

class PassportUploadErrorState extends UploadState {
  const PassportUploadErrorState({
    required String error,
    String? imagePath,
  }) : super(
          selectedIdentity: 'passport',
          passportImagePath: imagePath,
          errorMessage: error,
        );
}