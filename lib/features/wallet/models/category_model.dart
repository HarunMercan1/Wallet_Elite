class CategoryModel {
  final String id;
  final String userId;
  final String name;
  final String? translationKey; // Çeviri anahtarı (varsa)
  final String? icon; // Icon kodu (FontAwesome)
  final String? color; // Renk kodu (Hex)
  final String type; // income veya expense
  final bool isFavorite; // Favori mi?
  final bool isCustom; // Kullanıcı mı oluşturdu?
  final DateTime createdAt;

  CategoryModel({
    required this.id,
    required this.userId,
    required this.name,
    this.translationKey,
    this.icon,
    this.color,
    required this.type,
    this.isFavorite = false,
    this.isCustom = false,
    required this.createdAt,
  });

  /// JSON'dan model oluştur
  factory CategoryModel.fromJson(Map<String, dynamic> json) {
    return CategoryModel(
      id: json['id'] as String,
      userId: json['user_id'] as String,
      name: json['name'] as String,
      translationKey: json['translation_key'] as String?,
      icon: json['icon'] as String?,
      color: json['color'] as String?,
      type: json['type'] as String,
      isFavorite: json['is_favorite'] as bool? ?? false,
      isCustom: json['is_custom'] as bool? ?? false,
      createdAt: DateTime.parse(json['created_at'] as String),
    );
  }

  /// Model'i JSON'a çevir
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'user_id': userId,
      'name': name,
      'translation_key': translationKey,
      'icon': icon,
      'color': color,
      'type': type,
      'is_favorite': isFavorite,
      'is_custom': isCustom,
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
    String? translationKey,
    String? icon,
    String? color,
    String? type,
    bool? isFavorite,
    bool? isCustom,
    DateTime? createdAt,
  }) {
    return CategoryModel(
      id: id ?? this.id,
      userId: userId ?? this.userId,
      name: name ?? this.name,
      translationKey: translationKey ?? this.translationKey,
      icon: icon ?? this.icon,
      color: color ?? this.color,
      type: type ?? this.type,
      isFavorite: isFavorite ?? this.isFavorite,
      isCustom: isCustom ?? this.isCustom,
      createdAt: createdAt ?? this.createdAt,
    );
  }
}
