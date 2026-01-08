// lib/core/l10n/app_localizations.dart

/// Uygulama çevirileri
class AppLocalizations {
  final String locale;

  AppLocalizations(this.locale);

  bool get isTr => locale == 'tr';

  // ========== Genel ==========
  String get appName => 'Wallet Elite';
  String get cancel => isTr ? 'İptal' : 'Cancel';
  String get save => isTr ? 'Kaydet' : 'Save';
  String get delete => isTr ? 'Sil' : 'Delete';
  String get edit => isTr ? 'Düzenle' : 'Edit';
  String get add => isTr ? 'Ekle' : 'Add';
  String get ok => isTr ? 'Tamam' : 'OK';
  String get error => isTr ? 'Hata' : 'Error';
  String get success => isTr ? 'Başarılı' : 'Success';
  String get loading => isTr ? 'Yükleniyor...' : 'Loading...';
  String get search => isTr ? 'Ara...' : 'Search...';
  String get all => isTr ? 'Tümü' : 'All';
  String get today => isTr ? 'Bugün' : 'Today';
  String get yesterday => isTr ? 'Dün' : 'Yesterday';

  // ========== Navigation ==========
  String get home => isTr ? 'Ana Sayfa' : 'Home';
  String get transactions => isTr ? 'İşlemler' : 'Transactions';
  String get statistics => isTr ? 'İstatistik' : 'Statistics';
  String get settings => isTr ? 'Ayarlar' : 'Settings';

  // ========== Dashboard ==========
  String get welcome => isTr ? 'Hoş geldin,' : 'Welcome,';
  String get totalBalance => isTr ? 'Toplam Bakiye' : 'Total Balance';
  String get recentTransactions =>
      isTr ? 'Son İşlemler' : 'Recent Transactions';
  String get noTransactions => isTr ? 'Henüz işlem yok' : 'No transactions yet';
  String get addFirstTransaction =>
      isTr ? '+ butonuna basarak başla!' : 'Tap + to add your first!';

  // ========== İşlemler ==========
  String get income => isTr ? 'Gelir' : 'Income';
  String get expense => isTr ? 'Gider' : 'Expense';
  String get amount => isTr ? 'Tutar' : 'Amount';
  String get category => isTr ? 'Kategori' : 'Category';
  String get note => isTr ? 'Not' : 'Note';
  String get date => isTr ? 'Tarih' : 'Date';
  String get wallet => isTr ? 'Cüzdan' : 'Wallet';
  String get addTransaction => isTr ? 'İşlem Ekle' : 'Add Transaction';
  String get editTransaction => isTr ? 'İşlemi Düzenle' : 'Edit Transaction';
  String get deleteTransaction => isTr ? 'İşlemi Sil' : 'Delete Transaction';
  String get transactionAdded => isTr ? 'İşlem eklendi' : 'Transaction added';
  String get transactionUpdated =>
      isTr ? 'İşlem güncellendi' : 'Transaction updated';
  String get transactionDeleted =>
      isTr ? 'İşlem silindi' : 'Transaction deleted';
  String get enterAmount => isTr ? 'Tutar giriniz' : 'Enter amount';
  String get selectWallet => isTr ? 'Cüzdan seçiniz' : 'Select wallet';
  String get addNote => isTr ? 'Açıklama ekle...' : 'Add note...';
  String get more => isTr ? 'Daha Fazla' : 'More';
  String get searchTransactions =>
      isTr ? 'İşlem ara...' : 'Search transactions...';
  String get noIncomeFound =>
      isTr ? 'Gelir işlemi bulunamadı' : 'No income found';
  String get noExpenseFound =>
      isTr ? 'Gider işlemi bulunamadı' : 'No expense found';
  String get confirmDelete => isTr
      ? 'Bu işlemi silmek istediğinize emin misiniz? Bu işlem geri alınamaz.'
      : 'Are you sure you want to delete this transaction? This cannot be undone.';

  // ========== Kategoriler ==========
  String get categories => isTr ? 'Kategoriler' : 'Categories';
  String get incomeCategories =>
      isTr ? 'Gelir Kategorileri' : 'Income Categories';
  String get expenseCategories =>
      isTr ? 'Gider Kategorileri' : 'Expense Categories';
  String get newCategory => isTr ? 'Yeni Kategori' : 'New Category';
  String get newIncomeCategory =>
      isTr ? 'Yeni Gelir Kategorisi' : 'New Income Category';
  String get newExpenseCategory =>
      isTr ? 'Yeni Gider Kategorisi' : 'New Expense Category';
  String get categoryName => isTr ? 'Kategori Adı' : 'Category Name';
  String get selectIcon => isTr ? 'İkon Seç:' : 'Select Icon:';
  String get categoryAdded => isTr ? 'Kategori eklendi' : 'Category added';
  String get createCategories =>
      isTr ? 'Kategorileri Oluştur' : 'Create Categories';
  String get noCategories => isTr ? 'Henüz kategori yok' : 'No categories yet';
  String get longPressToFavorite => isTr
      ? 'Uzun basarak favorilere ekle/çıkar'
      : 'Long press to add/remove favorites';
  String addedToFavorites(String name) =>
      isTr ? '$name favorilere eklendi' : '$name added to favorites';
  String removedFromFavorites(String name) =>
      isTr ? '$name favorilerden çıkarıldı' : '$name removed from favorites';

  // ========== Cüzdanlar ==========
  String get wallets => isTr ? 'Cüzdanlar' : 'Wallets';
  String get addWallet => isTr ? 'Cüzdan Ekle' : 'Add Wallet';
  String get walletName => isTr ? 'Cüzdan Adı' : 'Wallet Name';
  String get walletType => isTr ? 'Cüzdan Türü' : 'Wallet Type';
  String get initialBalance => isTr ? 'Başlangıç Bakiyesi' : 'Initial Balance';
  String get cash => isTr ? 'Nakit' : 'Cash';
  String get bank => isTr ? 'Banka' : 'Bank';
  String get creditCard => isTr ? 'Kredi Kartı' : 'Credit Card';
  String get savings => isTr ? 'Birikim' : 'Savings';
  String get walletAdded => isTr ? 'Cüzdan eklendi' : 'Wallet added';
  String get noWallets => isTr ? 'Henüz cüzdan yok' : 'No wallets yet';
  String get manageWallets => isTr ? 'Cüzdanları Yönet' : 'Manage Wallets';

  // ========== Ayarlar ==========
  String get appearance => isTr ? 'Görünüm' : 'Appearance';
  String get theme => isTr ? 'Tema' : 'Theme';
  String get language => isTr ? 'Dil' : 'Language';
  String get dark => isTr ? 'Koyu' : 'Dark';
  String get light => isTr ? 'Açık' : 'Light';
  String get system => isTr ? 'Sistem' : 'System';
  String get selectTheme => isTr ? 'Tema Seçin' : 'Select Theme';
  String get selectLanguage => isTr ? 'Dil Seçin' : 'Select Language';
  String get account => isTr ? 'Hesap' : 'Account';
  String get signOut => isTr ? 'Çıkış Yap' : 'Sign Out';
  String get signOutConfirm => isTr
      ? 'Çıkış yapmak istediğinizden emin misiniz?'
      : 'Are you sure you want to sign out?';
  String get user => isTr ? 'Kullanıcı' : 'User';

  // ========== Auth ==========
  String get login => isTr ? 'Giriş Yap' : 'Sign In';
  String get register => isTr ? 'Kayıt Ol' : 'Sign Up';
  String get email => isTr ? 'E-posta' : 'Email';
  String get password => isTr ? 'Şifre' : 'Password';
  String get fullName => isTr ? 'Ad Soyad' : 'Full Name';
  String get forgotPassword => isTr ? 'Şifremi Unuttum' : 'Forgot Password';
  String get noAccount => isTr ? 'Hesabınız yok mu?' : "Don't have an account?";
  String get haveAccount =>
      isTr ? 'Zaten hesabınız var mı?' : 'Already have an account?';
  String get loginSuccess => isTr ? 'Giriş başarılı!' : 'Login successful!';
  String get registerSuccess => isTr
      ? 'Kayıt başarılı! Lütfen e-postanızı doğrulayın.'
      : 'Registration successful! Please verify your email.';

  // ========== İstatistik ==========
  String get thisMonth => isTr ? 'Bu Ay' : 'This Month';
  String get lastMonth => isTr ? 'Geçen Ay' : 'Last Month';
  String get thisYear => isTr ? 'Bu Yıl' : 'This Year';
  String get monthly => isTr ? 'Aylık' : 'Monthly';
  String get weekly => isTr ? 'Haftalık' : 'Weekly';
  String get daily => isTr ? 'Günlük' : 'Daily';
  String get totalIncome => isTr ? 'Toplam Gelir' : 'Total Income';
  String get totalExpense => isTr ? 'Toplam Gider' : 'Total Expense';
  String get balance => isTr ? 'Bakiye' : 'Balance';
  String get categoryBreakdown =>
      isTr ? 'Kategori Dağılımı' : 'Category Breakdown';
}
