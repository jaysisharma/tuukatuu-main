class Store {
  final String id;
  final String name;
  final String description;
  final String image;
  final String banner;
  final String address;
  final String phone;
  final String email;
  final double rating;
  final int reviews;
  final bool isFeatured;
  final bool isActive;
  final String deliveryTime;
  final double minimumOrder;
  final double deliveryFee;
  final List<String> categories;
  final Map<String, dynamic>? coordinates;

  Store({
    required this.id,
    required this.name,
    required this.description,
    required this.image,
    required this.banner,
    required this.address,
    required this.phone,
    required this.email,
    required this.rating,
    required this.reviews,
    required this.isFeatured,
    required this.isActive,
    required this.deliveryTime,
    required this.minimumOrder,
    required this.deliveryFee,
    required this.categories,
    this.coordinates,
  });

  factory Store.fromJson(Map<String, dynamic> json) {
    return Store(
      id: json['_id'] ?? json['id'] ?? '',
      name: json['storeName'] ?? json['name'] ?? '',
      description: json['storeDescription'] ?? json['description'] ?? '',
      image: json['storeImage'] ?? json['image'] ?? '',
      banner: json['storeBanner'] ?? json['banner'] ?? '',
      address: json['storeAddress'] ?? json['address'] ?? '',
      phone: json['storePhone'] ?? json['phone'] ?? '',
      email: json['storeEmail'] ?? json['email'] ?? '',
      rating: (json['storeRating'] ?? json['rating'] ?? 0).toDouble(),
      reviews: json['totalRatings'] ?? json['reviews'] ?? 0,
      isFeatured: json['isFeatured'] ?? false,
      isActive: json['isActive'] ?? true,
      deliveryTime: json['deliveryTime'] ?? '30-45 min',
      minimumOrder: (json['minimumOrder'] ?? 0).toDouble(),
      deliveryFee: (json['deliveryFee'] ?? 0).toDouble(),
      categories: List<String>.from(json['categories'] ?? []),
      coordinates: json['storeCoordinates'] ?? json['coordinates'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'description': description,
      'image': image,
      'banner': banner,
      'address': address,
      'phone': phone,
      'email': email,
      'rating': rating,
      'reviews': reviews,
      'isFeatured': isFeatured,
      'isActive': isActive,
      'deliveryTime': deliveryTime,
      'minimumOrder': minimumOrder,
      'deliveryFee': deliveryFee,
      'categories': categories,
      'coordinates': coordinates,
    };
  }

  Store copyWith({
    String? id,
    String? name,
    String? description,
    String? image,
    String? banner,
    String? address,
    String? phone,
    String? email,
    double? rating,
    int? reviews,
    bool? isFeatured,
    bool? isActive,
    String? deliveryTime,
    double? minimumOrder,
    double? deliveryFee,
    List<String>? categories,
    Map<String, dynamic>? coordinates,
  }) {
    return Store(
      id: id ?? this.id,
      name: name ?? this.name,
      description: description ?? this.description,
      image: image ?? this.image,
      banner: banner ?? this.banner,
      address: address ?? this.address,
      phone: phone ?? this.phone,
      email: email ?? this.email,
      rating: rating ?? this.rating,
      reviews: reviews ?? this.reviews,
      isFeatured: isFeatured ?? this.isFeatured,
      isActive: isActive ?? this.isActive,
      deliveryTime: deliveryTime ?? this.deliveryTime,
      minimumOrder: minimumOrder ?? this.minimumOrder,
      deliveryFee: deliveryFee ?? this.deliveryFee,
      categories: categories ?? this.categories,
      coordinates: coordinates ?? this.coordinates,
    );
  }

  // Demo store for testing
  static Store get demoStore => Store(
    id: 'demo-store-1',
    name: 'Fresh Grocery Store',
    description: 'Your one-stop shop for fresh groceries and household essentials',
    image: 'https://images.unsplash.com/photo-1559339352-11d035aa65de?w=400',
    banner: 'https://images.unsplash.com/photo-1559339352-11d035aa65de?w=800',
    address: '123 Main Street, Kathmandu',
    phone: '+977-1-2345678',
    email: 'freshgrocery@example.com',
    rating: 4.5,
    reviews: 120,
    isFeatured: true,
    isActive: true,
    deliveryTime: '30-45 min',
    minimumOrder: 200.0,
    deliveryFee: 50.0,
    categories: ['Grocery', 'Fresh Produce', 'Household'],
    coordinates: {'latitude': 27.7172, 'longitude': 85.3240},
  );
} 