class Product {
  final String id;
  final String name;
  final double price;
  final String imageUrl;
  final String category;
  final double rating;
  final int reviews;
  final bool isAvailable;
  final double deliveryFee;
  final String description;
  final List<String> images;
  final String? deliveryTime;
  final String? unit;
  final String vendorId;
  final String? dealTag;
  final String? dealExpiresAt;
  // Vendor information
  final Map<String, dynamic>? vendor;

  const Product({
    required this.id,
    required this.name,
    required this.price,
    required this.imageUrl,
    required this.category,
    required this.rating,
    required this.reviews,
    required this.isAvailable,
    required this.deliveryFee,
    required this.description,
    required this.images,
    required this.vendorId,
    this.deliveryTime = '10 mins',
    this.unit = '1 piece',
    this.dealTag,
    this.dealExpiresAt,
    this.vendor,
  });

  // Get vendor name from populated vendor data
  String get vendorName {
    if (vendor != null && vendor!['storeName'] != null) {
      return vendor!['storeName'];
    }
    return category; // Fallback to category if no vendor name
  }

  // Get vendor image from populated vendor data
  String get vendorImage {
    if (vendor != null && vendor!['storeImage'] != null) {
      return vendor!['storeImage'];
    }
    return imageUrl; // Fallback to product image
  }

  // Get vendor description from populated vendor data
  String get vendorDescription {
    if (vendor != null && vendor!['storeDescription'] != null) {
      return vendor!['storeDescription'];
    }
    return 'Store for $category products';
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is Product &&
          runtimeType == other.runtimeType &&
          id == other.id;

  @override
  int get hashCode => id.hashCode;

  static List<Product> dummyProducts = [
    const Product(
      id: '1',
      name: 'Coca Cola 1L',
      price: 80.0,
      imageUrl: 'assets/images/products/coca_cola.jpg',
      category: 'Beverages',
      rating: 4.5,
      reviews: 120,
      isAvailable: true,
      deliveryFee: 0,
      description: 'Coca-Cola is a carbonated soft drink manufactured by The Coca-Cola Company.',
      images: [
        'assets/images/products/coca_cola.jpg',
        'assets/images/products/coca_cola_2.jpg',
      ],
      vendorId: 'vendor1',
    ),
    const Product(
      id: '2',
      name: 'Lays Classic 100g',
      price: 50.0,
      imageUrl: 'assets/images/products/lays.jpg',
      category: 'Snacks',
      rating: 4.3,
      reviews: 85,
      isAvailable: true,
      deliveryFee: 20,
      description: 'LAY\'S® Classic potato chips are made with the highest quality potatoes and a sprinkle of salt.',
      images: [
        'assets/images/products/lays.jpg',
        'assets/images/products/lays_2.jpg',
      ],
      vendorId: 'vendor2',
    ),
    const Product(
      id: '3',
      name: 'Amul Milk 1L',
      price: 68.0,
      imageUrl: 'assets/images/products/milk.jpg',
      category: 'Dairy',
      rating: 4.7,
      reviews: 200,
      isAvailable: true,
      deliveryFee: 0,
      description: 'Fresh and nutritious milk from Amul, perfect for your daily needs.',
      images: [
        'assets/images/products/milk.jpg',
        'assets/images/products/milk_2.jpg',
      ],
      vendorId: 'vendor1',
    ),
    const Product(
      id: '4',
      name: 'Fresh Bread',
      price: 40.0,
      imageUrl: 'assets/images/products/bread.jpg',
      category: 'Bakery',
      rating: 4.4,
      reviews: 150,
      isAvailable: true,
      deliveryFee: 15,
      description: 'Freshly baked bread made with the finest ingredients.',
      images: [
        'assets/images/products/bread.jpg',
        'assets/images/products/bread_2.jpg',
      ],
      vendorId: 'vendor2',
    ),
    const Product(
      id: '5',
      name: 'Chocolate Bar',
      price: 45.0,
      imageUrl: 'assets/images/products/chocolate.jpg',
      category: 'Snacks',
      rating: 4.6,
      reviews: 180,
      isAvailable: true,
      deliveryFee: 0,
      description: 'Rich and creamy milk chocolate that melts in your mouth.',
      images: [
        'assets/images/products/chocolate.jpg',
        'assets/images/products/chocolate_2.jpg',
      ],
      vendorId: 'vendor1',
    ),
  ];

  factory Product.fromJson(Map<String, dynamic> json) {
    // Handle populated vendorId field
    Map<String, dynamic>? vendorData;
    if (json['vendorId'] is Map<String, dynamic>) {
      vendorData = json['vendorId'] as Map<String, dynamic>;
    } else if (json['vendor'] is Map<String, dynamic>) {
      vendorData = json['vendor'] as Map<String, dynamic>;
    }

    // Get the main image URL
    final mainImageUrl = json['imageUrl'] ?? json['image'] ?? '';
    
    // Get images array and ensure main image is included
    List<String> images = [];
    if (json['images'] is List) {
      images = (json['images'] as List).map((e) => e.toString()).toList();
    }
    
    // If images array is empty or doesn't contain the main image, add it
    if (mainImageUrl.isNotEmpty && (images.isEmpty || !images.contains(mainImageUrl))) {
      images.insert(0, mainImageUrl);
    }

    return Product(
      id: json['_id']?.toString() ?? json['id']?.toString() ?? '',
      name: json['name'] ?? '',
      price: (json['price'] is int) ? (json['price'] as int).toDouble() : (json['price'] ?? 0.0),
      imageUrl: mainImageUrl,
      category: json['category'] ?? '',
      rating: (json['rating'] is int) ? (json['rating'] as int).toDouble() : (json['rating'] ?? 0.0),
      reviews: json['reviews'] ?? 0,
      isAvailable: json['isAvailable'] ?? true,
      deliveryFee: (json['deliveryFee'] is int) ? (json['deliveryFee'] as int).toDouble() : (json['deliveryFee'] ?? 0.0),
      description: json['description'] ?? '',
      images: images,
      vendorId: vendorData?['_id']?.toString() ?? json['vendorId']?.toString() ?? '',
      deliveryTime: json['deliveryTime']?.toString() ?? '10 mins',
      unit: json['unit']?.toString() ?? '1 piece',
      dealTag: json['dealTag'],
      dealExpiresAt: json['dealExpiresAt'],
      vendor: vendorData,
    );
  }
}

class BannerModel {
  final String id;
  final String imageUrl;
  final String? title;
  final String? subtitle;

  BannerModel({required this.id, required this.imageUrl, this.title, this.subtitle});

  factory BannerModel.fromJson(Map<String, dynamic> json) {
    return BannerModel(
      id: json['_id']?.toString() ?? json['id']?.toString() ?? '',
      imageUrl: json['imageUrl'] ?? json['image'] ?? '',
      title: json['title'],
      subtitle: json['subtitle'],
    );
  }
}

class CategoryModel {
  final String id;
  final String name;
  final String? iconUrl;

  CategoryModel({required this.id, required this.name, this.iconUrl});

  factory CategoryModel.fromJson(Map<String, dynamic> json) {
    return CategoryModel(
      id: json['_id']?.toString() ?? json['id']?.toString() ?? '',
      name: json['name'] ?? '',
      iconUrl: json['iconUrl'] ?? json['icon'] ?? '',
    );
  }
}

class Combo {
  final String id;
  final String name;
  final List<Product> products;
  final double price;
  final String image;
  final List<String> tags;
  final bool isActive;

  Combo({
    required this.id,
    required this.name,
    required this.products,
    required this.price,
    required this.image,
    required this.tags,
    required this.isActive,
  });

  factory Combo.fromJson(Map<String, dynamic> json) {
    return Combo(
      id: json['_id']?.toString() ?? json['id']?.toString() ?? '',
      name: json['name'] ?? '',
      products: (json['products'] as List?)?.map((e) => Product.fromJson(e)).toList() ?? [],
      price: (json['price'] is int) ? (json['price'] as int).toDouble() : (json['price'] ?? 0.0),
      image: json['image'] ?? '',
      tags: (json['tags'] as List?)?.map((e) => e.toString()).toList() ?? [],
      isActive: json['isActive'] ?? true,
    );
  }
} 