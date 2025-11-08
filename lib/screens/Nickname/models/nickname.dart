class ToAccountDetail {
  final String id;
  final String accountNumber;

  ToAccountDetail({required this.id, required this.accountNumber});

  factory ToAccountDetail.fromJson(Map<String, dynamic> json) {
    return ToAccountDetail(
      id: (json['id'] ?? '').toString(),
      accountNumber: (json['accountNumber'] ?? '').toString(),
    );
  }
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
      toaccountDetail: json['toaccountDetail'] != null
          ? ToAccountDetail.fromJson(json['toaccountDetail'] as Map<String, dynamic>)
          : ToAccountDetail(id: '', accountNumber: ''),
    );
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'nickname': nickname,
        'toaccountDetail': {
          'id': toaccountDetail.id,
          'accountNumber': toaccountDetail.accountNumber,
        }
      };
}
