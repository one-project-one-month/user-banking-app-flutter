abstract class UploadEvent {}

// Identity Selection Events
class UploadInitialEvent extends UploadEvent {}

class UploadIdentitySelected extends UploadEvent {
  final String identity;
  UploadIdentitySelected(this.identity);
}

// Driving License Events
class DLFrontImagePicked extends UploadEvent {
  final String imagePath;
  DLFrontImagePicked(this.imagePath);
}

class DLBackImagePicked extends UploadEvent {
  final String imagePath;
  DLBackImagePicked(this.imagePath);
}

class DLImagesSubmitted extends UploadEvent {
  DLImagesSubmitted();
}

class DLImageRemoved extends UploadEvent {
  final bool isFront; // true for front, false for back
  DLImageRemoved(this.isFront);
}

// Passport Events
class PassportImagePicked extends UploadEvent {
  final String imagePath;
  PassportImagePicked(this.imagePath);
}

class PassportImageSubmitted extends UploadEvent {
  PassportImageSubmitted();
}

class PassportImageRemoved extends UploadEvent {
  PassportImageRemoved();
}

// Reset Event
class ResetUploadState extends UploadEvent {}