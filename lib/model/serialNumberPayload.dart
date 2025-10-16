class SerialNumberPayload {
  final String serialNumberId;
  final String serialNumber;
  final String password;
  final String name;
  final String email;
  final String phoneNumber;
  final String profileImage;
  final String userId;
  final String createdAt;
  final String updatedAt;

  SerialNumberPayload(
      {required this.serialNumber,
      required this.serialNumberId,
      required this.password,
      required this.userId,
      required this.name,
      required this.email,
      required this.phoneNumber,
      required this.createdAt,
      required this.updatedAt,
      required this.profileImage});

  factory SerialNumberPayload.fromJson(Map<String, dynamic> json) {
    return SerialNumberPayload(
        serialNumberId: json['_id'] as String? ?? '',
        serialNumber: json['serialNumber'] as String? ?? '',
        password: json['password'] as String,
        name: json['name'] as String? ?? '',
        email: json['email'] as String? ?? '',
        phoneNumber: json['phoneNumber'] as String? ?? '',
        profileImage: json['profileImage'] as String,
        userId: json['userId'] as String? ?? '',
        createdAt: json['createdAt'] as String? ?? "",
        updatedAt: json['updatedAt'] as String? ?? "");
  }

  @override
  String toString() {
    return 'SerialNumberPayload(serialNumberId: $serialNumberId, serialNumber: $serialNumber, password: $password, name: $name, email: $email, phoneNumber: $phoneNumber, profileNumber: $profileImage, userId: $userId, createdAt: $createdAt, updatedAt: $updatedAt)';
  }
}
