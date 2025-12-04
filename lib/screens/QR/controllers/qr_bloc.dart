import 'dart:async';
import 'package:flutter_bloc/flutter_bloc.dart';

import 'qr_event.dart';
import 'qr_state.dart';
import '../services/qr_api_service.dart';
import '../../auth/services/cache_service.dart';

class QRBloc extends Bloc<QREvent, QRState> {
  final QRApiService api;
  final CacheService cache;
  StreamSubscription? _subscriptionStream;

  QRBloc({QRApiService? apiService, CacheService? cacheService})
    : api = apiService ?? QRApiService(baseUrl: "https://136.112.160.13:7777"),
      cache = cacheService ?? CacheService(),
      super(const QRState()) {
    on<QRGenerateToReceive>(_onGenerateToReceive);
    on<QRScanToReceive>(_onScanToReceive);
    on<QRGenerateToPay>(_onGenerateToPay);
    on<QRSubscribeToPay>(_onSubscribeToPay);
    on<QRClear>(_onClear);
  }

  /// Generate QR to Receive
  FutureOr<void> _onGenerateToReceive(QRGenerateToReceive event, Emitter<QRState> emit) async {
    emit(state.copyWith(status: QRStatus.generating));

    try {
      final token = await cache.getToken();

      if (token == null || token.accessToken.isEmpty) {
        emit(state.copyWith(status: QRStatus.error, errorMessage: () => 'No authentication token found'));
        return;
      }

      final qrData = await api.generateQRToReceive(token.accessToken, event.amount, event.note);

      emit(state.copyWith(status: QRStatus.generated, qrToReceive: () => qrData, errorMessage: () => null));
    } catch (e) {
      String errorMsg = 'Failed to generate QR to Receive';
      if (e is QRApiException) {
        errorMsg = e.message;
      }

      print('❌ QRBloc error: $errorMsg');
      emit(state.copyWith(status: QRStatus.error, errorMessage: () => errorMsg));
    }
  }

  /// Scan QR to Receive
  FutureOr<void> _onScanToReceive(QRScanToReceive event, Emitter<QRState> emit) async {
    emit(state.copyWith(status: QRStatus.scanning));

    try {
      final token = await cache.getToken();

      if (token == null || token.accessToken.isEmpty) {
        emit(state.copyWith(status: QRStatus.error, errorMessage: () => 'No authentication token found'));
        return;
      }

      final scannedData = await api.scanQRToReceive(token.accessToken, event.token);

      emit(state.copyWith(status: QRStatus.scanned, scannedData: () => scannedData, errorMessage: () => null));
    } catch (e) {
      String errorMsg = 'Failed to scan QR';
      if (e is QRApiException) {
        errorMsg = e.message;
      }

      print('❌ QRBloc error: $errorMsg');
      emit(state.copyWith(status: QRStatus.error, errorMessage: () => errorMsg));
    }
  }

  /// Generate QR to Pay
  FutureOr<void> _onGenerateToPay(QRGenerateToPay event, Emitter<QRState> emit) async {
    emit(state.copyWith(status: QRStatus.generating));

    try {
      final token = await cache.getToken();

      if (token == null || token.accessToken.isEmpty) {
        emit(state.copyWith(status: QRStatus.error, errorMessage: () => 'No authentication token found'));
        return;
      }

      final qrData = await api.generateQRToPay(token.accessToken);

      emit(state.copyWith(status: QRStatus.generated, qrToPay: () => qrData, errorMessage: () => null));
    } catch (e) {
      String errorMsg = 'Failed to generate QR to Pay';
      if (e is QRApiException) {
        errorMsg = e.message;
      }

      print('❌ QRBloc error: $errorMsg');
      emit(state.copyWith(status: QRStatus.error, errorMessage: () => errorMsg));
    }
  }

  /// Subscribe to QR to Pay events
  FutureOr<void> _onSubscribeToPay(QRSubscribeToPay event, Emitter<QRState> emit) async {
    emit(state.copyWith(status: QRStatus.subscribing));

    try {
      final token = await cache.getToken();

      if (token == null || token.accessToken.isEmpty) {
        emit(state.copyWith(status: QRStatus.error, errorMessage: () => 'No authentication token found'));
        return;
      }

      // Cancel any existing subscription
      await _subscriptionStream?.cancel();

      // Start listening to SSE stream
      emit(state.copyWith(status: QRStatus.listening, isSubscribed: true, errorMessage: () => null));

      final stream = api.subscribeToQRToPay(token.accessToken, event.token);

      _subscriptionStream = stream.listen(
        (data) {
          print('📥 QR to Pay event received: $data');

          // Handle timeout event
          if (data.containsKey('timeout')) {
            print('⏱️ QR to Pay subscription timeout');
            add(const QRClear());
          }

          // TODO: Handle other events when backend implements them
          // For example: payment completion, scan notification, etc.
        },
        onError: (error) {
          print('❌ QR subscription error: $error');
          emit(
            state.copyWith(status: QRStatus.error, errorMessage: () => 'Connection error: $error', isSubscribed: false),
          );
        },
        onDone: () {
          print('✅ QR subscription closed');
          emit(state.copyWith(status: QRStatus.initial, isSubscribed: false));
        },
      );
    } catch (e) {
      String errorMsg = 'Failed to subscribe to QR events';
      if (e is QRApiException) {
        errorMsg = e.message;
      }

      print('❌ QRBloc error: $errorMsg');
      emit(state.copyWith(status: QRStatus.error, errorMessage: () => errorMsg, isSubscribed: false));
    }
  }

  /// Clear QR data
  FutureOr<void> _onClear(QRClear event, Emitter<QRState> emit) async {
    // Cancel subscription if active
    await _subscriptionStream?.cancel();
    _subscriptionStream = null;

    emit(const QRState(status: QRStatus.initial, isSubscribed: false));
  }

  @override
  Future<void> close() {
    _subscriptionStream?.cancel();
    api.dispose();
    return super.close();
  }
}
