// lib/features/auth/presentation/onboarding_view.dart
import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/color_theme_provider.dart';
import '../../../core/utils/responsive_helper.dart';
import '../../../l10n/app_localizations.dart';
import '../data/auth_provider.dart';
import '../../wallet/data/wallet_provider.dart';
import '../../settings/data/settings_provider.dart';

class OnboardingView extends ConsumerStatefulWidget {
  const OnboardingView({super.key});

  @override
  ConsumerState<OnboardingView> createState() => _OnboardingViewState();
}

class _OnboardingViewState extends ConsumerState<OnboardingView>
    with TickerProviderStateMixin {
  final PageController _pageController = PageController();
  int _currentPage = 0;
  int _animationKey = 0; // Animasyonları tekrar tetiklemek için

  // Controllers
  final _accountNameController = TextEditingController();
  final _initialBalanceController = TextEditingController(text: '0.0');

  // Selections
  String _selectedLanguage = 'tr';
  String _selectedTheme = 'ocean';
  String _selectedCurrency = 'TRY';
  String _selectedAccountType = 'cash';
  bool _isDarkMode = false;
  bool _isLoading = false;

  @override
  void dispose() {
    _pageController.dispose();
    _accountNameController.dispose();
    _initialBalanceController.dispose();
    super.dispose();
  }

  void _nextPage() {
    if (_currentPage < 5) {
      _pageController.nextPage(
        duration: const Duration(milliseconds: 400),
        curve: Curves.easeInOutCubic,
      );
    }
  }

  void _previousPage() {
    if (_currentPage > 0) {
      _pageController.previousPage(
        duration: const Duration(milliseconds: 400),
        curve: Curves.easeInOutCubic,
      );
    }
  }

  Future<void> _completeOnboarding() async {
    if (_accountNameController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(AppLocalizations.of(context)!.enterWalletName)),
      );
      return;
    }

    setState(() => _isLoading = true);

    final l = AppLocalizations.of(context)!;

    try {
      final authRepo = ref.read(authRepositoryProvider);
      final walletRepo = ref.read(walletRepositoryProvider);
      final user = Supabase.instance.client.auth.currentUser;
      if (user == null) {
        if (mounted) context.go('/auth');
        return;
      }

      // 1. Kullanıcı tercihlerini kaydet
      await authRepo.updateUserPreferences(
        userId: user.id,
        language: _selectedLanguage,
        theme: _selectedTheme,
        currency: _selectedCurrency,
        isDarkMode: _isDarkMode,
      );

      // 2. İlk cüzdanı oluştur (daha önce yarım kalmış bir onboarding'den
      // cüzdan kaldıysa tekrar oluşturma)
      final existingAccounts = await walletRepo.getAccounts(user.id);
      if (existingAccounts.isEmpty) {
        final initialBalance =
            double.tryParse(_initialBalanceController.text) ?? 0.0;
        final newWallet = await walletRepo.createAccount(
          userId: user.id,
          name: _accountNameController.text,
          type: _selectedAccountType,
          currency: _selectedCurrency,
          initialBalance: initialBalance,
        );
        if (newWallet == null) {
          if (mounted) {
            ScaffoldMessenger.of(
              context,
            ).showSnackBar(SnackBar(content: Text(l.errorOccurred)));
          }
          return;
        }
      }

      // 3. Varsayılan kategorileri oluştur (yoksa)
      final existingCategories = await walletRepo.getCategories(user.id);
      if (existingCategories.isEmpty) {
        await walletRepo.createDefaultCategories(user.id);
      }

      // 4. Onboarding'i tamamlandı olarak işaretle. Bu olmadan router
      // kullanıcıyı tekrar onboarding'e yönlendirir.
      final completed = await authRepo.completeOnboarding(user.id);
      if (!completed) {
        if (mounted) {
          ScaffoldMessenger.of(
            context,
          ).showSnackBar(SnackBar(content: Text(l.errorOccurred)));
        }
        return;
      }
      ref.invalidate(accountsProvider);
      ref.invalidate(categoriesProvider);
      ref.invalidate(incomeCategoriesProvider);
      ref.invalidate(expenseCategoriesProvider);

      // 5. Providerları güncelle
      ref.read(localeProvider.notifier).setLocale(_selectedLanguage);
      ref
          .read(colorSchemeProvider.notifier)
          .setColorScheme(_selectedTheme); // await kaldırıldı (void method)
      ref.read(currencyProvider.notifier).setCurrency(_selectedCurrency);

      if (mounted) {
        context.go('/home');
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('${AppLocalizations.of(context)!.error}: $e')),
        );
      }
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final r = ResponsiveHelper.of(context);
    final colorTheme = ref.watch(currentColorThemeProvider);
    // Dark mode state'den veya sistemden gelebilir ama burada state öncelikli (seçim yapılıyor)
    final isDark = _isDarkMode;

    return Scaffold(
      backgroundColor: isDark ? const Color(0xFF121212) : Colors.white,
      body: SafeArea(
        child: Column(
          children: [
            // Progress indicator
            _buildProgressIndicator(r, colorTheme),

            // Pages
            Expanded(
              child: PageView(
                controller: _pageController,
                physics:
                    const NeverScrollableScrollPhysics(), // Sadece butonlarla geçiş
                onPageChanged: (page) {
                  setState(() {
                    _currentPage = page;
                    _animationKey++;
                  });
                },
                children: [
                  _AnimatedPage(
                    key: ValueKey('welcome_$_animationKey'),
                    child: _buildWelcomePage(r, colorTheme, isDark),
                  ),
                  _AnimatedPage(
                    key: ValueKey('features_$_animationKey'),
                    child: _buildFeaturesPage(r, colorTheme, isDark),
                  ),
                  _AnimatedPage(
                    key: ValueKey('language_$_animationKey'),
                    child: _buildLanguagePage(r, colorTheme, isDark),
                  ),
                  _AnimatedPage(
                    key: ValueKey('theme_$_animationKey'),
                    child: _buildThemePage(r, colorTheme, isDark),
                  ),
                  _AnimatedPage(
                    key: ValueKey('currency_$_animationKey'),
                    child: _buildCurrencyPage(r, colorTheme, isDark),
                  ),
                  _AnimatedPage(
                    key: ValueKey('account_$_animationKey'),
                    child: _buildAccountPage(r, colorTheme, isDark),
                  ),
                ],
              ),
            ),

            // Navigation buttons
            _buildNavigationButtons(r, colorTheme, isDark),
          ],
        ),
      ),
    );
  }

  Widget _buildProgressIndicator(ResponsiveHelper r, ColorTheme colorTheme) {
    return Padding(
      padding: EdgeInsets.symmetric(
        horizontal: r.paddingL,
        vertical: r.paddingS,
      ),
      child: TweenAnimationBuilder<double>(
        tween: Tween(begin: 0.0, end: (_currentPage + 1) / 6),
        duration: const Duration(milliseconds: 500),
        curve: Curves.easeOutCubic,
        builder: (context, value, child) {
          return Container(
            height: r.hp(0.8),
            decoration: BoxDecoration(
              color: colorTheme.primary.withValues(alpha: 0.2),
              borderRadius: BorderRadius.circular(r.hp(0.4)),
            ),
            child: FractionallySizedBox(
              alignment: Alignment.centerLeft,
              widthFactor: value,
              child: Container(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [colorTheme.primary, colorTheme.accent],
                  ),
                  borderRadius: BorderRadius.circular(r.hp(0.4)),
                ),
              ),
            ),
          );
        },
      ),
    );
  }

  // ============ PAGE 1: WELCOME ============
  Widget _buildWelcomePage(
    ResponsiveHelper r,
    ColorTheme colorTheme,
    bool isDark,
  ) {
    final l10n = AppLocalizations.of(context)!;

    return Stack(
      children: [
        // Floating particles
        ...List.generate(
          15,
          (index) => _buildFloatingParticle(r, colorTheme, index),
        ),

        SingleChildScrollView(
          padding: EdgeInsets.all(r.paddingL),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              SizedBox(height: r.hp(6)),

              // Animated logo with bounce
              _SlideInWidget(
                delay: 0,
                direction: SlideDirection.up,
                child: _PulseWidget(
                  child: Container(
                    padding: EdgeInsets.all(r.paddingXL),
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        colors: [colorTheme.primary, colorTheme.accent],
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                      ),
                      shape: BoxShape.circle,
                      boxShadow: [
                        BoxShadow(
                          color: colorTheme.primary.withValues(alpha: 0.4),
                          blurRadius: 30,
                          spreadRadius: 5,
                        ),
                      ],
                    ),
                    child: Icon(
                      Icons.account_balance_wallet_rounded,
                      size: r.hp(10),
                      color: Colors.white,
                    ),
                  ),
                ),
              ),

              SizedBox(height: r.hp(4)),

              // Welcome text
              _SlideInWidget(
                delay: 200,
                direction: SlideDirection.up,
                child: Text(
                  l10n.welcomeTitle.replaceAll('\\n', '\n'),
                  style: TextStyle(
                    fontSize: r.hp(4.5),
                    fontWeight: FontWeight.bold,
                    color: isDark ? Colors.white : Colors.black87,
                  ),
                  textAlign: TextAlign.center,
                ),
              ),

              SizedBox(height: r.hp(1)),

              _SlideInWidget(
                delay: 300,
                direction: SlideDirection.up,
                child: Text(
                  l10n.welcomeSubtitle,
                  style: TextStyle(
                    fontSize: r.fontM,
                    color: isDark ? Colors.white70 : Colors.grey[600],
                    height: 1.5,
                  ),
                  textAlign: TextAlign.center,
                ),
              ),

              SizedBox(height: r.hp(6)),

              // Quick features
              _SlideInWidget(
                delay: 400,
                direction: SlideDirection.left,
                child: _buildQuickFeature(
                  r,
                  colorTheme,
                  isDark,
                  Icons.security,
                  l10n.secureData,
                ),
              ),
              SizedBox(height: r.hp(2)),
              _SlideInWidget(
                delay: 550,
                direction: SlideDirection.left,
                child: _buildQuickFeature(
                  r,
                  colorTheme,
                  isDark,
                  Icons.cloud_sync,
                  l10n.cloudSync,
                ),
              ),
              SizedBox(height: r.hp(2)),
              _SlideInWidget(
                delay: 700,
                direction: SlideDirection.left,
                child: _buildQuickFeature(
                  r,
                  colorTheme,
                  isDark,
                  Icons.insights,
                  l10n.smartInsights,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildFloatingParticle(
    ResponsiveHelper r,
    ColorTheme colorTheme,
    int index,
  ) {
    final random = math.Random(index);
    final size = r.hp(1) + random.nextDouble() * r.hp(2);
    final left = random.nextDouble() * r.wp(90);
    final top = random.nextDouble() * r.hp(70);

    return Positioned(
      left: left,
      top: top,
      child: _FloatingParticle(
        size: size,
        color: colorTheme.primary,
        delay: index * 200,
      ),
    );
  }

  Widget _buildQuickFeature(
    ResponsiveHelper r,
    ColorTheme colorTheme,
    bool isDark,
    IconData icon,
    String text,
  ) {
    return Container(
      padding: EdgeInsets.all(r.paddingM),
      decoration: BoxDecoration(
        color: isDark ? Colors.white.withValues(alpha: 0.05) : Colors.grey[50],
        borderRadius: r.borderRadiusM,
        border: Border.all(color: colorTheme.primary.withValues(alpha: 0.2)),
      ),
      child: Row(
        children: [
          Container(
            padding: EdgeInsets.all(r.paddingS),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [colorTheme.primary, colorTheme.accent],
              ),
              borderRadius: r.borderRadiusS,
            ),
            child: Icon(icon, color: Colors.white, size: r.iconM),
          ),
          SizedBox(width: r.spaceM),
          Expanded(
            child: Text(
              text,
              style: TextStyle(
                fontSize: r.fontS,
                color: isDark ? Colors.white : Colors.black87,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
        ],
      ),
    );
  }

  // ============ PAGE 2: FEATURES ============
  Widget _buildFeaturesPage(
    ResponsiveHelper r,
    ColorTheme colorTheme,
    bool isDark,
  ) {
    final l10n = AppLocalizations.of(context)!;

    final features = [
      {
        'icon': Icons.account_balance_wallet,
        'title': l10n.wallet,
        'desc': l10n.manageWalletsDesc,
        'color': colorTheme.primary,
      },
      {
        'icon': Icons.pie_chart,
        'title': l10n.budgetTracking,
        'desc': l10n.budgetTrackingDesc,
        'color': colorTheme.accent,
      },
      {
        'icon': Icons.repeat,
        'title': l10n.recurringTransactions,
        'desc': l10n.recurringTransactionsDesc,
        'color': colorTheme.success,
      },
      {
        'icon': Icons.people,
        'title': l10n.debtBook,
        'desc': l10n.debtBookDesc,
        'color': Colors.orange,
      },
      {
        'icon': Icons.analytics,
        'title': l10n.statisticsTitle,
        'desc': l10n.analyzeSpendingDesc,
        'color': Colors.purple,
      },
    ];

    return SingleChildScrollView(
      padding: EdgeInsets.all(r.paddingL),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(height: r.hp(2)),

          _SlideInWidget(
            delay: 0,
            direction: SlideDirection.down,
            child: Text(
              l10n.discoverFeatures,
              style: TextStyle(
                fontSize: r.hp(3.5),
                fontWeight: FontWeight.bold,
                color: isDark ? Colors.white : Colors.black87,
              ),
            ),
          ),

          SizedBox(height: r.hp(1)),

          _SlideInWidget(
            delay: 100,
            direction: SlideDirection.down,
            child: Text(
              l10n.discoverFeaturesDesc,
              style: TextStyle(
                fontSize: r.fontM,
                color: isDark ? Colors.white70 : Colors.grey[600],
              ),
            ),
          ),

          SizedBox(height: r.hp(3)),

          ...features.asMap().entries.map((entry) {
            final index = entry.key;
            final feature = entry.value;

            return _SlideInWidget(
              delay: 200 + (index * 150),
              direction: SlideDirection.left,
              child: _buildFeatureCard(r, isDark, feature),
            );
          }),
        ],
      ),
    );
  }

  Widget _buildFeatureCard(
    ResponsiveHelper r,
    bool isDark,
    Map<String, dynamic> feature,
  ) {
    final color = feature['color'] as Color;

    return Container(
      margin: EdgeInsets.only(bottom: r.hp(2)),
      padding: EdgeInsets.all(r.paddingM),
      decoration: BoxDecoration(
        color: isDark ? Colors.white.withValues(alpha: 0.05) : Colors.white,
        borderRadius: r.borderRadiusM,
        border: Border.all(color: color.withValues(alpha: 0.3)),
        boxShadow: [
          BoxShadow(
            color: color.withValues(alpha: 0.1),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Row(
        children: [
          Container(
            padding: EdgeInsets.all(r.paddingM),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [color, color.withValues(alpha: 0.7)],
              ),
              borderRadius: r.borderRadiusS,
            ),
            child: Icon(
              feature['icon'] as IconData,
              color: Colors.white,
              size: r.iconL,
            ),
          ),
          SizedBox(width: r.spaceM),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  feature['title'] as String,
                  style: TextStyle(
                    fontSize: r.fontM,
                    fontWeight: FontWeight.bold,
                    color: isDark ? Colors.white : Colors.black87,
                  ),
                ),
                SizedBox(height: r.hp(0.5)),
                Text(
                  feature['desc'] as String,
                  style: TextStyle(
                    fontSize: r.fontXS,
                    color: isDark ? Colors.white60 : Colors.grey[600],
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // ============ PAGE 3: LANGUAGE ============
  Widget _buildLanguagePage(
    ResponsiveHelper r,
    ColorTheme colorTheme,
    bool isDark,
  ) {
    final l10n = AppLocalizations.of(context)!;

    final languages = [
      {'code': 'tr', 'name': 'Türkçe', 'flag': '🇹🇷'},
      {'code': 'en', 'name': 'English', 'flag': '🇬🇧'},
      {'code': 'de', 'name': 'Deutsch', 'flag': '🇩🇪'},
      {'code': 'es', 'name': 'Español', 'flag': '🇪🇸'},
      {'code': 'fr', 'name': 'Français', 'flag': '🇫🇷'},
      {'code': 'it', 'name': 'Italiano', 'flag': '🇮🇹'},
      {'code': 'pt', 'name': 'Português', 'flag': '🇵🇹'},
      {'code': 'ru', 'name': 'Русский', 'flag': '🇷🇺'},
      {'code': 'ar', 'name': 'العربية', 'flag': '🇸🇦'},
      {'code': 'ja', 'name': '日本語', 'flag': '🇯🇵'},
      {'code': 'ko', 'name': '한국어', 'flag': '🇰🇷'},
      {'code': 'zh', 'name': '中文', 'flag': '🇨🇳'},
    ];

    return Padding(
      padding: EdgeInsets.all(r.paddingL),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(height: r.hp(2)),

          _SlideInWidget(
            delay: 0,
            direction: SlideDirection.down,
            child: Text(
              l10n.selectLanguage, // "Dil Seçin"
              style: TextStyle(
                fontSize: r.hp(3.5),
                fontWeight: FontWeight.bold,
                color: isDark ? Colors.white : Colors.black87,
              ),
            ),
          ),

          SizedBox(height: r.hp(1)),

          _SlideInWidget(
            delay: 100,
            direction: SlideDirection.down,
            child: Text(
              l10n.selectLanguageDesc,
              style: TextStyle(
                fontSize: r.fontM,
                color: isDark ? Colors.white70 : Colors.grey[600],
              ),
            ),
          ),

          SizedBox(height: r.hp(3)),

          Expanded(
            child: GridView.builder(
              gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 3,
                crossAxisSpacing: r.spaceS,
                mainAxisSpacing: r.spaceS,
                childAspectRatio: 1.0,
              ),
              itemCount: languages.length,
              itemBuilder: (context, index) {
                final lang = languages[index];
                final isSelected = _selectedLanguage == lang['code'];

                return _ScaleInWidget(
                  delay: 200 + (index * 60),
                  child: GestureDetector(
                    onTap: () {
                      setState(() => _selectedLanguage = lang['code']!);
                      // Hemen uygula ki kullanıcı görsün
                      ref
                          .read(localeProvider.notifier)
                          .setLocale(lang['code']!);
                    },
                    child: AnimatedContainer(
                      duration: const Duration(milliseconds: 200),
                      decoration: BoxDecoration(
                        color: isSelected
                            ? colorTheme.primary.withValues(alpha: 0.15)
                            : (isDark
                                  ? Colors.white.withValues(alpha: 0.05)
                                  : Colors.grey[100]),
                        borderRadius: r.borderRadiusM,
                        border: Border.all(
                          color: isSelected
                              ? colorTheme.primary
                              : Colors.transparent,
                          width: 2,
                        ),
                      ),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text(
                            lang['flag']!,
                            style: TextStyle(fontSize: r.hp(3.5)),
                          ),
                          SizedBox(height: r.hp(0.5)),
                          Text(
                            lang['name']!,
                            style: TextStyle(
                              fontSize: r.fontXS,
                              fontWeight: isSelected
                                  ? FontWeight.bold
                                  : FontWeight.normal,
                              color: isSelected
                                  ? colorTheme.primary
                                  : (isDark ? Colors.white70 : Colors.black87),
                            ),
                            textAlign: TextAlign.center,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ],
                      ),
                    ),
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  // ============ PAGE 4: THEME ============
  Widget _buildThemePage(
    ResponsiveHelper r,
    ColorTheme colorTheme,
    bool isDark,
  ) {
    final l10n = AppLocalizations.of(context)!;

    final themes = [
      {
        'id': 'ocean',
        'name': l10n.themeOcean,
        'primary': const Color(0xFF2196F3),
        'accent': const Color(0xFF00BCD4),
        'icon': Icons.water,
      },
      {
        'id': 'sunset',
        'name': l10n.themeSunset,
        'primary': const Color(0xFFFF6B35),
        'accent': const Color(0xFFFFD93D),
        'icon': Icons.wb_twilight,
      },
      {
        'id': 'forest',
        'name': l10n.themeForest,
        'primary': const Color(0xFF4CAF50),
        'accent': const Color(0xFF8BC34A),
        'icon': Icons.park,
      },
      {
        'id': 'lavender',
        'name': l10n.themeLavender,
        'primary': const Color(0xFF9C27B0),
        'accent': const Color(0xFFE91E63),
        'icon': Icons.local_florist,
      },
      {
        'id': 'midnight',
        'name': l10n.themeMidnight,
        'primary': const Color(0xFF3F51B5),
        'accent': const Color(0xFF7C4DFF),
        'icon': Icons.nightlight,
      },
      {
        'id': 'rose',
        'name': l10n.themeRose,
        'primary': const Color(0xFFE91E63),
        'accent': const Color(0xFFFF4081),
        'icon': Icons.favorite,
      },
    ];

    return Padding(
      padding: EdgeInsets.all(r.paddingL),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(height: r.hp(2)),

          _SlideInWidget(
            delay: 0,
            direction: SlideDirection.down,
            child: Text(
              l10n.selectTheme,
              style: TextStyle(
                fontSize: r.hp(3.5),
                fontWeight: FontWeight.bold,
                color: isDark ? Colors.white : Colors.black87,
              ),
            ),
          ),

          SizedBox(height: r.hp(1)),

          _SlideInWidget(
            delay: 100,
            direction: SlideDirection.down,
            child: Text(
              l10n.selectThemeDesc,
              style: TextStyle(
                fontSize: r.fontM,
                color: isDark ? Colors.white70 : Colors.grey[600],
              ),
            ),
          ),

          SizedBox(height: r.hp(3)),

          Expanded(
            child: GridView.builder(
              gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 2,
                crossAxisSpacing: r.spaceM,
                mainAxisSpacing: r.spaceM,
                childAspectRatio: 1.2,
              ),
              itemCount: themes.length,
              itemBuilder: (context, index) {
                final theme = themes[index];
                final isSelected = _selectedTheme == theme['id'];

                return _ScaleInWidget(
                  delay: 200 + (index * 80),
                  child: GestureDetector(
                    onTap: () {
                      setState(() => _selectedTheme = theme['id'] as String);
                      ref
                          .read(colorSchemeProvider.notifier)
                          .setColorScheme(theme['id'] as String);
                    },
                    child: AnimatedContainer(
                      duration: const Duration(milliseconds: 200),
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          colors: [
                            theme['primary'] as Color,
                            theme['accent'] as Color,
                          ],
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                        ),
                        borderRadius: r.borderRadiusM,
                        border: Border.all(
                          color: isSelected ? Colors.white : Colors.transparent,
                          width: 3,
                        ),
                        boxShadow: isSelected
                            ? [
                                BoxShadow(
                                  color: (theme['primary'] as Color).withValues(
                                    alpha: 0.5,
                                  ),
                                  blurRadius: 12,
                                  offset: const Offset(0, 4),
                                ),
                              ]
                            : [],
                      ),
                      child: Stack(
                        children: [
                          Center(
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Icon(
                                  theme['icon'] as IconData,
                                  color: Colors.white,
                                  size: r.iconL,
                                ),
                                SizedBox(height: r.hp(1)),
                                Text(
                                  theme['name'] as String,
                                  style: TextStyle(
                                    fontSize: r.fontM,
                                    fontWeight: FontWeight.bold,
                                    color: Colors.white,
                                  ),
                                ),
                              ],
                            ),
                          ),
                          if (isSelected)
                            Positioned(
                              top: 8,
                              right: 8,
                              child: Icon(
                                Icons.check_circle,
                                color: Colors.white,
                                size: r.iconM,
                              ),
                            ),
                        ],
                      ),
                    ),
                  ),
                );
              },
            ),
          ),

          SizedBox(height: r.hp(2)),

          // Dark mode toggle
          _SlideInWidget(
            delay: 700,
            direction: SlideDirection.up,
            child: GestureDetector(
              onTap: () {
                setState(() => _isDarkMode = !_isDarkMode);
                // Notifier'a bildirmek gerekebilir ama şimdilik local state yeterli çünkü view rebuild oluyor
              },
              child: Container(
                padding: EdgeInsets.all(r.paddingM),
                decoration: BoxDecoration(
                  color: isDark
                      ? Colors.white.withValues(alpha: 0.1)
                      : Colors.grey[100],
                  borderRadius: r.borderRadiusM,
                  border: Border.all(
                    color: _isDarkMode
                        ? colorTheme.primary
                        : Colors.transparent,
                  ),
                ),
                child: Row(
                  children: [
                    Icon(
                      _isDarkMode ? Icons.dark_mode : Icons.light_mode,
                      color: _isDarkMode ? colorTheme.primary : Colors.orange,
                      size: r.iconM,
                    ),
                    SizedBox(width: r.spaceM),
                    Text(
                      l10n.darkMode,
                      style: TextStyle(
                        fontSize: r.fontM,
                        fontWeight: FontWeight.w600,
                        color: isDark ? Colors.white : Colors.black87,
                      ),
                    ),
                    const Spacer(),
                    Switch(
                      value: _isDarkMode,
                      onChanged: (val) => setState(() => _isDarkMode = val),
                      activeColor: colorTheme.primary,
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  // ============ PAGE 5: CURRENCY ============
  Widget _buildCurrencyPage(
    ResponsiveHelper r,
    ColorTheme colorTheme,
    bool isDark,
  ) {
    final l10n = AppLocalizations.of(context)!;

    final currencies = [
      {
        'code': 'TRY',
        'name': l10n.turkishLira,
        'symbol': '₺',
        'color': Colors.red,
      },
      {
        'code': 'USD',
        'name': l10n.usDollar,
        'symbol': r'$',
        'color': Colors.green,
      },
      {'code': 'EUR', 'name': l10n.euro, 'symbol': '€', 'color': Colors.blue},
      {
        'code': 'GBP',
        'name': l10n.britishPound,
        'symbol': '£',
        'color': Colors.purple,
      },
      {
        'code': 'JPY',
        'name': l10n.japaneseYen,
        'symbol': '¥',
        'color': Colors.orange,
      },
      {
        'code': 'RUB',
        'name': l10n.russianRuble,
        'symbol': '₽',
        'color': Colors.teal,
      },
    ];

    return Padding(
      padding: EdgeInsets.all(r.paddingL),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(height: r.hp(2)),

          _SlideInWidget(
            delay: 0,
            direction: SlideDirection.down,
            child: Text(
              l10n.selectCurrency,
              style: TextStyle(
                fontSize: r.hp(3.5),
                fontWeight: FontWeight.bold,
                color: isDark ? Colors.white : Colors.black87,
              ),
            ),
          ),

          SizedBox(height: r.hp(1)),

          _SlideInWidget(
            delay: 100,
            direction: SlideDirection.down,
            child: Text(
              l10n.selectCurrencyDesc,
              style: TextStyle(
                fontSize: r.fontM,
                color: isDark ? Colors.white70 : Colors.grey[600],
              ),
            ),
          ),

          SizedBox(height: r.hp(3)),

          Expanded(
            child: ListView.builder(
              itemCount: currencies.length,
              itemBuilder: (context, index) {
                final currency = currencies[index];
                final isSelected = _selectedCurrency == currency['code'];
                final color = currency['color'] as Color;

                return _SlideInWidget(
                  delay: 200 + (index * 80),
                  direction: SlideDirection.right,
                  child: GestureDetector(
                    onTap: () => setState(
                      () => _selectedCurrency = currency['code'] as String,
                    ),
                    child: AnimatedContainer(
                      duration: const Duration(milliseconds: 200),
                      margin: EdgeInsets.only(bottom: r.hp(1.5)),
                      padding: EdgeInsets.all(r.paddingM),
                      decoration: BoxDecoration(
                        color: isSelected
                            ? color.withValues(alpha: 0.1)
                            : (isDark
                                  ? Colors.white.withValues(alpha: 0.05)
                                  : Colors.white),
                        borderRadius: r.borderRadiusM,
                        border: Border.all(
                          color: isSelected
                              ? color
                              : color.withValues(alpha: 0.3),
                          width: isSelected ? 2 : 1,
                        ),
                        boxShadow: isSelected
                            ? [
                                BoxShadow(
                                  color: color.withValues(alpha: 0.2),
                                  blurRadius: 8,
                                  offset: const Offset(0, 2),
                                ),
                              ]
                            : [],
                      ),
                      child: Row(
                        children: [
                          Container(
                            width: r.hp(6),
                            height: r.hp(6),
                            decoration: BoxDecoration(
                              gradient: LinearGradient(
                                colors: [color, color.withValues(alpha: 0.7)],
                              ),
                              borderRadius: r.borderRadiusS,
                            ),
                            child: Center(
                              child: Text(
                                currency['symbol'] as String,
                                style: TextStyle(
                                  fontSize: r.hp(2.5),
                                  fontWeight: FontWeight.bold,
                                  color: Colors.white,
                                ),
                              ),
                            ),
                          ),
                          SizedBox(width: r.spaceM),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  currency['name'] as String,
                                  style: TextStyle(
                                    fontSize: r.fontM,
                                    fontWeight: FontWeight.w600,
                                    color: isDark
                                        ? Colors.white
                                        : Colors.black87,
                                  ),
                                ),
                                Text(
                                  currency['code'] as String,
                                  style: TextStyle(
                                    fontSize: r.fontXS,
                                    color: isDark
                                        ? Colors.white60
                                        : Colors.grey[600],
                                  ),
                                ),
                              ],
                            ),
                          ),
                          if (isSelected)
                            Icon(
                              Icons.check_circle,
                              color: color,
                              size: r.iconM,
                            ),
                        ],
                      ),
                    ),
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  // ============ PAGE 6: ACCOUNT ============
  Widget _buildAccountPage(
    ResponsiveHelper r,
    ColorTheme colorTheme,
    bool isDark,
  ) {
    final l10n = AppLocalizations.of(context)!;

    final accountTypes = [
      {'id': 'cash', 'name': l10n.cashType, 'icon': Icons.money},
      {'id': 'bank', 'name': l10n.bankAccount, 'icon': Icons.account_balance},
      {
        'id': 'credit_card',
        'name': l10n.creditCardType,
        'icon': Icons.credit_card,
      },
      {
        'id': 'investment',
        'name': l10n.investmentType,
        'icon': Icons.trending_up,
      },
    ];

    return SingleChildScrollView(
      padding: EdgeInsets.all(r.paddingL),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(height: r.hp(2)),

          _SlideInWidget(
            delay: 0,
            direction: SlideDirection.down,
            child: Text(
              l10n.createFirstWallet,
              style: TextStyle(
                fontSize: r.hp(3.5),
                fontWeight: FontWeight.bold,
                color: isDark ? Colors.white : Colors.black87,
              ),
            ),
          ),

          SizedBox(height: r.hp(1)),

          _SlideInWidget(
            delay: 100,
            direction: SlideDirection.down,
            child: Text(
              l10n.createWalletDesc,
              style: TextStyle(
                fontSize: r.fontM,
                color: isDark ? Colors.white70 : Colors.grey[600],
              ),
            ),
          ),

          SizedBox(height: r.hp(4)),

          // Wallet Name Input
          _SlideInWidget(
            delay: 200,
            direction: SlideDirection.left,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  l10n.walletName,
                  style: TextStyle(
                    fontSize: r.fontS,
                    fontWeight: FontWeight.bold,
                    color: isDark ? Colors.white70 : Colors.grey[700],
                  ),
                ),
                SizedBox(height: r.spaceXS),
                TextField(
                  controller: _accountNameController,
                  style: TextStyle(color: isDark ? Colors.white : Colors.black),
                  decoration: InputDecoration(
                    hintText: l10n.walletNameHint,
                    hintStyle: TextStyle(
                      color: isDark ? Colors.grey[600] : Colors.grey[400],
                    ),
                    prefixIcon: Icon(
                      Icons.account_balance_wallet,
                      color: colorTheme.primary,
                    ),
                    filled: true,
                    fillColor: isDark
                        ? Colors.white.withValues(alpha: 0.05)
                        : Colors.grey[100],
                    border: OutlineInputBorder(
                      borderRadius: r.borderRadiusM,
                      borderSide: BorderSide.none,
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderRadius: r.borderRadiusM,
                      borderSide: BorderSide(
                        color: colorTheme.primary,
                        width: 2,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),

          SizedBox(height: r.hp(3)),

          // Wallet Type Selection
          _SlideInWidget(
            delay: 300,
            direction: SlideDirection.left,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  l10n.walletType,
                  style: TextStyle(
                    fontSize: r.fontS,
                    fontWeight: FontWeight.bold,
                    color: isDark ? Colors.white70 : Colors.grey[700],
                  ),
                ),
                SizedBox(height: r.spaceS),
                GridView.builder(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 2,
                    crossAxisSpacing: r.spaceM,
                    mainAxisSpacing: r.spaceM,
                    childAspectRatio: 2.5,
                  ),
                  itemCount: accountTypes.length,
                  itemBuilder: (context, index) {
                    final type = accountTypes[index];
                    final isSelected = _selectedAccountType == type['id'];

                    return GestureDetector(
                      onTap: () => setState(
                        () => _selectedAccountType = type['id'] as String,
                      ),
                      child: AnimatedContainer(
                        duration: const Duration(milliseconds: 200),
                        padding: EdgeInsets.symmetric(horizontal: r.spaceS),
                        decoration: BoxDecoration(
                          color: isSelected
                              ? colorTheme.primary.withValues(alpha: 0.1)
                              : (isDark
                                    ? Colors.white.withValues(alpha: 0.05)
                                    : Colors.grey[100]),
                          borderRadius: r.borderRadiusS,
                          border: Border.all(
                            color: isSelected
                                ? colorTheme.primary
                                : Colors.transparent,
                            width: 1.5,
                          ),
                        ),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(
                              type['icon'] as IconData,
                              color: isSelected
                                  ? colorTheme.primary
                                  : Colors.grey,
                              size: r.iconS,
                            ),
                            SizedBox(width: r.spaceS),
                            Text(
                              type['name'] as String,
                              style: TextStyle(
                                fontSize: r.fontXS,
                                fontWeight: isSelected
                                    ? FontWeight.bold
                                    : FontWeight.normal,
                                color: isDark ? Colors.white : Colors.black87,
                              ),
                            ),
                          ],
                        ),
                      ),
                    );
                  },
                ),
              ],
            ),
          ),

          SizedBox(height: r.hp(3)),

          // Initial Balance Input
          _SlideInWidget(
            delay: 400,
            direction: SlideDirection.left,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  l10n.initialBalanceOptional,
                  style: TextStyle(
                    fontSize: r.fontS,
                    fontWeight: FontWeight.bold,
                    color: isDark ? Colors.white70 : Colors.grey[700],
                  ),
                ),
                SizedBox(height: r.spaceXS),
                TextField(
                  controller: _initialBalanceController,
                  keyboardType: const TextInputType.numberWithOptions(
                    decimal: true,
                  ),
                  style: TextStyle(color: isDark ? Colors.white : Colors.black),
                  decoration: InputDecoration(
                    suffixText: _selectedCurrency,
                    hintText: '0.0',
                    hintStyle: TextStyle(
                      color: isDark ? Colors.grey[600] : Colors.grey[400],
                    ),
                    prefixIcon: Icon(
                      Icons.attach_money,
                      color: colorTheme.primary,
                    ),
                    filled: true,
                    fillColor: isDark
                        ? Colors.white.withValues(alpha: 0.05)
                        : Colors.grey[100],
                    border: OutlineInputBorder(
                      borderRadius: r.borderRadiusM,
                      borderSide: BorderSide.none,
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderRadius: r.borderRadiusM,
                      borderSide: BorderSide(
                        color: colorTheme.primary,
                        width: 2,
                      ),
                    ),
                  ),
                ),
                SizedBox(height: r.spaceXS),
                Text(
                  l10n.initialBalanceHint,
                  style: TextStyle(fontSize: r.fontXS, color: Colors.grey),
                ),
              ],
            ),
          ),

          if (_isLoading)
            Padding(
              padding: EdgeInsets.only(top: r.paddingL),
              child: Center(
                child: CircularProgressIndicator(color: colorTheme.primary),
              ),
            ),
        ],
      ),
    );
  }

  // ============ NAVIGATION BUTTONS ============
  Widget _buildNavigationButtons(
    ResponsiveHelper r,
    ColorTheme colorTheme,
    bool isDark,
  ) {
    if (_isLoading) return const SizedBox.shrink();

    return Container(
      padding: EdgeInsets.all(r.paddingL),
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF1E1E1E) : Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.1),
            blurRadius: 10,
            offset: const Offset(0, -2),
          ),
        ],
      ),
      child: Row(
        children: [
          if (_currentPage > 0)
            TextButton.icon(
              onPressed: _previousPage,
              icon: Icon(Icons.arrow_back, size: r.iconS),
              label: Text(AppLocalizations.of(context)!.backButton),
              style: TextButton.styleFrom(
                foregroundColor: isDark ? Colors.white70 : Colors.grey[700],
              ),
            )
          else
            const SizedBox(),

          const Spacer(),

          // Page dots
          Row(
            children: List.generate(6, (index) {
              final isActive = _currentPage == index;
              return AnimatedContainer(
                duration: const Duration(milliseconds: 300),
                width: isActive ? r.hp(2.5) : r.hp(1),
                height: r.hp(1),
                margin: EdgeInsets.symmetric(horizontal: r.spaceXS / 2),
                decoration: BoxDecoration(
                  color: isActive
                      ? colorTheme.primary
                      : colorTheme.primary.withValues(alpha: 0.3),
                  borderRadius: BorderRadius.circular(r.hp(0.5)),
                ),
              );
            }),
          ),

          const Spacer(),

          if (_currentPage < 5)
            ElevatedButton(
              onPressed: _nextPage,
              style: ElevatedButton.styleFrom(
                backgroundColor: colorTheme.primary,
                foregroundColor: Colors.white,
                padding: EdgeInsets.symmetric(
                  horizontal: r.paddingL,
                  vertical: r.paddingS,
                ),
                shape: RoundedRectangleBorder(borderRadius: r.borderRadiusM),
                elevation: 4,
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    AppLocalizations.of(context)!.continueButton,
                    style: TextStyle(
                      fontSize: r.fontS,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  SizedBox(width: r.spaceXS),
                  Icon(Icons.arrow_forward, size: r.iconS),
                ],
              ),
            )
          else
            ElevatedButton(
              onPressed: _completeOnboarding,
              style: ElevatedButton.styleFrom(
                backgroundColor: colorTheme.success,
                foregroundColor: Colors.white,
                padding: EdgeInsets.symmetric(
                  horizontal: r.paddingL,
                  vertical: r.paddingS,
                ),
                shape: RoundedRectangleBorder(borderRadius: r.borderRadiusM),
                elevation: 4,
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    AppLocalizations.of(context)!.startButton,
                    style: TextStyle(
                      fontSize: r.fontS,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  SizedBox(width: r.spaceXS),
                  Icon(Icons.rocket_launch, size: r.iconS),
                ],
              ),
            ),
        ],
      ),
    );
  }
}

// ============ INLINE ANIMATION WIDGETS ============
// Bu widget'lar private olarak dosya içinde tutuluyor ki
// başka yerlerden erişilmesin, kopyala-yapıştır ile taşınabilsin.

/// Wrapper for animated pages to force rebuild with keys
class _AnimatedPage extends StatelessWidget {
  final Widget child;
  const _AnimatedPage({super.key, required this.child});
  @override
  Widget build(BuildContext context) => child;
}

enum SlideDirection { up, down, left, right }

class _SlideInWidget extends StatefulWidget {
  final Widget child;
  final int delay;
  final SlideDirection direction;
  const _SlideInWidget({
    required this.child,
    required this.delay,
    this.direction = SlideDirection.up,
  });
  @override
  State<_SlideInWidget> createState() => _SlideInWidgetState();
}

class _SlideInWidgetState extends State<_SlideInWidget>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<Offset> _slideAnimation;
  late Animation<double> _fadeAnimation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(milliseconds: 600),
      vsync: this,
    );
    Offset beginOffset;
    switch (widget.direction) {
      case SlideDirection.up:
        beginOffset = const Offset(0, 0.3);
        break;
      case SlideDirection.down:
        beginOffset = const Offset(0, -0.3);
        break;
      case SlideDirection.left:
        beginOffset = const Offset(0.3, 0);
        break;
      case SlideDirection.right:
        beginOffset = const Offset(-0.3, 0);
        break;
    }
    _slideAnimation = Tween<Offset>(
      begin: beginOffset,
      end: Offset.zero,
    ).animate(CurvedAnimation(parent: _controller, curve: Curves.easeOutCubic));
    _fadeAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(parent: _controller, curve: Curves.easeOut));
    Future.delayed(Duration(milliseconds: widget.delay), () {
      if (mounted) _controller.forward();
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) => SlideTransition(
    position: _slideAnimation,
    child: FadeTransition(opacity: _fadeAnimation, child: widget.child),
  );
}

class _ScaleInWidget extends StatefulWidget {
  final Widget child;
  final int delay;
  const _ScaleInWidget({required this.child, required this.delay});
  @override
  State<_ScaleInWidget> createState() => _ScaleInWidgetState();
}

class _ScaleInWidgetState extends State<_ScaleInWidget>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _scaleAnimation;
  late Animation<double> _fadeAnimation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(milliseconds: 500),
      vsync: this,
    );
    _scaleAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(parent: _controller, curve: Curves.easeOutBack));
    _fadeAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(parent: _controller, curve: Curves.easeOut));
    Future.delayed(Duration(milliseconds: widget.delay), () {
      if (mounted) _controller.forward();
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) => ScaleTransition(
    scale: _scaleAnimation,
    child: FadeTransition(opacity: _fadeAnimation, child: widget.child),
  );
}

class _FloatingParticle extends StatefulWidget {
  final double size;
  final Color color;
  final int delay;
  const _FloatingParticle({
    required this.size,
    required this.color,
    required this.delay,
  });
  @override
  State<_FloatingParticle> createState() => _FloatingParticleState();
}

class _FloatingParticleState extends State<_FloatingParticle>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(seconds: 3),
      vsync: this,
    );
    Future.delayed(Duration(milliseconds: widget.delay), () {
      if (mounted) _controller.repeat(reverse: true);
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _controller,
      builder: (context, child) {
        final value = _controller.value;
        return Transform.translate(
          offset: Offset(
            math.sin(value * math.pi * 2) * 10,
            math.cos(value * math.pi * 2) * 15,
          ),
          child: Opacity(
            opacity: 0.15 + (value * 0.15),
            child: Container(
              width: widget.size,
              height: widget.size,
              decoration: BoxDecoration(
                color: widget.color,
                shape: BoxShape.circle,
              ),
            ),
          ),
        );
      },
    );
  }
}

class _PulseWidget extends StatefulWidget {
  final Widget child;
  const _PulseWidget({required this.child});
  @override
  State<_PulseWidget> createState() => _PulseWidgetState();
}

class _PulseWidgetState extends State<_PulseWidget>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(milliseconds: 1500),
      vsync: this,
    )..repeat(reverse: true);
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _controller,
      builder: (context, child) {
        return Transform.scale(
          scale: 1.0 + (_controller.value * 0.05),
          child: widget.child,
        );
      },
    );
  }
}
