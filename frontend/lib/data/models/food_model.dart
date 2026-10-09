class FoodModel {
  final String id;
  final String name;
  final String category;
  final String? imageUrl;
  final String? description;
  final bool isActive;

  const FoodModel({
    required this.id,
    required this.name,
    required this.category,
    this.imageUrl,
    this.description,
    this.isActive = true,
  });

  factory FoodModel.fromJson(Map<String, dynamic> json) {
    return FoodModel(
      id: json['id']?.toString() ?? '',
      name: json['name'] as String? ?? '',
      category: json['category'] as String? ?? '',
      imageUrl: json['image_url'] as String?,
      description: json['description'] as String?,
      isActive: json['is_active'] as bool? ?? true,
    );
  }

  Map<String, dynamic> toJson() => {
    'id': id,
    'name': name,
    'category': category,
    'image_url': imageUrl,
    'description': description,
    'is_active': isActive,
  };

  FoodModel copyWith({
    String? id,
    String? name,
    String? category,
    String? imageUrl,
    String? description,
    bool? isActive,
  }) {
    return FoodModel(
      id: id ?? this.id,
      name: name ?? this.name,
      category: category ?? this.category,
      imageUrl: imageUrl ?? this.imageUrl,
      description: description ?? this.description,
      isActive: isActive ?? this.isActive,
    );
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) || other is FoodModel && id == other.id;

  @override
  int get hashCode => id.hashCode;
}
