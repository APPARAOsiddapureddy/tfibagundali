class UserModel {
  const UserModel({
    required this.id,
    required this.phone,
    required this.displayName,
    required this.username,
    required this.region,
    required this.isNewUser,
  });

  final String id;
  final String phone;
  final String displayName;
  final String username;
  final String region;
  final bool isNewUser;

  factory UserModel.fromJson(Map<String, dynamic> json) {
    return UserModel(
      id: (json['id'] ?? '').toString(),
      phone: (json['phone'] ?? '').toString(),
      displayName: (json['display_name'] ?? json['displayName'] ?? 'Fan')
          .toString(),
      username: (json['username'] ?? '@fan').toString(),
      region: (json['region'] ?? 'AP/TS').toString(),
      isNewUser: (json['is_new_user'] ?? json['isNewUser'] ?? false) == true,
    );
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'phone': phone,
        'display_name': displayName,
        'username': username,
        'region': region,
        'is_new_user': isNewUser,
      };
}

