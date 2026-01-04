import 'package:supabase_flutter/supabase_flutter.dart';
import '../models/transaction_model.dart';

class WalletRepository {
  final SupabaseClient _client;

  WalletRepository(this._client);

  // 1. Son İşlemleri Getir (Mutfağa Sipariş Verme)
  Future<List<TransactionModel>> getRecentTransactions() async {
    try {
      // Supabase'deki kullanıcının ID'sini al
      final userId = _client.auth.currentUser!.id;

      // Sorgu: "transactions" tablosuna git, benim ID'me ait olanları seç, tarihe göre yeni olan en başta olsun.
      final List<dynamic> data = await _client
          .from('transactions')
          .select()
          .eq('user_id', userId) // Sadece benim verim!
          .order('date', ascending: false) // En yenisi en üstte
          .limit(10); // Şimdilik son 10 işlemi getir

      // Gelen ham veriyi (JSON) bizim Model'e çevir
      return data.map((e) => TransactionModel.fromJson(e)).toList();
    } catch (e) {
      print("Veri çekme hatası: $e");
      return []; // Hata olursa boş liste döndür, uygulama çökmesin
    }
  }

  // 2. Yeni İşlem Ekle (Yakında kullanacağız)
  Future<void> addTransaction({
    required String title,
    required double amount,
    required bool isExpense,
  }) async {
    final userId = _client.auth.currentUser!.id;

    // 1. Önce kullanıcının bir cüzdanı var mı kontrol et?
    var accountResponse = await _client
        .from('accounts')
        .select('id')
        .eq('user_id', userId)
        .limit(1)
        .maybeSingle();

    String accountId;

    // 2. EĞER CÜZDAN YOKSA OTOMATİK OLUŞTUR! (Hayat kurtaran kısım)
    if (accountResponse == null) {
      final newAccount = await _client
          .from('accounts')
          .insert({
        'user_id': userId,
        'name': 'Nakit', // Varsayılan isim
        'type': 'cash',
        'balance': 0,
      })
          .select()
          .single(); // Oluştur ve bilgisini geri al

      accountId = newAccount['id'];
    } else {
      accountId = accountResponse['id'];
    }

    // 3. Şimdi harcamayı gönül rahatlığıyla ekle
    await _client.from('transactions').insert({
      'user_id': userId,
      'account_id': accountId,
      'description': title,
      'amount': amount,
      'type': isExpense ? 'expense' : 'income',
      'date': DateTime.now().toIso8601String(),
    });
  }
}