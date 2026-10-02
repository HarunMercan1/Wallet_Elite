// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Turkish (`tr`).
class AppLocalizationsTr extends AppLocalizations {
  AppLocalizationsTr([String locale = 'tr']) : super(locale);

  @override
  String get appName => 'Cüzdan Elite';

  @override
  String get cancel => 'İptal';

  @override
  String get save => 'Kaydet';

  @override
  String get saved => 'Kaydedildi';

  @override
  String get delete => 'Sil';

  @override
  String get edit => 'Düzenle';

  @override
  String get add => 'Ekle';

  @override
  String get ok => 'Tamam';

  @override
  String get error => 'Hata';

  @override
  String get success => 'Başarılı';

  @override
  String get loading => 'Yükleniyor...';

  @override
  String get search => 'Ara...';

  @override
  String get all => 'Tümü';

  @override
  String get today => 'Bugün';

  @override
  String get yesterday => 'Dün';

  @override
  String get notFound => 'bulunamadı';

  @override
  String get home => 'Ana Sayfa';

  @override
  String get transactions => 'İşlemler';

  @override
  String get statistics => 'İstatistik';

  @override
  String get settings => 'Ayarlar';

  @override
  String get welcome => 'Hoş geldin,';

  @override
  String get totalBalance => 'Toplam Bakiye';

  @override
  String get recentTransactions => 'Son İşlemler';

  @override
  String get noTransactions => 'Henüz işlem yok';

  @override
  String get addFirstTransaction => '+ butonuna basarak başla!';

  @override
  String get income => 'Gelir';

  @override
  String get expense => 'Gider';

  @override
  String get amount => 'Tutar';

  @override
  String get category => 'Kategori';

  @override
  String get note => 'Not';

  @override
  String get date => 'Tarih';

  @override
  String get wallet => 'Cüzdan';

  @override
  String get addTransaction => 'İşlem Ekle';

  @override
  String get editTransaction => 'İşlemi Düzenle';

  @override
  String get deleteTransaction => 'İşlemi Sil';

  @override
  String get transactionAdded => 'İşlem eklendi';

  @override
  String get transactionUpdated => 'İşlem güncellendi';

  @override
  String get transactionDeleted => 'İşlem silindi';

  @override
  String get enterAmount => 'Tutar giriniz';

  @override
  String get selectWallet => 'Cüzdan seçiniz';

  @override
  String get addNote => 'Açıklama ekle...';

  @override
  String get more => 'Daha Fazla';

  @override
  String get searchTransactions => 'İşlem ara...';

  @override
  String get noIncomeFound => 'Gelir işlemi bulunamadı';

  @override
  String get noExpenseFound => 'Gider işlemi bulunamadı';

  @override
  String get confirmDelete =>
      'Bu işlemi silmek istediğinize emin misiniz? Bu işlem geri alınamaz.';

  @override
  String get categories => 'Kategoriler';

  @override
  String get incomeCategories => 'Gelir Kategorileri';

  @override
  String get expenseCategories => 'Gider Kategorileri';

  @override
  String get newCategory => 'Yeni Kategori';

  @override
  String get newIncomeCategory => 'Yeni Gelir Kategorisi';

  @override
  String get newExpenseCategory => 'Yeni Gider Kategorisi';

  @override
  String get categoryName => 'Kategori Adı';

  @override
  String get selectIcon => 'İkon Seç:';

  @override
  String get categoryAdded => 'Kategori eklendi';

  @override
  String get createCategories => 'Kategorileri Oluştur';

  @override
  String get noCategories => 'Henüz kategori yok';

  @override
  String get longPressToFavorite => 'Uzun basarak favorilere ekle/çıkar';

  @override
  String addedToFavorites(String name) {
    return '$name favorilere eklendi';
  }

  @override
  String removedFromFavorites(String name) {
    return '$name favorilerden çıkarıldı';
  }

  @override
  String get wallets => 'Cüzdanlar';

  @override
  String get addWallet => 'Cüzdan Ekle';

  @override
  String get walletName => 'Cüzdan Adı';

  @override
  String get walletType => 'Cüzdan Türü';

  @override
  String get initialBalance => 'Başlangıç Bakiyesi';

  @override
  String get cash => 'Nakit';

  @override
  String get bank => 'Banka';

  @override
  String get creditCard => 'Kredi Kartı';

  @override
  String get savings => 'Birikim';

  @override
  String get walletAdded => 'Cüzdan eklendi';

  @override
  String get walletDeleted => 'Cüzdan silindi';

  @override
  String get editWallet => 'Cüzdanı Düzenle';

  @override
  String get walletUpdated => 'Cüzdan güncellendi';

  @override
  String get deleteWallet => 'Cüzdanı Sil';

  @override
  String get deleteWalletConfirm =>
      'Bu cüzdanı silmek istediğinize emin misiniz? Bu cüzdandaki tüm işlemler de kalıcı olarak silinecektir.';

  @override
  String get noWallets => 'Henüz cüzdan yok';

  @override
  String get manageWallets => 'Cüzdanları Yönet';

  @override
  String get categoryNotFound => 'Kategori bulunamadı';

  @override
  String get walletNotFound => 'Cüzdan bulunamadı';

  @override
  String errorWithDetails(String details) {
    return 'Hata: $details';
  }

  @override
  String get networkError =>
      'Ağ bağlantı hatası. Lütfen internetinizi kontrol edin.';

  @override
  String get appearance => 'Görünüm';

  @override
  String get theme => 'Tema';

  @override
  String get language => 'Dil';

  @override
  String get dark => 'Koyu';

  @override
  String get light => 'Açık';

  @override
  String get system => 'Sistem';

  @override
  String get selectTheme => 'Tema Seçin';

  @override
  String get selectLanguage => 'Dil Seçin';

  @override
  String get colorScheme => 'Renk Şeması';

  @override
  String get account => 'Hesap';

  @override
  String get signOut => 'Çıkış Yap';

  @override
  String get signOutConfirm => 'Çıkış yapmak istediğinizden emin misiniz?';

  @override
  String get user => 'Kullanıcı';

  @override
  String get login => 'Giriş Yap';

  @override
  String get register => 'Kayıt Ol';

  @override
  String get email => 'E-posta';

  @override
  String get password => 'Şifre';

  @override
  String get fullName => 'Ad Soyad';

  @override
  String get forgotPassword => 'Şifremi Unuttum';

  @override
  String get noAccount => 'Hesabınız yok mu?';

  @override
  String get haveAccount => 'Zaten hesabınız var mı?';

  @override
  String get loginSuccess => 'Giriş başarılı!';

  @override
  String get registerSuccess =>
      'Kayıt başarılı! Lütfen e-postanızı doğrulayın.';

  @override
  String get thisMonth => 'Bu Ay';

  @override
  String get lastMonth => 'Geçen Ay';

  @override
  String get thisYear => 'Bu Yıl';

  @override
  String get monthly => 'Aylık';

  @override
  String get weekly => 'Haftalık';

  @override
  String get daily => 'Günlük';

  @override
  String get totalIncome => 'Toplam Gelir';

  @override
  String get totalExpense => 'Toplam Gider';

  @override
  String get balance => 'Bakiye';

  @override
  String get categoryBreakdown => 'Kategori Dağılımı';

  @override
  String get cat_food => 'Yemek';

  @override
  String get cat_transport => 'Ulaşım';

  @override
  String get cat_shopping => 'Alışveriş';

  @override
  String get cat_entertainment => 'Eğlence';

  @override
  String get cat_bills => 'Faturalar';

  @override
  String get cat_health => 'Sağlık';

  @override
  String get cat_education => 'Eğitim';

  @override
  String get cat_rent => 'Kira';

  @override
  String get cat_taxes => 'Vergi';

  @override
  String get cat_salary => 'Maaş';

  @override
  String get cat_freelance => 'Freelance';

  @override
  String get cat_investment => 'Yatırım';

  @override
  String get cat_gift => 'Hediye';

  @override
  String get cat_other => 'Diğer';

  @override
  String get cat_pets => 'Evcil Hayvan';

  @override
  String get cat_groceries => 'Market';

  @override
  String get cat_electronics => 'Elektronik';

  @override
  String get cat_charity => 'Bağış';

  @override
  String get cat_insurance => 'Sigorta';

  @override
  String get cat_gym => 'Spor';

  @override
  String get cat_travel => 'Seyahat';

  @override
  String get statisticsTitle => 'İstatistik Özeti';

  @override
  String get periodFilter => 'Dönem';

  @override
  String get allTime => 'Tüm Zamanlar';

  @override
  String get last7Days => 'Son 7 Gün';

  @override
  String get last30Days => 'Son 30 Gün';

  @override
  String get averageDailySpending => 'Günlük Ort. Harcama';

  @override
  String get totalTransactions => 'Toplam İşlem';

  @override
  String get incomeCount => 'Gelir Sayısı';

  @override
  String get expenseCount => 'Gider Sayısı';

  @override
  String get topCategories => 'En Çok Harcama';

  @override
  String get savingsRate => 'Tasarruf Oranı';

  @override
  String get biggestIncome => 'En Büyük Gelir';

  @override
  String get biggestExpense => 'En Büyük Gider';

  @override
  String get noData => 'Bu dönem için veri yok';

  @override
  String get spendingTrend => 'Harcama Trendi';

  @override
  String get incomeVsExpense => 'Gelir - Gider';

  @override
  String get loginTab => 'Giriş Yap';

  @override
  String get registerTab => 'Kayıt Ol';

  @override
  String get tagline => 'Finansal özgürlüğünüz, avucunuzda';

  @override
  String get enterFullName => 'Ad soyad giriniz';

  @override
  String get nameTooShort => 'Ad en az 2 karakter olmalı';

  @override
  String get enterEmail => 'E-posta giriniz';

  @override
  String get validEmail => 'Geçerli bir e-posta giriniz';

  @override
  String get enterPassword => 'Şifre giriniz';

  @override
  String get passwordTooShort => 'Şifre en az 6 karakter olmalı';

  @override
  String get forgotPasswordTitle => 'Şifre Sıfırla';

  @override
  String get forgotPasswordText =>
      'E-posta adresinize şifre sıfırlama bağlantısı göndereceğiz.';

  @override
  String get send => 'Gönder';

  @override
  String get passwordResetSent => 'Şifre sıfırlama bağlantısı gönderildi.';

  @override
  String get loginFailed => 'Giriş başarısız. E-posta veya şifre yanlış.';

  @override
  String get registerFailed =>
      'Kayıt başarısız. Bu e-posta zaten kullanılıyor olabilir.';

  @override
  String get googleLoginFailed => 'Google ile giriş başarısız oldu';

  @override
  String get continueWithGoogle => 'Google ile Devam Et';

  @override
  String get orDivider => 'veya';

  @override
  String get privacyText =>
      'Devam ederek Kullanım Şartları ve Gizlilik Politikası\'nı kabul etmiş olursunuz';

  @override
  String get errorOccurred => 'Bir hata oluştu';

  @override
  String get welcomeTitle => 'Wallet Elite\'e\\nHoş Geldin! 👋';

  @override
  String get welcomeSubtitle =>
      'Finansal özgürlüğüne giden yolculuğa başlamak için birkaç basit adım kaldı.';

  @override
  String get manageWalletsDesc => 'Tüm hesaplarını tek yerden takip et';

  @override
  String get analyzeSpending => 'Harcamalarını Analiz Et';

  @override
  String get analyzeSpendingDesc => 'Nereye para gittiğini gör';

  @override
  String get debtBook => 'Borç Defteri';

  @override
  String get debtBookDesc => 'Alacak ve borçlarını takip et';

  @override
  String get backButton => 'Geri';

  @override
  String get continueButton => 'Devam';

  @override
  String get startButton => 'Başla';

  @override
  String get selectCurrency => 'Para Birimi Seç';

  @override
  String get selectCurrencyDesc =>
      'Tüm hesaplarında kullanacağın para birimini seç';

  @override
  String get turkishLira => 'Türk Lirası';

  @override
  String get usDollar => 'Amerikan Doları';

  @override
  String get euro => 'Euro';

  @override
  String get britishPound => 'İngiliz Sterlini';

  @override
  String get createFirstWallet => 'İlk Cüzdanını Oluştur';

  @override
  String get createWalletDesc =>
      'Paranı takip etmeye başlamak için bir cüzdan oluştur';

  @override
  String get walletNameHint => 'örn: Nakit Param';

  @override
  String get cashType => 'Nakit';

  @override
  String get bankAccount => 'Banka Hesabı';

  @override
  String get creditCardType => 'Kredi Kartı';

  @override
  String get investmentType => 'Altın/Yatırım';

  @override
  String get initialBalanceOptional => 'Başlangıç Bakiyesi (Opsiyonel)';

  @override
  String get initialBalanceHint =>
      'Şu anda cüzdanında ne kadar para olduğunu gir. Sonra istediğin zaman değiştirebilirsin.';

  @override
  String get enterWalletName => 'Lütfen cüzdan adı girin';

  @override
  String get onboardingSuccess => 'Kayıt başarılı! Giriş yapabilirsiniz.';

  @override
  String get mon => 'Pt';

  @override
  String get tue => 'Sa';

  @override
  String get wed => 'Ça';

  @override
  String get thu => 'Pe';

  @override
  String get fri => 'Cu';

  @override
  String get sat => 'Ct';

  @override
  String get sun => 'Pz';

  @override
  String get addExpense => 'Gider Ekle';

  @override
  String get addIncome => 'Gelir Ekle';

  @override
  String get expenseAdded => 'Gider eklendi';

  @override
  String get incomeAdded => 'Gelir eklendi';

  @override
  String get debtTracking => 'Borç Takibi';

  @override
  String get myLends => 'Alacaklarım';

  @override
  String get myDebts => 'Borçlarım';

  @override
  String get personName => 'Kişi Adı';

  @override
  String get dueDate => 'Vade Tarihi';

  @override
  String get recordPayment => 'Ödeme Kaydet';

  @override
  String daysRemaining(int days) {
    return '$days gün kaldı';
  }

  @override
  String get overdue => 'Vadesi geçmiş';

  @override
  String get remaining => 'Kalan';

  @override
  String get lend => 'Borç Verdim';

  @override
  String get borrow => 'Borç Aldım';

  @override
  String get upcomingDues => 'Yaklaşan Vadeler';

  @override
  String get allRecords => 'Tüm Kayıtlar';

  @override
  String get hideCompleted => 'Tamamlananları Gizle';

  @override
  String get showCompleted => 'Tamamlananları Göster';

  @override
  String get markAsCompleted => 'Tamamlandı Olarak İşaretle';

  @override
  String get debtAdded => 'Kayıt eklendi';

  @override
  String get debtUpdated => 'Kayıt güncellendi';

  @override
  String get debtDeleted => 'Kayıt silindi';

  @override
  String get paymentRecorded => 'Ödeme kaydedildi';

  @override
  String get noDebts => 'Henüz borç kaydı yok';

  @override
  String get addDebt => 'Kayıt Ekle';

  @override
  String get debtAmount => 'Tutar';

  @override
  String get debtDescription => 'Açıklama (opsiyonel)';

  @override
  String get selectDueDate => 'Vade tarihi seç';

  @override
  String get totalLent => 'Toplam Alacak';

  @override
  String get totalBorrowed => 'Toplam Borç';

  @override
  String people(int count) {
    return '$count kişi';
  }

  @override
  String memberSince(String date) {
    return '$date tarihinden beri üye';
  }

  @override
  String get editProfile => 'Profili Düzenle';

  @override
  String get profileUpdated => 'Profil güncellendi';

  @override
  String get changePhoto => 'Fotoğrafı Değiştir';

  @override
  String get takePhoto => 'Fotoğraf Çek';

  @override
  String get chooseFromGallery => 'Galeriden Seç';

  @override
  String get removePhoto => 'Fotoğrafı Kaldır';

  @override
  String get notifications => 'Bildirimler';

  @override
  String get quickActions => 'Hızlı İşlemler';

  @override
  String get thisMonthSummary => 'Bu Ay Özeti';

  @override
  String get financialScore => 'Finansal Skor';

  @override
  String get financialScoreDesc => 'Finansal sağlık puanınız';

  @override
  String get spendingTips => 'Harcama İpuçları';

  @override
  String get spendingTipsDesc => 'Tasarruf önerileri';

  @override
  String get categoryAnalysis => 'Kategori Analizi';

  @override
  String get categoryAnalysisDesc => 'Detaylı harcama dağılımı';

  @override
  String get monthlyComparison => 'Aylık Karşılaştırma';

  @override
  String get monthlyComparisonDesc => 'Geçmiş aylarla kıyasla';

  @override
  String get budgetProgress => 'Bütçe Durumu';

  @override
  String get budgetProgressDesc => 'Hedeflerine ne kadar yakınsın';

  @override
  String get viewDetails => 'Detayları Gör';

  @override
  String get excellent => 'Mükemmel';

  @override
  String get good => 'İyi';

  @override
  String get average => 'Ortalama';

  @override
  String get needsImprovement => 'Geliştirilmeli';

  @override
  String get poor => 'Zayıf';

  @override
  String get comparedToLastMonth => 'Geçen Aya Göre';

  @override
  String get youSpentLess => 'daha az harcadın';

  @override
  String get youSpentMore => 'daha fazla harcadın';

  @override
  String get noChange => 'Değişiklik yok';

  @override
  String get allWallets => 'Tüm Cüzdanlar';

  @override
  String get budgets => 'Bütçeler';

  @override
  String get history => 'Geçmiş';

  @override
  String get sort => 'Sıralama';

  @override
  String get payment => 'Ödeme';

  @override
  String get completedDebts => 'Tamamlanan Borçlar';

  @override
  String get noCompletedDebts => 'Tamamlanmış borç kaydı yok';

  @override
  String get lent => 'Borç Verdim';

  @override
  String get borrowed => 'Borç Aldım';

  @override
  String get deleteDebt => 'Kaydı Sil';

  @override
  String get deleteDebtConfirm =>
      'Bu kaydı silmek istediğinize emin misiniz? Bu işlem geri alınamaz.';

  @override
  String get paymentHistory => 'Ödeme Geçmişi';

  @override
  String get noPaymentsYet => 'Henüz ödeme yok';

  @override
  String get displayName => 'Görünen İsim';

  @override
  String get customDateRange => 'Özel Aralık';

  @override
  String get startDate => 'Başlangıç Tarihi';

  @override
  String get endDate => 'Bitiş Tarihi';

  @override
  String get selectDateRange => 'Tarih Aralığı Seç';

  @override
  String get transactionSummary => 'İşlem Özeti';

  @override
  String get topSpendingCategory => 'En Çok Harcama';

  @override
  String get leastSpendingCategory => 'En Az Harcama';

  @override
  String get averageTransaction => 'Ort. İşlem';

  @override
  String get weekdaySpending => 'Hafta İçi Harcama';

  @override
  String get weekendSpending => 'Hafta Sonu Harcama';

  @override
  String get vsLastMonth => 'Geçen Aya Göre';

  @override
  String get thisWeek => 'Bu Hafta';

  @override
  String get lastWeek => 'Geçen Hafta';

  @override
  String get last3Months => 'Son 3 Ay';

  @override
  String get last6Months => 'Son 6 Ay';

  @override
  String get viewAllCategories => 'Tüm Kategorileri Gör';

  @override
  String get viewTrendDetails => 'Trend Detayları';

  @override
  String get budgetTips => 'Bütçe Önerileri';

  @override
  String get savingsGoal => 'Tasarruf Hedefi';

  @override
  String get potentialSavings => 'Potansiyel Tasarruf';

  @override
  String ifYouReduce(String category, int percent, String amount) {
    return '$category kategorisinde %$percent azaltırsan ayda $amount tasarruf edersin';
  }

  @override
  String get allCategories => 'Tüm Kategoriler';

  @override
  String get categoryDetails => 'Kategori Detayları';

  @override
  String get trendDetails => 'Trend Detayları';

  @override
  String get periodComparison => 'Dönem Karşılaştırma';

  @override
  String get noExpenseData => 'Gider verisi yok';

  @override
  String get spendingPatterns => 'Harcama Kalıpları';

  @override
  String get apply => 'Uygula';

  @override
  String get reset => 'Sıfırla';

  @override
  String get recurringTransactions => 'Tekrarlayan İşlemler';

  @override
  String get addRecurringTransaction => 'Tekrarlayan İşlem Ekle';

  @override
  String get editRecurringTransaction => 'Tekrarlayan İşlemi Düzenle';

  @override
  String get deleteRecurringTransaction => 'Tekrarlayan İşlemi Sil';

  @override
  String get deleteRecurringConfirmation =>
      'Bu tekrarlayan işlemi silmek istediğinize emin misiniz?';

  @override
  String get noRecurringTransactions => 'Henüz tekrarlayan işlem yok';

  @override
  String get addRecurringTransactionHint =>
      'Maaş, fatura gibi düzenli işlemler ekleyerek zaman kazanın';

  @override
  String get frequency => 'Tekrar Sıklığı';

  @override
  String get yearly => 'Yıllık';

  @override
  String get dayOfMonth => 'Ayın Günü';

  @override
  String get dayOfWeek => 'Haftanın Günü';

  @override
  String get nextExecution => 'Sonraki Çalışma';

  @override
  String get active => 'Aktif';

  @override
  String get inactive => 'Pasif';

  @override
  String get optional => 'Opsiyonel';

  @override
  String get monday => 'Pazartesi';

  @override
  String get tuesday => 'Salı';

  @override
  String get wednesday => 'Çarşamba';

  @override
  String get thursday => 'Perşembe';

  @override
  String get friday => 'Cuma';

  @override
  String get saturday => 'Cumartesi';

  @override
  String get sunday => 'Pazar';

  @override
  String get description => 'Açıklama';

  @override
  String get descriptionHint => 'örn: Netflix aboneliği';

  @override
  String get selectAccount => 'Hesap Seç';

  @override
  String get selectCategory => 'Kategori Seç';

  @override
  String get pleaseEnterAmount => 'Lütfen tutar giriniz';

  @override
  String get pleaseEnterValidAmount => 'Geçerli bir tutar giriniz';

  @override
  String get pleaseSelectAccount => 'Lütfen hesap seçiniz';

  @override
  String get budget => 'Bütçe';

  @override
  String get addBudget => 'Bütçe Ekle';

  @override
  String get editBudget => 'Bütçeyi Düzenle';

  @override
  String get deleteBudget => 'Bütçeyi Sil';

  @override
  String get deleteBudgetConfirmation =>
      'Bu bütçeyi silmek istediğinizden emin misiniz?';

  @override
  String get noBudgets => 'Henüz bütçe yok';

  @override
  String get addBudgetHint =>
      'Harcamalarınızı kontrol altında tutmak için bütçe oluşturun';

  @override
  String get budgetName => 'Bütçe Adı';

  @override
  String get budgetNameHint => 'örn: Aylık Yemek Bütçesi';

  @override
  String get pleaseEnterBudgetName => 'Lütfen bütçe adı giriniz';

  @override
  String get budgetAmount => 'Bütçe Limiti';

  @override
  String get budgetPeriod => 'Bütçe Periyodu';

  @override
  String get budgetStartDay => 'Dönem Başlangıç Günü';

  @override
  String get allExpenses => 'Tüm Harcamalar';

  @override
  String get notifyAtPercent => 'Uyarı Yüzdesi';

  @override
  String get notifyWhenExceeded => 'Aşıldığında bildir';

  @override
  String get used => 'kullanıldı';

  @override
  String get exceeded => 'aşıldı';

  @override
  String get secureData => 'Verileriniz güvenli ve şifrelenmiş';

  @override
  String get cloudSync => 'Tüm cihazlarınızda senkronize edin';

  @override
  String get smartInsights => 'Finanslarınız hakkında akıllı öneriler';

  @override
  String get discoverFeatures => 'Özellikleri Keşfet';

  @override
  String get discoverFeaturesDesc =>
      'Finanslarınızı yönetmek için ihtiyacınız olan her şey';

  @override
  String get budgetTracking => 'Bütçe Takibi';

  @override
  String get budgetTrackingDesc => 'Harcama limitleri belirle ve takip et';

  @override
  String get recurringTransactionsDesc =>
      'Düzenli ödemelerinizi otomatikleştirin';

  @override
  String get selectLanguageDesc => 'Tercih ettiğiniz dili seçin';

  @override
  String get selectThemeDesc => 'Uygulama deneyiminizi kişiselleştirin';

  @override
  String get themeOcean => 'Okyanus';

  @override
  String get themeSunset => 'Gün Batımı';

  @override
  String get themeForest => 'Orman';

  @override
  String get themeLavender => 'Lavanta';

  @override
  String get themeMidnight => 'Gece Yarısı';

  @override
  String get themeRose => 'Gül';

  @override
  String get darkMode => 'Karanlık Mod';

  @override
  String get japaneseYen => 'Japon Yeni';

  @override
  String get russianRuble => 'Rus Rublesi';

  @override
  String get categoryDistribution => 'Kategori Dağılımı';

  @override
  String get other => 'Diğer';

  @override
  String get last7DaysSpending => 'Son 7 Gün Harcama';

  @override
  String get currencyLabel => 'Para Birimi';

  @override
  String get deleteAccount => 'Hesabı Sil';

  @override
  String get deleteAccountConfirmTitle => 'Hesabınız silinsin mi?';

  @override
  String get deleteAccountConfirmMessage =>
      'Hesabınız ve tüm verileriniz (cüzdanlar, işlemler, kategoriler, bütçeler ve borçlar) kalıcı olarak silinecek. Bu işlem geri alınamaz.';

  @override
  String get deleteAccountConfirmButton => 'Kalıcı olarak sil';

  @override
  String get deleteAccountSuccess => 'Hesabınız silindi.';

  @override
  String get filter => 'Filtrele';

  @override
  String get transactionTypeLabel => 'İşlem Tipi';

  @override
  String get highestAmount => 'En Yüksek Tutar';

  @override
  String get lowestAmount => 'En Düşük Tutar';

  @override
  String get appSettingsSection => 'Uygulama';

  @override
  String get replayAppTour => 'Tanıtım Turunu Tekrar İzle';

  @override
  String get replayAppTourDesc => 'Uygulamanın özelliklerini keşfet';

  @override
  String get watchAdToUnlock => 'Reklam izle ve aç';

  @override
  String get premiumThemeUnlockMessage =>
      'Bu premium temayı kalıcı olarak açmak için kısa bir reklam izleyin.';

  @override
  String get watchAd => 'Reklam İzle';

  @override
  String get uploadYourPhoto => 'Kendi fotoğrafını yükle';

  @override
  String get orPickAvatar => 'veya bir avatar seç';

  @override
  String get signingIn => 'Giriş yapılıyor...';

  @override
  String get appTour => 'Tanıtım Turu';

  @override
  String get languageSupportTitle => '18 Dil Desteği 🌍';

  @override
  String get languageSupportDesc => 'Kendi dilinizde kullanın';

  @override
  String get colorThemesTitle => 'Renk Temaları 🎨';

  @override
  String get colorThemesDesc => 'Kendi tarzınızı seçin + Karanlık Mod';

  @override
  String get darkModeAvailable => 'Karanlık mod da mevcut!';

  @override
  String get multiCurrencyTitle => 'Çoklu Para Birimi 💰';

  @override
  String get multiCurrencyDesc => 'Tüm dünya para birimlerini destekliyoruz';

  @override
  String get nextButton => 'İleri';

  @override
  String get errInvalidCredentials => 'E-posta veya şifre hatalı';

  @override
  String get errEmailNotConfirmed => 'Lütfen e-posta adresinizi doğrulayın';

  @override
  String get errTooManyRequests =>
      'Çok fazla deneme yaptınız, lütfen biraz bekleyin';

  @override
  String get errEmailInUse => 'Bu e-posta adresi zaten kullanılıyor';

  @override
  String get errWeakPassword => 'Şifre çok zayıf';

  @override
  String get errInvalidEmail => 'Geçersiz e-posta adresi';

  @override
  String get errGoogleConfig => 'Google giriş yapılandırma hatası (kod 10).';

  @override
  String get errPlayServices =>
      'Google Play Hizmetleri güncel değil veya bu cihaz desteklenmiyor.';

  @override
  String get newestFirst => 'En Yeni';

  @override
  String get oldestFirst => 'En Eski';

  @override
  String get deleteAccountConfirmWord => 'SİL';

  @override
  String deleteAccountTypeToConfirm(String word) {
    return 'Onaylamak için $word yazın';
  }

  @override
  String get premiumTitle => 'Wallet Elite Premium';

  @override
  String get premiumSubtitle => 'Tüm özelliklerin kilidini açın';

  @override
  String get premiumFeatureNoAds => 'Reklamsız kullanım';

  @override
  String get premiumFeatureThemes => 'Tüm premium temalar';

  @override
  String get premiumFeatureUnlimited => 'Sınırsız cüzdan ve bütçe';

  @override
  String get premiumFeatureExport => 'Verilerini dışa aktar (CSV / Excel)';

  @override
  String get planMonthly => 'Aylık';

  @override
  String get planYearly => 'Yıllık';

  @override
  String get planLifetime => 'Ömür boyu';

  @override
  String get perMonth => 'aylık';

  @override
  String get perYear => 'yıllık';

  @override
  String get oneTimePayment => 'Tek seferlik ödeme';

  @override
  String get bestValue => 'En avantajlı';

  @override
  String get restorePurchases => 'Satın Alımları Geri Yükle';

  @override
  String get purchaseSuccess => 'Premium\'a hoş geldiniz! 🎉';

  @override
  String get restoreSuccess => 'Satın alımlar geri yüklendi.';

  @override
  String get purchasePending =>
      'Ödeme onay bekliyor. Onaylanınca Premium etkinleşecek.';

  @override
  String get restoreNothing =>
      'Bu hesap için önceki bir satın alım bulunamadı.';

  @override
  String get purchaseNotAvailable =>
      'Satın alma şu anda kullanılamıyor. Lütfen daha sonra tekrar deneyin.';

  @override
  String get subscriptionTerms =>
      'Abonelikler iptal edilene kadar otomatik yenilenir. Dilediğiniz zaman Google Play > Ödemeler ve abonelikler bölümünden iptal edebilirsiniz.';

  @override
  String get premiumActive => 'Premium etkin';

  @override
  String get premiumActiveDesc =>
      'Wallet Elite\'i desteklediğiniz için teşekkürler!';

  @override
  String get goPremium => 'Premium\'a Geç';

  @override
  String get goPremiumDesc =>
      'Reklamsız, tüm temalar, sınırsız cüzdan ve bütçe';

  @override
  String walletLimitReached(int count) {
    return 'Ücretsiz planda en fazla $count cüzdan oluşturabilirsiniz. Sınırsız cüzdan için Premium\'a geçin.';
  }

  @override
  String budgetLimitReached(int count) {
    return 'Ücretsiz planda en fazla $count aktif bütçe oluşturabilirsiniz. Sınırsız bütçe için Premium\'a geçin.';
  }

  @override
  String unlockThemeTitle(String name) {
    return '$name temasını aç';
  }

  @override
  String get rewardedThemeUnlockMessage =>
      'Bu temayı 24 saat kullanmak için kısa bir reklam izleyin ya da tüm temaları kalıcı açmak için Premium\'a geçin.';

  @override
  String get adNotReady =>
      'Reklam henüz hazır değil. Lütfen biraz sonra tekrar deneyin.';

  @override
  String get themeUnlocked24h => 'Tema 24 saatliğine açıldı';

  @override
  String get adPrivacySettings => 'Reklam gizlilik ayarları';

  @override
  String get exportData => 'Verileri dışa aktar';

  @override
  String get exportDataDesc =>
      'İşlemlerinizi CSV dosyası olarak paylaşın (Excel\'de açılır)';

  @override
  String get exportFailed => 'Dışa aktarma başarısız oldu';

  @override
  String get exportNoData => 'Dışa aktarılacak işlem yok.';

  @override
  String get cat_clothing => 'Giyim';

  @override
  String get supportSection => 'Destek';

  @override
  String get sendFeedback => 'Geliştiriciye Yaz';

  @override
  String get sendFeedbackDesc =>
      'Öneri, şikayet veya isteğini e-postayla gönder';

  @override
  String emailAppNotFound(String email) {
    return 'E-posta uygulaması bulunamadı. Adres: $email';
  }

  @override
  String get rateApp => 'Bizi Değerlendir';

  @override
  String get rateAppDesc => 'Google Play\'de puan ver';

  @override
  String get updateAvailableTitle => 'Güncelleme var';

  @override
  String get updateAvailableMessage =>
      'Wallet Elite\'in yeni sürümü yayınlandı. En yeni özellikler ve düzeltmeler için güncelle.';

  @override
  String get updateNow => 'Güncelle';

  @override
  String get later => 'Sonra';

  @override
  String get summaryImage => 'Özet Görseli';

  @override
  String get summaryImageDesc => 'Özetini görsel olarak kaydet veya paylaş';

  @override
  String get saveToGallery => 'Galeriye Kaydet';

  @override
  String get share => 'Paylaş';

  @override
  String get imageSaved => 'Görsel galeriye kaydedildi';

  @override
  String get imageSaveFailed => 'Görsel kaydedilemedi';
}
