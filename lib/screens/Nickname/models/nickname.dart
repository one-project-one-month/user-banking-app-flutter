class ToAccountDetail {
  final String id;
  final String accountNumber;

  ToAccountDetail({required this.id, required this.accountNumber});

  factory ToAccountDetail.fromJson(Map<String, dynamic> json) {
    return ToAccountDetail(id: (json['id'] ?? '').toString(), accountNumber: (json['accountNumber'] ?? '').toString());
  }

  Map<String, dynamic> toJson() => {'id': id, 'accountNumber': accountNumber};
}

class NicknameOption {
  final String id;
  final String nickname;
  final ToAccountDetail toaccountDetail;

  NicknameOption({required this.id, required this.nickname, required this.toaccountDetail});

  factory NicknameOption.fromJson(Map<String, dynamic> json) {
    return NicknameOption(
      id: (json['id'] ?? '').toString(),
      nickname: (json['nickname'] ?? '').toString(),
      toaccountDetail:
          json['toAccountDetail'] != null || json['toaccountDetail'] != null
              ? ToAccountDetail.fromJson((json['toAccountDetail'] ?? json['toaccountDetail']) as Map<String, dynamic>)
              : ToAccountDetail(id: '', accountNumber: ''),
    );
  }

  Map<String, dynamic> toJson() => {'id': id, 'nickname': nickname, 'toAccountDetail': toaccountDetail.toJson()};

  @override
  String toString() => 'NicknameOption(id: $id, nickname: $nickname, account: ${toaccountDetail.accountNumber})';
}
