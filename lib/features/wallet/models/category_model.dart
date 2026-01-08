// lib/features/wallet/models/category_model.dart

/// Kategori modeli (categories tablosu)
class CategoryModel {
  final String id;
  final String userId;
  final String name;
  final String? icon; // Icon kodu (FontAwesome)
  final String type; // income veya expense
  final bool isFavorite; // Favori mi?
  final DateTime createdAt;

  CategoryModel({
    required this.id,
    required this.userId,
    required this.name,
    this.icon,
    required this.type,
    this.isFavorite = false,
    required this.createdAt,
  });

  /// JSON'dan model oluştur
  factory CategoryModel.fromJson(Map<String, dynamic> json) {
    return CategoryModel(
      id: json['id'] as String,
      userId: json['user_id'] as String,
      name: json['name'] as String,
      icon: json['icon'] as String?,
      type: json['type'] as String,
      isFavorite: json['is_favorite'] as bool? ?? false,
      createdAt: DateTime.parse(json['created_at'] as String),
    );
  }

  /// Model'i JSON'a çevir
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'user_id': userId,
      'name': name,
      'icon': icon,
      'type': type,
      'is_favorite': isFavorite,
      'created_at': createdAt.toIso8601String(),
    };
  }

  /// Gelir kategorisi mi?
  bool get isIncome => type == 'income';

  /// Gider kategorisi mi?
  bool get isExpense => type == 'expense';

  /// Kopyala ve güncelle
  CategoryModel copyWith({
    String? id,
    String? userId,
    String? name,
    String? icon,
    String? type,
    bool? isFavorite,
    DateTime? createdAt,
  }) {
    return CategoryModel(
      id: id ?? this.id,
      userId: userId ?? this.userId,
      name: name ?? this.name,
      icon: icon ?? this.icon,
      type: type ?? this.type,
      isFavorite: isFavorite ?? this.isFavorite,
      createdAt: createdAt ?? this.createdAt,
    );
  }
}
