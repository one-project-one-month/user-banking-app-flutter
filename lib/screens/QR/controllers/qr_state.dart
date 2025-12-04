import 'package:equatable/equatable.dart';
import '../models/qr_models.dart';

enum QRStatus {
  initial,
  generating,
  generated,
  scanning,
  scanned,
  subscribing,
  listening,
  error,
}

class QRState extends Equatable {
  final QRStatus status;
  final QRToReceive? qrToReceive;
  final QRToPay? qrToPay;
  final ScannedQRData? scannedData;
  final String? errorMessage;
  final bool isSubscribed;

  const QRState({
    this.status = QRStatus.initial,
    this.qrToReceive,
    this.qrToPay,
    this.scannedData,
    this.errorMessage,
    this.isSubscribed = false,
  });

  QRState copyWith({
    QRStatus? status,
    QRToReceive? Function()? qrToReceive,
    QRToPay? Function()? qrToPay,
    ScannedQRData? Function()? scannedData,
    String? Function()? errorMessage,
    bool? isSubscribed,
  }) {
    return QRState(
      status: status ?? this.status,
      qrToReceive: qrToReceive != null ? qrToReceive() : this.qrToReceive,
      qrToPay: qrToPay != null ? qrToPay() : this.qrToPay,
      scannedData: scannedData != null ? scannedData() : this.scannedData,
      errorMessage: errorMessage != null ? errorMessage() : this.errorMessage,
      isSubscribed: isSubscribed ?? this.isSubscribed,
    );
  }

  bool get isGenerating => status == QRStatus.generating;
  bool get isGenerated => status == QRStatus.generated;
  bool get isScanning => status == QRStatus.scanning;
  bool get isScanned => status == QRStatus.scanned;
  bool get isSubscribing => status == QRStatus.subscribing;
  bool get isListening => status == QRStatus.listening;
  bool get hasError => status == QRStatus.error;

  @override
  List<Object?> get props => [
        status,
        qrToReceive,
        qrToPay,
        scannedData,
        errorMessage,
        isSubscribed,
      ];
}