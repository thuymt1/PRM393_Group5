class HostApplication {
  final String id;
  final String userId;
  final String fullName;
  final String phone;
  final String email;
  final String? reason;
  final String? experience;
  final String status; // pending | approved | rejected
  final String? adminNote;
  final DateTime createdAt;
  final DateTime? reviewedAt;
  final String? reviewedBy;

  HostApplication({
    required this.id,
    required this.userId,
    required this.fullName,
    required this.phone,
    required this.email,
    this.reason,
    this.experience,
    required this.status,
    this.adminNote,
    required this.createdAt,
    this.reviewedAt,
    this.reviewedBy,
  });

  factory HostApplication.fromJson(Map<String, dynamic> json) {
    return HostApplication(
      id: json['id'] ?? '',
      userId: json['user_id'] ?? '',
      fullName: json['full_name'] ?? '',
      phone: json['phone'] ?? '',
      email: json['email'] ?? '',
      reason: json['reason'],
      experience: json['experience'],
      status: json['status'] ?? 'pending',
      adminNote: json['admin_note'],
      createdAt: DateTime.parse(json['created_at'] ?? DateTime.now().toIso8601String()),
      reviewedAt: json['reviewed_at'] != null ? DateTime.parse(json['reviewed_at']) : null,
      reviewedBy: json['reviewed_by'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'user_id': userId,
      'full_name': fullName,
      'phone': phone,
      'email': email,
      'reason': reason,
      'experience': experience,
      'status': status,
      'admin_note': adminNote,
      'created_at': createdAt.toIso8601String(),
      'reviewed_at': reviewedAt?.toIso8601String(),
      'reviewed_by': reviewedBy,
    };
  }

  bool get isPending => status == 'pending';
  bool get isApproved => status == 'approved';
  bool get isRejected => status == 'rejected';

  String get statusLabel {
    switch (status) {
      case 'pending': return 'Đang chờ xét duyệt';
      case 'approved': return 'Đã được phê duyệt';
      case 'rejected': return 'Bị từ chối';
      default: return 'Không xác định';
    }
  }
}
