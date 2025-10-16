import 'package:banking_app/screens/KYC/controllers/upload_event.dart';
import 'package:banking_app/screens/KYC/controllers/upload_state.dart';
import 'package:bloc/bloc.dart';

class UploadBloc extends Bloc<UploadEvent, UploadState> {
  UploadBloc() : super(const UploadInitial()) {
    //Identity selection
    on<UploadInitialEvent>(_onInitial);
    on<UploadIdentitySelected>(_onIdentitySelected);

    // Driving License events
    on<DLFrontImagePicked>(_onDLFrontImagePicked);
    on<DLBackImagePicked>(_onDLBackImagePicked);
    on<DLImagesSubmitted>(_onDLImagesSubmitted);
    on<DLImageRemoved>(_onDLImageRemoved);

    // Passport events
    on<PassportImagePicked>(_onPassportImagePicked);
    on<PassportImageSubmitted>(_onPassportImageSubmitted);
    on<PassportImageRemoved>(_onPassportImageRemoved);

    // Reset
    on<ResetUploadState>(_onReset);
  }

  // Identity selection handlers
  void _onInitial(UploadInitialEvent event, Emitter<UploadState> emit) {
    emit(const UploadInitial());
  }

  void _onIdentitySelected(
    UploadIdentitySelected event,
    Emitter<UploadState> emit,
  ) {
    emit(IdentitySelectedState(event.identity));
  }

  // Driving License handlers
  void _onDLFrontImagePicked(
    DLFrontImagePicked event,
    Emitter<UploadState> emit,
  ) {
    emit(
      DLImagePickedState(
        frontPath: event.imagePath,
        backPath: state.dlBackImagePath,
      ),
    );
  }

  void _onDLBackImagePicked(
    DLBackImagePicked event,
    Emitter<UploadState> emit,
  ) {
    emit(
      DLImagePickedState(
        frontPath: state.dlFrontImagePath,
        backPath: event.imagePath,
      ),
    );
  }

  Future<void> _onDLImagesSubmitted(
    DLImagesSubmitted event,
    Emitter<UploadState> emit,
  ) async {
    if (state.dlFrontImagePath == null || state.dlBackImagePath == null) {
      emit(
        DLUploadErrorState(
          error: 'Please upload both front and back images',
          frontPath: state.dlFrontImagePath,
          backPath: state.dlBackImagePath,
        ),
      );
      return;
    }

    emit(
      DLUploadingState(
        frontPath: state.dlFrontImagePath!,
        backPath: state.dlBackImagePath!,
      ),
    );

    try {
      // TODO: Implement your upload logic here
      // Example:
      // await yourUploadService.uploadDrivingLicense(
      //   frontPath: state.dlFrontImagePath!,
      //   backPath: state.dlBackImagePath!,
      // );

      // Simulate network delay for demonstration
      await Future.delayed(const Duration(seconds: 2));

      emit(const DLUploadSuccessState());
    } catch (e) {
      emit(
        DLUploadErrorState(
          error: e.toString(),
          frontPath: state.dlFrontImagePath,
          backPath: state.dlBackImagePath,
        ),
      );
    }
  }

  void _onDLImageRemoved(DLImageRemoved event, Emitter<UploadState> emit) {
    emit(
      DLImagePickedState(
        frontPath: event.isFront ? null : state.dlFrontImagePath,
        backPath: event.isFront ? state.dlBackImagePath : null,
      ),
    );
  }

  // Passport handlers
  void _onPassportImagePicked(
    PassportImagePicked event,
    Emitter<UploadState> emit,
  ) {
    emit(PassportImagePickedState(imagePath: event.imagePath));
  }

  Future<void> _onPassportImageSubmitted(
    PassportImageSubmitted event,
    Emitter<UploadState> emit,
  ) async {
    if (state.passportImagePath == null || state.passportImagePath!.isEmpty) {
      emit(
        const PassportUploadErrorState(
          error: 'Please upload passport image',
          imagePath: null,
        ),
      );
      return;
    }

    emit(PassportUploadingState(imagePath: state.passportImagePath!));

    try {
      // TODO: Implement your upload logic here
      // Example:
      // await yourUploadService.uploadPassport(
      //   imagePath: state.passportImagePath!,
      // );

      // Simulate network delay for demonstration
      await Future.delayed(const Duration(seconds: 2));

      emit(const PassportUploadSuccessState());
    } catch (e) {
      emit(
        PassportUploadErrorState(
          error: e.toString(),
          imagePath: state.passportImagePath,
        ),
      );
    }
  }

  void _onPassportImageRemoved(
    PassportImageRemoved event,
    Emitter<UploadState> emit,
  ) {
    emit(const PassportImagePickedState(imagePath: ''));
  }

  // Reset handler
  void _onReset(ResetUploadState event, Emitter<UploadState> emit) {
    emit(const UploadInitial());
  }
}
