class Address {
  final String id;
  final String label;
  final String address;
  final double latitude;
  final double longitude;
  final String type;
  final String instructions;
  final bool isDefault;
  final bool isVerified;
  final DateTime createdAt;
  final DateTime updatedAt;

  Address({
    required this.id,
    required this.label,
    required this.address,
    required this.latitude,
    required this.longitude,
    required this.type,
    required this.instructions,
    required this.isDefault,
    required this.isVerified,
    required this.createdAt,
    required this.updatedAt,
  });

  factory Address.fromJson(Map<String, dynamic> json) {
    final coords = json['coordinates'] ?? {};

    return Address(
      id: json['_id'] ?? '',
      label: json['label'] ?? '',
      address: json['address'] ?? '',
      latitude: (coords['latitude'] ?? 0).toDouble(),
      longitude: (coords['longitude'] ?? 0).toDouble(),
      type: json['type'] ?? 'other',
      instructions: json['instructions'] ?? '',
      isDefault: json['isDefault'] ?? false,
      isVerified: json['isVerified'] ?? false,
      createdAt: DateTime.tryParse(json['createdAt'] ?? '') ?? DateTime.now(),
      updatedAt: DateTime.tryParse(json['updatedAt'] ?? '') ?? DateTime.now(),
    );
  }

  @override
  String toString() {
    return 'Address(id: $id, label: $label, address: $address, '
           'latitude: $latitude, longitude: $longitude, type: $type, '
           'instructions: $instructions, isDefault: $isDefault, '
           'isVerified: $isVerified, createdAt: $createdAt, updatedAt: $updatedAt)';
  }
}
