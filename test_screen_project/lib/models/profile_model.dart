class ProfileModel {
  final String id;
  final String email;
  final String fullName;
  final String phone;
  final String role; // customer | host | author
  final String? avatarUrl;

  const ProfileModel({
    required this.id,
    required this.email,
    required this.fullName,
    required this.phone,
    required this.role,
    this.avatarUrl,
  });

  factory ProfileModel.fromJson(Map<String, dynamic> json) {
    return ProfileModel(
      id: json['id'] ?? '',
      email: json['email'] ?? '',
      fullName: json['full_name'] ?? '',
      phone: json['phone'] ?? '',
      role: json['role'] ?? 'customer',
      avatarUrl: json['avatar_url'],
    );
  }
}
