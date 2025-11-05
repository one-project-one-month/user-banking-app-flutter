import 'package:equatable/equatable.dart';

class SelectedAccountDetails {
  final int? id;
  final String accountNumber;
  final double balance;

  SelectedAccountDetails({this.id, required this.accountNumber, required this.balance});

  factory SelectedAccountDetails.fromJson(Map<String, dynamic> json) {
    return SelectedAccountDetails(
      id: json['id'] is int ? json['id'] : (json['id'] != null ? int.tryParse(json['id'].toString()) : null),
      accountNumber: json['accountNumber'] ?? json['account_number'] ?? '',
      balance: _parseDouble(json['balance'] ?? 0),
    );
  }

  static double _parseDouble(dynamic value) {
    if (value == null) return 0.0;
    if (value is double) return value;
    if (value is int) return value.toDouble();
    if (value is String) return double.tryParse(value) ?? 0.0;
    return 0.0;
  }
}

class User extends Equatable {
  final String email;
  final String username;
  final double currentBalance;
  final SelectedAccountDetails? selectedAccountDetails;

  const User({
    required this.email,
    required this.username,
    required this.currentBalance,
    this.selectedAccountDetails,
  });

  factory User.fromJson(Map<String, dynamic> json) {
    SelectedAccountDetails? accountDetails;
    if (json.containsKey('selectedAccountDetails') && json['selectedAccountDetails'] != null) {
      accountDetails = SelectedAccountDetails.fromJson(
        json['selectedAccountDetails'] is Map<String, dynamic>
            ? json['selectedAccountDetails'] as Map<String, dynamic>
            : Map<String, dynamic>.from(json['selectedAccountDetails']),
      );
    }

    return User(
      email: json['email'] ?? '',
      username: json['username'] ?? '',
      currentBalance: _parseDouble(json['currentBalance'] ?? json['current_balance'] ?? 0),
      selectedAccountDetails: accountDetails,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'email': email,
      'username': username,
      'currentBalance': currentBalance,
      if (selectedAccountDetails != null)
        'selectedAccountDetails': {
          'id': selectedAccountDetails!.id,
          'accountNumber': selectedAccountDetails!.accountNumber,
          'balance': selectedAccountDetails!.balance,
        }
    };
  }

  User copyWith({
    String? email,
    String? username,
    double? currentBalance,
    SelectedAccountDetails? selectedAccountDetails,
  }) {
    return User(
      email: email ?? this.email,
      username: username ?? this.username,
      currentBalance: currentBalance ?? this.currentBalance,
      selectedAccountDetails: selectedAccountDetails ?? this.selectedAccountDetails,
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
    // Format balance with thousand separators
    final formatter = currentBalance.toStringAsFixed(0);
    return formatter.replaceAllMapped(RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'), (Match m) => '${m[1]},');
  }

  @override
  List<Object?> get props => [email, username, currentBalance, selectedAccountDetails];

  @override
  String toString() {
    return 'User(email: $email, username: $username, balance: $currentBalance)';
  }
}
