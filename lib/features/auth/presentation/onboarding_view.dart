// lib/features/auth/presentation/onboarding_view.dart
import '../../../core/utils/responsive_helper.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../../../core/theme/app_colors.dart';
import '../data/auth_provider.dart';
import '../../wallet/data/wallet_provider.dart';
import '../../../l10n/app_localizations.dart';

class OnboardingView extends ConsumerStatefulWidget {
  const OnboardingView({super.key});

  @override
  ConsumerState<OnboardingView> createState() => _OnboardingViewState();
}

class _OnboardingViewState extends ConsumerState<OnboardingView> {
  final PageController _pageController = PageController();
  int _currentPage = 0;

  final _accountNameController = TextEditingController();
  final _initialBalanceController = TextEditingController(text: '0.0');

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
    final l = AppLocalizations.of(context)!;

    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Column(
          children: [
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
                  _buildWelcomePage(l),
                  _buildCurrencyPage(l),
                  _buildAccountPage(l),
                ],
              ),
            ),

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
                      child: Text(l.backButton),
                    ),
                  const Spacer(),
                  ElevatedButton(
                    onPressed: _currentPage == 2
                        ? () => _completeOnboarding(l)
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
                      _currentPage == 2 ? l.startButton : l.continueButton,
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

  Widget _buildWelcomePage(AppLocalizations l) {
    final responsive = ResponsiveHelper(context);

    return SingleChildScrollView(
      padding: EdgeInsets.all(responsive.paddingL),
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
            l.welcomeTitle.replaceAll('\\n', '\n'),
            style: TextStyle(
              fontSize: responsive.titleFontSize,
              fontWeight: FontWeight.bold,
              color: AppColors.textPrimary,
            ),
            textAlign: TextAlign.center,
          ),
          SizedBox(height: responsive.hp(2)),
          Text(
            l.welcomeSubtitle,
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
            l.manageWallets,
            l.manageWalletsDesc,
          ),
          SizedBox(height: responsive.hp(2)),
          _buildFeatureItem(
            Icons.trending_up,
            l.analyzeSpending,
            l.analyzeSpendingDesc,
          ),
          SizedBox(height: responsive.hp(2)),
          _buildFeatureItem(Icons.people_outline, l.debtBook, l.debtBookDesc),
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

  Widget _buildCurrencyPage(AppLocalizations l) {
    final currencies = [
      {'code': 'TRY', 'name': l.turkishLira, 'symbol': '₺'},
      {'code': 'USD', 'name': l.usDollar, 'symbol': '\$'},
      {'code': 'EUR', 'name': l.euro, 'symbol': '€'},
      {'code': 'GBP', 'name': l.britishPound, 'symbol': '£'},
    ];

    return Padding(
      padding: const EdgeInsets.all(32),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const SizedBox(height: 32),
          Text(
            l.selectCurrency,
            style: const TextStyle(fontSize: 28, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 8),
          Text(
            l.selectCurrencyDesc,
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

  Widget _buildAccountPage(AppLocalizations l) {
    final accountTypes = [
      {'type': 'cash', 'name': l.cashType, 'icon': Icons.payments},
      {'type': 'bank', 'name': l.bankAccount, 'icon': Icons.account_balance},
      {
        'type': 'credit_card',
        'name': l.creditCardType,
        'icon': Icons.credit_card,
      },
      {'type': 'gold', 'name': l.investmentType, 'icon': Icons.diamond},
    ];

    return SingleChildScrollView(
      padding: const EdgeInsets.all(32),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const SizedBox(height: 32),
          Text(
            l.createFirstWallet,
            style: const TextStyle(fontSize: 28, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 8),
          Text(
            l.createWalletDesc,
            style: TextStyle(fontSize: 16, color: Colors.grey[600]),
          ),
          const SizedBox(height: 32),

          TextField(
            controller: _accountNameController,
            decoration: InputDecoration(
              labelText: l.walletName,
              hintText: l.walletNameHint,
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              prefixIcon: const Icon(Icons.account_balance_wallet),
            ),
          ),

          const SizedBox(height: 24),

          Text(
            l.walletType,
            style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
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

          TextField(
            controller: _initialBalanceController,
            keyboardType: const TextInputType.numberWithOptions(decimal: true),
            decoration: InputDecoration(
              labelText: l.initialBalanceOptional,
              hintText: '0.00',
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
                    l.initialBalanceHint,
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

  void _completeOnboarding(AppLocalizations l) async {
    if (_accountNameController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(l.enterWalletName),
          backgroundColor: AppColors.error,
        ),
      );
      return;
    }

    final initialBalance =
        double.tryParse(_initialBalanceController.text.trim()) ?? 0.0;

    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => const Center(child: CircularProgressIndicator()),
    );

    try {
      final user = Supabase.instance.client.auth.currentUser;

      if (user == null) {
        throw Exception('User session not found');
      }

      final walletController = ref.read(walletControllerProvider);
      final accountCreated = await walletController.createAccount(
        name: _accountNameController.text,
        type: _selectedAccountType,
        initialBalance: initialBalance,
      );

      if (!accountCreated) {
        throw Exception('Could not create wallet');
      }

      final walletRepo = ref.read(walletRepositoryProvider);
      await walletRepo.createDefaultCategories(user.id);

      final authController = ref.read(authControllerProvider);
      final onboardingCompleted = await authController.completeOnboarding();

      if (!onboardingCompleted) {
        throw Exception('Could not complete onboarding');
      }

      if (mounted) Navigator.pop(context);
      if (mounted) context.go('/home');
    } catch (e) {
      if (mounted) Navigator.pop(context);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('${l.error}: $e'),
            backgroundColor: AppColors.error,
            duration: const Duration(seconds: 5),
          ),
        );
      }
    }
  }
}
