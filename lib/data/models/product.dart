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
    this.deliveryTime = '10 mins',
    this.unit = '1 piece',
  });

  static List<Product> dummyProducts = [
    Product(
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
    ),
    Product(
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
    ),
    Product(
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
    ),
    Product(
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
    ),
    Product(
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
    ),
  ];
} 