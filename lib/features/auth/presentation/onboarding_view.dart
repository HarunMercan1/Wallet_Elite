// lib/features/auth/presentation/onboarding_view.dart
import '../../../core/utils/responsive_helper.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../../../core/theme/app_colors.dart';
import '../data/auth_provider.dart';
import '../../wallet/data/wallet_provider.dart';

class OnboardingView extends ConsumerStatefulWidget {
  const OnboardingView({super.key});

  @override
  ConsumerState<OnboardingView> createState() => _OnboardingViewState();
}

class _OnboardingViewState extends ConsumerState<OnboardingView> {
  final PageController _pageController = PageController();
  int _currentPage = 0;

  // Form kontrolörleri
  final _accountNameController = TextEditingController();
  final _initialBalanceController = TextEditingController(text: '0.0');

  // Seçimler
  String _selectedCurrency = 'TRY';
  String _selectedAccountType = 'cash';

  @override
  void dispose() {
    _pageController.dispose();
    _accountNameController.dispose();
    _initialBalanceController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Column(
          children: [
            // Progress Bar
            LinearProgressIndicator(
              value: (_currentPage + 1) / 3,
              backgroundColor: Colors.grey[200],
              valueColor: const AlwaysStoppedAnimation<Color>(
                AppColors.primary,
              ),
            ),

            Expanded(
              child: PageView(
                controller: _pageController,
                physics: const NeverScrollableScrollPhysics(),
                onPageChanged: (page) {
                  setState(() => _currentPage = page);
                },
                children: [
                  _buildWelcomePage(),
                  _buildCurrencyPage(),
                  _buildAccountPage(),
                ],
              ),
            ),

            // Butonlar
            Padding(
              padding: const EdgeInsets.all(24),
              child: Row(
                children: [
                  if (_currentPage > 0)
                    TextButton(
                      onPressed: () {
                        _pageController.previousPage(
                          duration: const Duration(milliseconds: 300),
                          curve: Curves.easeInOut,
                        );
                      },
                      child: const Text('Geri'),
                    ),
                  const Spacer(),
                  ElevatedButton(
                    onPressed: _currentPage == 2
                        ? _completeOnboarding
                        : _nextPage,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.primary,
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(
                        horizontal: 48,
                        vertical: 16,
                      ),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    child: Text(
                      _currentPage == 2 ? 'Başla' : 'Devam',
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  /// Hoş geldin sayfası
  /// Hoş geldin sayfası
  /// Hoş geldin sayfası
  Widget _buildWelcomePage() {
    final responsive = ResponsiveHelper(context);

    return SingleChildScrollView(
      padding: EdgeInsets.all(responsive.horizontalPadding),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          SizedBox(height: responsive.hp(4)),
          Icon(
            Icons.account_balance_wallet_rounded,
            size: responsive.largeIconSize,
            color: AppColors.accent,
          ),
          SizedBox(height: responsive.hp(3)),
          Text(
            'Wallet Elite\'e\nHoş Geldin! 👋',
            style: TextStyle(
              fontSize: responsive.titleFontSize,
              fontWeight: FontWeight.bold,
              color: AppColors.textPrimary,
            ),
            textAlign: TextAlign.center,
          ),
          SizedBox(height: responsive.hp(2)),
          Text(
            'Finansal özgürlüğüne giden yolculuğa başlamak için birkaç basit adım kaldı.',
            style: TextStyle(
              fontSize: responsive.bodyFontSize,
              color: Colors.grey[600],
              height: 1.5,
            ),
            textAlign: TextAlign.center,
          ),
          SizedBox(height: responsive.hp(5)),
          _buildFeatureItem(
            Icons.account_balance_wallet,
            'Cüzdanlarını Yönet',
            'Tüm hesaplarını tek yerden takip et',
          ),
          SizedBox(height: responsive.hp(2)),
          _buildFeatureItem(
            Icons.trending_up,
            'Harcamalarını Analiz Et',
            'Nereye para gittiğini gör',
          ),
          SizedBox(height: responsive.hp(2)),
          _buildFeatureItem(
            Icons.people_outline,
            'Borç Defteri',
            'Alacak ve borçlarını takip et',
          ),
          SizedBox(height: responsive.hp(4)),
        ],
      ),
    );
  }

  Widget _buildFeatureItem(IconData icon, String title, String subtitle) {
    return Row(
      children: [
        Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: AppColors.primary.withOpacity(0.1),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Icon(icon, color: AppColors.primary),
        ),
        const SizedBox(width: 16),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                ),
              ),
              Text(
                subtitle,
                style: TextStyle(fontSize: 14, color: Colors.grey[600]),
              ),
            ],
          ),
        ),
      ],
    );
  }

  /// Para birimi seçim sayfası
  Widget _buildCurrencyPage() {
    final currencies = [
      {'code': 'TRY', 'name': 'Türk Lirası', 'symbol': '₺'},
      {'code': 'USD', 'name': 'Amerikan Doları', 'symbol': '\$'},
      {'code': 'EUR', 'name': 'Euro', 'symbol': '€'},
      {'code': 'GBP', 'name': 'İngiliz Sterlini', 'symbol': '£'},
    ];

    return Padding(
      padding: const EdgeInsets.all(32),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const SizedBox(height: 32),
          const Text(
            'Para Birimi Seç',
            style: TextStyle(fontSize: 28, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 8),
          Text(
            'Tüm hesaplarında kullanacağın para birimini seç',
            style: TextStyle(fontSize: 16, color: Colors.grey[600]),
          ),
          const SizedBox(height: 32),
          Expanded(
            child: ListView.builder(
              itemCount: currencies.length,
              itemBuilder: (context, index) {
                final currency = currencies[index];
                final isSelected = _selectedCurrency == currency['code'];

                return Container(
                  margin: const EdgeInsets.only(bottom: 12),
                  decoration: BoxDecoration(
                    border: Border.all(
                      color: isSelected ? AppColors.primary : Colors.grey[300]!,
                      width: 2,
                    ),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: ListTile(
                    contentPadding: const EdgeInsets.all(16),
                    leading: Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: isSelected
                            ? AppColors.primary
                            : Colors.grey[200],
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Text(
                        currency['symbol']!,
                        style: TextStyle(
                          fontSize: 24,
                          fontWeight: FontWeight.bold,
                          color: isSelected ? Colors.white : Colors.black87,
                        ),
                      ),
                    ),
                    title: Text(
                      currency['name']!,
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    subtitle: Text(currency['code']!),
                    trailing: isSelected
                        ? const Icon(
                            Icons.check_circle,
                            color: AppColors.primary,
                          )
                        : null,
                    onTap: () {
                      setState(() => _selectedCurrency = currency['code']!);
                    },
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  /// İlk cüzdan oluşturma sayfası
  Widget _buildAccountPage() {
    final accountTypes = [
      {'type': 'cash', 'name': 'Nakit', 'icon': Icons.payments},
      {'type': 'bank', 'name': 'Banka Hesabı', 'icon': Icons.account_balance},
      {'type': 'credit_card', 'name': 'Kredi Kartı', 'icon': Icons.credit_card},
      {'type': 'gold', 'name': 'Altın/Yatırım', 'icon': Icons.diamond},
    ];

    return SingleChildScrollView(
      padding: const EdgeInsets.all(32),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const SizedBox(height: 32),
          const Text(
            'İlk Cüzdanını Oluştur',
            style: TextStyle(fontSize: 28, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 8),
          Text(
            'Paranı takip etmeye başlamak için bir cüzdan oluştur',
            style: TextStyle(fontSize: 16, color: Colors.grey[600]),
          ),
          const SizedBox(height: 32),

          // Cüzdan Adı
          TextField(
            controller: _accountNameController,
            decoration: InputDecoration(
              labelText: 'Cüzdan Adı',
              hintText: 'örn: Nakit Param',
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              prefixIcon: const Icon(Icons.account_balance_wallet),
            ),
          ),

          const SizedBox(height: 24),

          // Cüzdan Tipi
          const Text(
            'Cüzdan Tipi',
            style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 12),
          GridView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 2,
              crossAxisSpacing: 12,
              mainAxisSpacing: 12,
              childAspectRatio: 1.5,
            ),
            itemCount: accountTypes.length,
            itemBuilder: (context, index) {
              final type = accountTypes[index];
              final isSelected = _selectedAccountType == type['type'];

              return GestureDetector(
                onTap: () {
                  setState(() => _selectedAccountType = type['type'] as String);
                },
                child: Container(
                  decoration: BoxDecoration(
                    color: isSelected ? AppColors.primary : Colors.grey[100],
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(
                      color: isSelected ? AppColors.primary : Colors.grey[300]!,
                      width: 2,
                    ),
                  ),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        type['icon'] as IconData,
                        size: 32,
                        color: isSelected ? Colors.white : Colors.grey[700],
                      ),
                      const SizedBox(height: 8),
                      Text(
                        type['name'] as String,
                        style: TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w600,
                          color: isSelected ? Colors.white : Colors.grey[700],
                        ),
                      ),
                    ],
                  ),
                ),
              );
            },
          ),

          const SizedBox(height: 24),

          // Başlangıç Bakiyesi
          TextField(
            controller: _initialBalanceController,
            keyboardType: const TextInputType.numberWithOptions(
              decimal: true,
            ), // ← Ondalık sayı
            decoration: InputDecoration(
              labelText: 'Başlangıç Bakiyesi (Opsiyonel)',
              hintText: '0.00', // ← 0 yerine 0.00
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              prefixText: '₺ ',
              prefixIcon: const Icon(Icons.attach_money),
            ),
          ),

          const SizedBox(height: 16),

          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: AppColors.info.withOpacity(0.1),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Row(
              children: [
                const Icon(Icons.info_outline, color: AppColors.info),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    'Şu anda cüzdanında ne kadar para olduğunu gir. Sonra istediğin zaman değiştirebilirsin.',
                    style: TextStyle(fontSize: 14, color: Colors.grey[700]),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  void _nextPage() {
    _pageController.nextPage(
      duration: const Duration(milliseconds: 300),
      curve: Curves.easeInOut,
    );
  }

  void _completeOnboarding() async {
    // Validasyon
    if (_accountNameController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Lütfen cüzdan adı girin'),
          backgroundColor: AppColors.error,
        ),
      );
      return;
    }

    final initialBalance =
        double.tryParse(_initialBalanceController.text.trim()) ?? 0.0;

    // Loading göster
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => const Center(child: CircularProgressIndicator()),
    );

    try {
      // ÖNCE KULLANICI ID'Sİ AL - Doğrudan Supabase'den al (StreamProvider gecikebilir)
      final user = Supabase.instance.client.auth.currentUser;

      if (user == null) {
        throw Exception('Kullanıcı oturumu bulunamadı');
      }

      print('👤 Kullanıcı ID: ${user.id}');
      print('💼 Cüzdan: ${_accountNameController.text}');
      print('💰 Bakiye: $initialBalance');

      // 1. İlk cüzdanı oluştur
      final walletController = ref.read(walletControllerProvider);
      final accountCreated = await walletController.createAccount(
        name: _accountNameController.text,
        type: _selectedAccountType,
        initialBalance: initialBalance,
      );

      if (!accountCreated) {
        throw Exception('Cüzdan oluşturulamadı');
      }

      print('✅ Cüzdan başarıyla oluşturuldu');

      // 2. Varsayılan kategorileri oluştur (user_id ile - schema'ya uygun)
      final walletRepo = ref.read(walletRepositoryProvider);
      await walletRepo.createDefaultCategories(user.id);

      print('✅ Varsayılan kategoriler oluşturuldu');

      // 3. Onboarding'i tamamla
      final authController = ref.read(authControllerProvider);
      final onboardingCompleted = await authController.completeOnboarding();

      if (!onboardingCompleted) {
        throw Exception('Onboarding tamamlanamadı');
      }

      print('✅ Onboarding tamamlandı');

      // Loading'i kapat
      if (mounted) Navigator.pop(context);

      // Home'a yönlendir
      if (mounted) context.go('/home');
    } catch (e) {
      print('❌ HATA: $e');

      // Loading'i kapat
      if (mounted) Navigator.pop(context);

      // Hata göster
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Hata: $e'),
            backgroundColor: AppColors.error,
            duration: const Duration(seconds: 5),
          ),
        );
      }
    }
  }

  Future<void> _createDefaultCategories() async {
    // TODO: Varsayılan kategorileri oluştur
    // Şimdilik Supabase'de zaten var, bu yüzden pass
  }
}
