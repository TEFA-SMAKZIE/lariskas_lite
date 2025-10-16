class TokenPayload {
  final String serialNumberId;
  final String serialNumber;
  final String userId;
  final String name;
  final String email;
  final String phoneNumber;
  final int iat;
  final int exp;

  TokenPayload(
      {required this.serialNumber,
      required this.serialNumberId,
      required this.userId,
      required this.name,
      required this.email,
      required this.phoneNumber,
      required this.iat,
      required this.exp});

  factory TokenPayload.fromJson(Map<String, dynamic> json) {
    return TokenPayload(
        serialNumberId: json['serialNumberId'] as String? ?? '',
        serialNumber: json['serialNumber'] as String? ?? '',
        userId: json['userId'] as String? ?? '',
        name: json['name'] as String? ?? '',
        email: json['email'] as String? ?? '',
        phoneNumber: json['phoneNumber'] as String? ?? '',
        iat: json['iat'] as int? ?? 0,
        exp: json['exp'] as int? ?? 0);
  }
}
