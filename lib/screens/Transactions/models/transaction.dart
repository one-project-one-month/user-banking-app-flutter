import 'package:equatable/equatable.dart';

class TransferUser {
  final int id;
  final String name;

  TransferUser({required this.id, required this.name});

  factory TransferUser.fromJson(Map<String, dynamic> json) {
    return TransferUser(
      id: json['id'] is int ? json['id'] : int.parse(json['id'].toString()),
      name: json['name']?.toString() ?? '',
    );
  }

  Map<String, dynamic> toJson() => {'id': id, 'name': name};
}

class TransferAccount {
  final int id;
  final String accountNumber;
  final double balance;

  TransferAccount({required this.id, required this.accountNumber, required this.balance});

  factory TransferAccount.fromJson(Map<String, dynamic> json) {
    return TransferAccount(
      id: json['id'] is int ? json['id'] : int.parse(json['id'].toString()),
      accountNumber: json['accountNumber'] ?? json['account_number'] ?? '',
      balance: _parseDouble(json['balance'] ?? 0),
    );
  }

  Map<String, dynamic> toJson() => {'id': id, 'accountNumber': accountNumber, 'balance': balance};

  static double _parseDouble(dynamic value) {
    if (value == null) return 0.0;
    if (value is double) return value;
    if (value is int) return value.toDouble();
    if (value is String) return double.tryParse(value) ?? 0.0;
    return 0.0;
  }
}

class RecentTransfer extends Equatable {
  final TransferUser user;
  final TransferAccount account;
  final String? time;
  final bool isIncome;
  final bool quickPay;

  const RecentTransfer({
    required this.user,
    required this.account,
    this.time,
    this.isIncome = false,
    this.quickPay = false,
  });

  factory RecentTransfer.fromJson(Map<String, dynamic> json) {
    return RecentTransfer(
      user: TransferUser.fromJson(json['user'] ?? {}),
      account: TransferAccount.fromJson(json['account'] ?? {}),
      time: json['time']?.toString(),
      isIncome: json['isIncome'] ?? json['is_income'] ?? false,
      quickPay: json['quickPay'] ?? json['quick_pay'] ?? false,
    );
  }

  Map<String, dynamic> toJson() => {
    'user': user.toJson(),
    'account': account.toJson(),
    if (time != null) 'time': time,
    'isIncome': isIncome,
    'quickPay': quickPay,
  };

  String get formattedBalance {
    final formatter = account.balance.toStringAsFixed(0);
    return formatter.replaceAllMapped(RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'), (Match m) => '${m[1]},');
  }

  @override
  List<Object?> get props => [user, account, time, isIncome, quickPay];
}

// For grouping transactions by date
class TransactionGroup {
  final String date;
  final List<RecentTransfer> transactions;

  TransactionGroup({required this.date, required this.transactions});

  double get totalIncome {
    return transactions.where((t) => t.isIncome).fold(0.0, (sum, t) => sum + t.account.balance);
  }

  double get totalOutcome {
    return transactions.where((t) => !t.isIncome).fold(0.0, (sum, t) => sum + t.account.balance);
  }
}
