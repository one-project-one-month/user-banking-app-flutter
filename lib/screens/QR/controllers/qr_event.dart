import 'package:equatable/equatable.dart';

abstract class QREvent extends Equatable {
  const QREvent();

  @override
  List<Object?> get props => [];
}

/// Generate QR to Receive (with amount and note)
class QRGenerateToReceive extends QREvent {
  final double amount;
  final String note;

  const QRGenerateToReceive({
    required this.amount,
    required this.note,
  });

  @override
  List<Object?> get props => [amount, note];
}

/// Scan QR to Receive (process scanned token)
class QRScanToReceive extends QREvent {
  final String token;

  const QRScanToReceive(this.token);

  @override
  List<Object?> get props => [token];
}

/// Generate QR to Pay (for receiving payments from others)
class QRGenerateToPay extends QREvent {
  const QRGenerateToPay();
}

/// Subscribe to QR to Pay events (listen for scans)
class QRSubscribeToPay extends QREvent {
  final String token;

  const QRSubscribeToPay(this.token);

  @override
  List<Object?> get props => [token];
}

/// Clear QR data
class QRClear extends QREvent {
  const QRClear();
}