class AddOn {
  final String id;
  final String name;
  final String? description;
  final double price;
  final String? icon;
  final bool isActive;

  AddOn({
    required this.id,
    required this.name,
    this.description,
    required this.price,
    this.icon,
    required this.isActive,
  });

  factory AddOn.fromJson(Map<String, dynamic> json) {
    return AddOn(
      id: json['_id'] ?? json['id'] ?? '',
      name: json['name'] ?? '',
      description: json['description'],
      price: (json['price'] ?? 0).toDouble(),
      icon: json['icon'],
      isActive: json['isActive'] ?? true,
    );
  }
}
