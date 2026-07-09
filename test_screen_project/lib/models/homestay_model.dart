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
  final int? maxGuests;
  final int? numBedrooms;
  final int? numBathrooms;
  final String? hostId;
  final String? hostName;
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
    this.maxGuests,
    this.numBedrooms,
    this.numBathrooms,
    this.hostId,
    this.hostName,
    this.hostAvatar,
  });

  factory Homestay.fromJson(Map<String, dynamic> json) {
    // Backend DTO tra ve field "images" la List<String> (danh sach URL)
    List<String> imageList = [];

    if (json['images'] != null && json['images'] is List) {
      // Format tu Backend Spring Boot (HomestayDto)
      imageList = (json['images'] as List)
          .map((img) => img.toString())
          .toList();
    } else if (json['homestay_images'] != null && json['homestay_images'] is List) {
      // Format tu Supabase truc tiep (fallback)
      imageList = (json['homestay_images'] as List)
          .map((img) => img['url'].toString())
          .toList();
    }

    return Homestay(
      id: json['id'] is int ? json['id'] : int.tryParse(json['id'].toString()) ?? 0,
      name: json['name'] ?? '',
      description: json['description'] ?? '',
      address: json['address'] ?? '',
      city: json['city'] ?? '',
      pricePerNight: (json['price_per_night'] ?? json['pricePerNight'] ?? 0).toDouble(),
      rating: (json['rating'] ?? 0).toDouble(),
      images: imageList,
      // Backend tra ve category la String ten, Supabase tra ve object
      category: json['category'] is String
          ? json['category']
          : (json['categories']?['name'] ?? ''),
      status: json['status'] ?? 'active',
      maxGuests: json['max_guests'] ?? json['maxGuests'],
      numBedrooms: json['num_bedrooms'] ?? json['numBedrooms'],
      numBathrooms: json['num_bathrooms'] ?? json['numBathrooms'],
      hostId: json['hostId'] ?? json['host_id'],
      hostName: json['hostName'] ?? json['host_name'],
      hostAvatar: json['hostAvatar'] ?? json['host_avatar'],
    );
  }
}
