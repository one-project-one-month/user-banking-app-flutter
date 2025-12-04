import 'package:equatable/equatable.dart';

/// QR to Receive - Generated QR data
class QRToReceive extends Equatable {
  final String token;
  final double amount;
  final String note;

  const QRToReceive({
    required this.token,
    required this.amount,
    required this.note,
  });

  factory QRToReceive.fromJson(Map<String, dynamic> json) {
    return QRToReceive(
      token: json['token']?.toString() ?? '',
      amount: _parseDouble(json['amount']),
      note: json['note']?.toString() ?? '',
    );
  }

  Map<String, dynamic> toJson() => {
        'token': token,
        'amount': amount,
        'note': note,
      };

  static double _parseDouble(dynamic value) {
    if (value == null) return 0.0;
    if (value is double) return value;
    if (value is int) return value.toDouble();
    if (value is String) return double.tryParse(value) ?? 0.0;
    return 0.0;
  }

  @override
  List<Object?> get props => [token, amount, note];
}

/// QR to Pay - Generated QR data
class QRToPay extends Equatable {
  final String token;

  const QRToPay({required this.token});

  factory QRToPay.fromJson(Map<String, dynamic> json) {
    return QRToPay(
      token: json['token']?.toString() ?? '',
    );
  }

  Map<String, dynamic> toJson() => {
        'token': token,
      };

  @override
  List<Object?> get props => [token];
}

/// Scanned QR data (from QR to Pay scan)
class ScannedQRData extends Equatable {
  final String fromAccountId;
  final String fromAccountNumber;
  final double fromBalance;
  final String fromName; // Added: name of the sender
  final String toAccountId;
  final String toAccountNumber;
  final double toBalance;
  final String toName; // Added: name of the recipient
  final double amount;
  final String note;

  const ScannedQRData({
    required this.fromAccountId,
    required this.fromAccountNumber,
    required this.fromBalance,
    required this.fromName,
    required this.toAccountId,
    required this.toAccountNumber,
    required this.toBalance,
    required this.toName,
    required this.amount,
    required this.note,
  });

  factory ScannedQRData.fromJson(Map<String, dynamic> json) {
    final fromAccount = json['fromAccountDetails'] as Map<String, dynamic>?;
    final toAccount = json['toAccountDetails'] as Map<String, dynamic>?;

    return ScannedQRData(
      fromAccountId: fromAccount?['id']?.toString() ?? '',
      fromAccountNumber: fromAccount?['accountNumber']?.toString() ?? '',
      fromBalance: _parseDouble(fromAccount?['balance']),
      fromName: '', // Will be fetched separately
      toAccountId: toAccount?['id']?.toString() ?? '',
      toAccountNumber: toAccount?['accountNumber']?.toString() ?? '',
      toBalance: _parseDouble(toAccount?['balance']),
      toName: '', // Will be fetched separately
      amount: _parseDouble(json['amount']),
      note: json['note']?.toString() ?? '',
    );
  }
  
  ScannedQRData copyWith({
    String? fromName,
    String? toName,
  }) {
    return ScannedQRData(
      fromAccountId: fromAccountId,
      fromAccountNumber: fromAccountNumber,
      fromBalance: fromBalance,
      fromName: fromName ?? this.fromName,
      toAccountId: toAccountId,
      toAccountNumber: toAccountNumber,
      toBalance: toBalance,
      toName: toName ?? this.toName,
      amount: amount,
      note: note,
    );
  }

  static double _parseDouble(dynamic value) {
    if (value == null) return 0.0;
    if (value is double) return value;
    if (value is int) return value.toDouble();
    if (value is String) return double.tryParse(value) ?? 0.0;
    return 0.0;
  }

  @override
  List<Object?> get props => [
        fromAccountId,
        fromAccountNumber,
        fromBalance,
        fromName,
        toAccountId,
        toAccountNumber,
        toBalance,
        toName,
        amount,
        note,
      ];
}