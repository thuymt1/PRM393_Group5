class Homestay {
  final int id;
  final String name;
  final String description;
  final String address;
  final String city;
  final double pricePerNight;
  final double rating;
  final List<String> images;
  final String category;
  final String status;
  final String hostId;
  final String hostName;
  final String? hostAvatar;

  Homestay({
    required this.id,
    required this.name,
    required this.description,
    required this.address,
    required this.city,
    required this.pricePerNight,
    required this.rating,
    required this.images,
    required this.category,
    required this.status,
    required this.hostId,
    this.hostName = 'Chủ nhà',
    this.hostAvatar,
  });

  factory Homestay.fromJson(Map<String, dynamic> json) {
    // Xử lý lấy danh sách ảnh từ bảng liên kết homestay_images (nếu có)
    var imageList = <String>[];
    if (json['homestay_images'] != null) {
      imageList = (json['homestay_images'] as List)
          .map((img) => img['url'] as String)
          .toList();
    }

    return Homestay(
      id: json['id'],
      name: json['name'] ?? '',
      description: json['description'] ?? '',
      address: json['address'] ?? '',
      city: json['city'] ?? '',
      pricePerNight: (json['price_per_night'] ?? 0).toDouble(),
      rating: (json['rating'] ?? 0).toDouble(),
      images: imageList,
      category: json['categories']?['name'] ?? '', // Lấy tên category từ join
      status: json['status'] ?? 'active',
      hostId: json['host_id'] ?? '',
      hostName: json['profiles']?['full_name'] ?? 'Chủ nhà',
      hostAvatar: json['profiles']?['avatar_url'],
    );
  }
}
