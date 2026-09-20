class User {
  final String id;
  final String email;
  final String nickname;
  final String? profileImageUrl;

  const User({
    required this.id,
    required this.email,
    required this.nickname,
    this.profileImageUrl,
  });

  User copyWith({
    String? id,
    String? email,
    String? nickname,
    String? profileImageUrl,
  }) {
    return User(
      id: id ?? this.id,
      email: email ?? this.email,
      nickname: nickname ?? this.nickname,
      profileImageUrl: profileImageUrl ?? this.profileImageUrl,
    );
  }

  factory User.fromJson(Map<String, dynamic> json) {
    return User(
      id: json['id'] as String,
      email: json['email'] as String,
      nickname: json['nickname'] as String,
      profileImageUrl: json['profileImageUrl'] as String?,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'email': email,
      'nickname': nickname,
      'profileImageUrl': profileImageUrl,
    };
  }
}