class CategoryModel {
  final String id;
  final String name;      // Örn: Market
  final String type;      // income (gelir) veya expense (gider)
  final String iconCode;  // Örn: cartShopping

  CategoryModel({
    required this.id,
    required this.name,
    required this.type,
    required this.iconCode,
  });

  // Supabase'den gelen JSON verisini modele çeviren fabrika
  factory CategoryModel.fromJson(Map<String, dynamic> json) {
    return CategoryModel(
      id: json['id'],
      name: json['name'],
      type: json['type'],
      // Eğer veritabanında ikon boşsa 'question' (soru işareti) koy
      iconCode: json['icon'] ?? 'question',
    );
  }
}