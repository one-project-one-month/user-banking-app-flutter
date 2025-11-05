import 'package:equatable/equatable.dart';

/// From Account model (user's own account)
class FromAccount extends Equatable {
  final String id;
  final String accountNumber;
  final double balance;

  const FromAccount({
    required this.id,
    required this.accountNumber,
    required this.balance,
  });

  factory FromAccount.fromJson(Map<String, dynamic> json) {
    return FromAccount(
      id: json['id']?.toString() ?? '',
      accountNumber: json['accountNumber'] ?? '',
      balance: _parseDouble(json['balance']),
    );
  }

  static double _parseDouble(dynamic value) {
    if (value == null) return 0.0;
    if (value is double) return value;
    if (value is int) return value.toDouble();
    if (value is String) return double.tryParse(value) ?? 0.0;
    return 0.0;
  }

  String get formattedBalance {
    final formatter = balance.toStringAsFixed(0);
    return formatter.replaceAllMapped(
      RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'),
      (Match m) => '${m[1]},',
    );
  }

  @override
  List<Object?> get props => [id, accountNumber, balance];
}

/// Transfer recipient details
class TransferRecipient extends Equatable {
  final String id;
  final String accountNumber;
  final String fullName;

  const TransferRecipient({
    required this.id,
    required this.accountNumber,
    required this.fullName,
  });

  factory TransferRecipient.fromJson(Map<String, dynamic> json) {
    return TransferRecipient(
      id: json['id']?.toString() ?? '',
      accountNumber: json['accountNumber'] ?? '',
      fullName: json['fullName'] ?? json['fullname'] ?? '',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'accountNumber': accountNumber,
      'fullName': fullName,
    };
  }

  @override
  List<Object?> get props => [id, accountNumber, fullName];
}

/// Favorite user with nickname
class FavoriteUser extends Equatable {
  final String nicknameId;
  final String nickname;
  final String accountNumber;
  final String fullName;

  const FavoriteUser({
    required this.nicknameId,
    required this.nickname,
    required this.accountNumber,
    required this.fullName,
  });

  factory FavoriteUser.fromJson(Map<String, dynamic> json) {
    return FavoriteUser(
      nicknameId: json['nicknameId']?.toString() ?? '',
      nickname: json['nickname'] ?? '',
      accountNumber: json['accountNumber'] ?? '',
      fullName: json['fullName'] ?? json['fullname'] ?? '',
    );
  }

  TransferRecipient toRecipient() {
    return TransferRecipient(
      id: nicknameId,
      accountNumber: accountNumber,
      fullName: fullName,
    );
  }

  @override
  List<Object?> get props => [nicknameId, nickname, accountNumber, fullName];
}