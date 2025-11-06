class UserProfile {
  final String name;
  final String phone;
  final String? avatarUrl;

  const UserProfile({required this.name, required this.phone, this.avatarUrl});

  factory UserProfile.fromJson(Map<String, dynamic> json) => UserProfile(
        name: json['name'] as String? ?? '',
        phone: json['phone'] as String? ?? '',
        avatarUrl: json['avatarUrl'] as String?,
      );

  Map<String, dynamic> toJson() => {
        'name': name,
        'phone': phone,
        'avatarUrl': avatarUrl,
      };
}
