class TransactionModel {
  final String id;
  final String title;     // Örn: Starbucks
  final double amount;    // Örn: 145.0
  final DateTime date;    // Örn: Bugün
  final bool isExpense;   // true (Gider) veya false (Gelir)

  TransactionModel({
    required this.id,
    required this.title,
    required this.amount,
    required this.date,
    required this.isExpense,
  });

  // RESTORAN MANTIĞI:
  // Supabase'den (Mutafaktan) gelen veriyi (JSON) bizim anlayacağımız şekle çeviren yer.
  factory TransactionModel.fromJson(Map<String, dynamic> json) {
    return TransactionModel(
      id: json['id'],
      // Veritabanında bazen 'description' bazen 'name' olabilir, ona göre ayarlıyoruz
      title: json['description'] ?? 'Bilinmeyen İşlem',
      amount: (json['amount'] as num).toDouble(),
      date: DateTime.parse(json['date']),
      // Eğer type 'expense' ise true, yoksa false olsun
      isExpense: json['type'] == 'expense',
    );
  }
}