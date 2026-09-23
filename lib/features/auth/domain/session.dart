class Session {
  final String token;
  final String deviceId;
  final String userName;

  const Session({
    required this.token,
    required this.deviceId,
    required this.userName,
  });

  factory Session.fromJson(Map<String, dynamic> json) {
    return Session(
      token: json['token'] as String,
      deviceId: json['deviceId'] as String,
      userName: json['user']?['name'] as String? ?? json['userName'] as String? ?? 'User',
    );
  }

  Map<String, dynamic> toJson() => {
    'token': token,
    'deviceId': deviceId,
    'userName': userName,
  };
}
