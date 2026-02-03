// lib/features/auth/presentation/onboarding_preview_view.dart
import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/color_theme_provider.dart';
import '../../../core/utils/responsive_helper.dart';

/// Onboarding Preview - Ayarlardan erişilebilen demo modu
class OnboardingPreviewView extends ConsumerStatefulWidget {
  const OnboardingPreviewView({super.key});

  @override
  ConsumerState<OnboardingPreviewView> createState() =>
      _OnboardingPreviewViewState();
}

class _OnboardingPreviewViewState extends ConsumerState<OnboardingPreviewView>
    with TickerProviderStateMixin {
  final PageController _pageController = PageController();
  int _currentPage = 0;

  // Her sayfa değiştiğinde animasyonları yeniden tetiklemek için key
  int _animationKey = 0;

  // Animation controllers
  late AnimationController _logoAnimController;
  late AnimationController _fadeInController;
  late Animation<double> _logoScale;
  late Animation<double> _fadeIn;

  @override
  void initState() {
    super.initState();
    _initAnimations();
  }

  void _initAnimations() {
    _logoAnimController = AnimationController(
      duration: const Duration(milliseconds: 1200),
      vsync: this,
    );

    _fadeInController = AnimationController(
      duration: const Duration(milliseconds: 800),
      vsync: this,
    );

    _logoScale = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _logoAnimController, curve: Curves.elasticOut),
    );

    _fadeIn = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(parent: _fadeInController, curve: Curves.easeIn));

    _logoAnimController.forward();
    Future.delayed(const Duration(milliseconds: 400), () {
      if (mounted) _fadeInController.forward();
    });
  }

  @override
  void dispose() {
    _pageController.dispose();
    _logoAnimController.dispose();
    _fadeInController.dispose();
    super.dispose();
  }

  void _nextPage() {
    if (_currentPage < 4) {
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

  @override
  Widget build(BuildContext context) {
    final r = ResponsiveHelper.of(context);
    final colorTheme = ref.watch(currentColorThemeProvider);
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      backgroundColor: isDark ? const Color(0xFF121212) : Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: Icon(Icons.close, color: isDark ? Colors.white : Colors.black),
          onPressed: () => context.pop(),
        ),
        title: Text(
          'Tanıtım Turu',
          style: TextStyle(
            color: isDark ? Colors.white : Colors.black,
            fontSize: r.fontL,
            fontWeight: FontWeight.bold,
          ),
        ),
        centerTitle: true,
      ),
      body: SafeArea(
        child: Column(
          children: [
            // Progress indicator with animation
            _buildProgressIndicator(r, colorTheme),

            // Pages
            Expanded(
              child: PageView(
                controller: _pageController,
                onPageChanged: (page) {
                  setState(() {
                    _currentPage = page;
                    _animationKey++; // Her sayfa değişiminde key güncelle
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
        tween: Tween(begin: 0.0, end: (_currentPage + 1) / 5),
        duration: const Duration(milliseconds: 500),
        curve: Curves.easeOutCubic,
        builder: (context, value, child) {
          return Container(
            height: r.hp(0.8),
            decoration: BoxDecoration(
              color: colorTheme.primary.withOpacity(0.2),
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
    return Stack(
      children: [
        // Floating particles
        ...List.generate(
          20,
          (index) => _buildFloatingParticle(r, colorTheme, index),
        ),

        SingleChildScrollView(
          padding: EdgeInsets.all(r.paddingL),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              SizedBox(height: r.hp(4)),

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
                          color: colorTheme.primary.withOpacity(0.4),
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
                  'Wallet Elite',
                  style: TextStyle(
                    fontSize: r.hp(4.5),
                    fontWeight: FontWeight.bold,
                    color: isDark ? Colors.white : Colors.black87,
                  ),
                ),
              ),

              SizedBox(height: r.hp(1)),

              _SlideInWidget(
                delay: 300,
                direction: SlideDirection.up,
                child: Text(
                  'Finansal özgürlüğünüz, elinizde',
                  style: TextStyle(
                    fontSize: r.fontM,
                    color: isDark ? Colors.white70 : Colors.grey[600],
                    height: 1.5,
                  ),
                  textAlign: TextAlign.center,
                ),
              ),

              SizedBox(height: r.hp(6)),

              // Quick features with staggered animation
              _SlideInWidget(
                delay: 400,
                direction: SlideDirection.left,
                child: _buildQuickFeature(
                  r,
                  colorTheme,
                  isDark,
                  Icons.security,
                  'Verileriniz güvenli ve şifrelenmiş',
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
                  'Tüm cihazlarınızda senkronize',
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
                  'Akıllı finansal öneriler',
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
        color: isDark ? Colors.white.withOpacity(0.05) : Colors.grey[50],
        borderRadius: r.borderRadiusM,
        border: Border.all(color: colorTheme.primary.withOpacity(0.2)),
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
    final features = [
      {
        'icon': Icons.account_balance_wallet,
        'title': 'Cüzdan Yönetimi',
        'desc': 'Tüm hesaplarınızı tek yerden takip edin',
        'color': colorTheme.primary,
      },
      {
        'icon': Icons.pie_chart,
        'title': 'Bütçe Takibi',
        'desc': 'Harcama limitleri belirleyin',
        'color': colorTheme.accent,
      },
      {
        'icon': Icons.repeat,
        'title': 'Tekrarlayan İşlemler',
        'desc': 'Düzenli ödemelerinizi otomatikleştirin',
        'color': colorTheme.success,
      },
      {
        'icon': Icons.people,
        'title': 'Borç Defteri',
        'desc': 'Alacak ve borçlarınızı takip edin',
        'color': Colors.orange,
      },
      {
        'icon': Icons.analytics,
        'title': 'Detaylı İstatistikler',
        'desc': 'Paranızın nereye gittiğini görün',
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
              'Özellikleri Keşfet',
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
              'Finanslarınızı yönetmek için ihtiyacınız olan her şey',
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
        color: isDark ? Colors.white.withOpacity(0.05) : Colors.white,
        borderRadius: r.borderRadiusM,
        border: Border.all(color: color.withOpacity(0.3)),
        boxShadow: [
          BoxShadow(
            color: color.withOpacity(0.1),
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
              gradient: LinearGradient(colors: [color, color.withOpacity(0.7)]),
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
          Icon(Icons.arrow_forward_ios, color: color, size: r.iconS),
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
              '18 Dil Desteği 🌍',
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
              'Kendi dilinizde kullanın',
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

                return _ScaleInWidget(
                  delay: 200 + (index * 80),
                  child: Container(
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        colors: [
                          colorTheme.primary.withOpacity(0.1),
                          colorTheme.accent.withOpacity(0.05),
                        ],
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                      ),
                      borderRadius: r.borderRadiusM,
                      border: Border.all(
                        color: colorTheme.primary.withOpacity(0.2),
                      ),
                    ),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(
                          lang['flag']!,
                          style: TextStyle(fontSize: r.hp(4)),
                        ),
                        SizedBox(height: r.hp(0.5)),
                        Text(
                          lang['name']!,
                          style: TextStyle(
                            fontSize: r.fontXS,
                            fontWeight: FontWeight.w600,
                            color: isDark ? Colors.white : Colors.black87,
                          ),
                          textAlign: TextAlign.center,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ],
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
    final themes = [
      {
        'name': 'Okyanus',
        'primary': const Color(0xFF2196F3),
        'accent': const Color(0xFF00BCD4),
        'icon': Icons.water,
      },
      {
        'name': 'Gün Batımı',
        'primary': const Color(0xFFFF6B35),
        'accent': const Color(0xFFFFD93D),
        'icon': Icons.wb_twilight,
      },
      {
        'name': 'Orman',
        'primary': const Color(0xFF4CAF50),
        'accent': const Color(0xFF8BC34A),
        'icon': Icons.park,
      },
      {
        'name': 'Lavanta',
        'primary': const Color(0xFF9C27B0),
        'accent': const Color(0xFFE91E63),
        'icon': Icons.local_florist,
      },
      {
        'name': 'Gece Yarısı',
        'primary': const Color(0xFF3F51B5),
        'accent': const Color(0xFF7C4DFF),
        'icon': Icons.nightlight,
      },
      {
        'name': 'Gül',
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
              '6 Renk Teması 🎨',
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
              'Kendi tarzınızı seçin + Karanlık Mod',
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

                return _ScaleInWidget(
                  delay: 200 + (index * 100),
                  child: Container(
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
                      boxShadow: [
                        BoxShadow(
                          color: (theme['primary'] as Color).withOpacity(0.4),
                          blurRadius: 15,
                          offset: const Offset(0, 5),
                        ),
                      ],
                    ),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          theme['icon'] as IconData,
                          size: r.iconXL,
                          color: Colors.white,
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
                );
              },
            ),
          ),

          SizedBox(height: r.hp(2)),

          // Dark mode showcase
          _SlideInWidget(
            delay: 800,
            direction: SlideDirection.up,
            child: Container(
              padding: EdgeInsets.all(r.paddingM),
              decoration: BoxDecoration(
                color: isDark
                    ? Colors.white.withOpacity(0.1)
                    : Colors.grey[100],
                borderRadius: r.borderRadiusM,
              ),
              child: Row(
                children: [
                  Icon(
                    Icons.dark_mode,
                    color: colorTheme.primary,
                    size: r.iconM,
                  ),
                  SizedBox(width: r.spaceM),
                  Text(
                    'Karanlık mod da mevcut!',
                    style: TextStyle(
                      fontSize: r.fontM,
                      fontWeight: FontWeight.w600,
                      color: isDark ? Colors.white : Colors.black87,
                    ),
                  ),
                  const Spacer(),
                  Icon(
                    Icons.check_circle,
                    color: colorTheme.success,
                    size: r.iconM,
                  ),
                ],
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
    final currencies = [
      {
        'code': 'TRY',
        'name': 'Türk Lirası',
        'symbol': '₺',
        'color': Colors.red,
      },
      {
        'code': 'USD',
        'name': 'ABD Doları',
        'symbol': r'$',
        'color': Colors.green,
      },
      {'code': 'EUR', 'name': 'Euro', 'symbol': '€', 'color': Colors.blue},
      {
        'code': 'GBP',
        'name': 'İngiliz Sterlini',
        'symbol': '£',
        'color': Colors.purple,
      },
      {
        'code': 'JPY',
        'name': 'Japon Yeni',
        'symbol': '¥',
        'color': Colors.orange,
      },
      {
        'code': 'RUB',
        'name': 'Rus Rublesi',
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
              'Çoklu Para Birimi 💰',
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
              'Tüm dünya para birimlerini destekliyoruz',
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
                final color = currency['color'] as Color;

                return _SlideInWidget(
                  delay: 200 + (index * 100),
                  direction: SlideDirection.right,
                  child: Container(
                    margin: EdgeInsets.only(bottom: r.hp(1.5)),
                    padding: EdgeInsets.all(r.paddingM),
                    decoration: BoxDecoration(
                      color: isDark
                          ? Colors.white.withOpacity(0.05)
                          : Colors.white,
                      borderRadius: r.borderRadiusM,
                      border: Border.all(color: color.withOpacity(0.3)),
                      boxShadow: [
                        BoxShadow(
                          color: color.withOpacity(0.1),
                          blurRadius: 8,
                          offset: const Offset(0, 2),
                        ),
                      ],
                    ),
                    child: Row(
                      children: [
                        Container(
                          width: r.hp(6),
                          height: r.hp(6),
                          decoration: BoxDecoration(
                            gradient: LinearGradient(
                              colors: [color, color.withOpacity(0.7)],
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
                                  color: isDark ? Colors.white : Colors.black87,
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
                      ],
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

  // ============ NAVIGATION BUTTONS ============
  Widget _buildNavigationButtons(
    ResponsiveHelper r,
    ColorTheme colorTheme,
    bool isDark,
  ) {
    return Container(
      padding: EdgeInsets.all(r.paddingL),
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF1E1E1E) : Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
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
              label: const Text('Geri'),
              style: TextButton.styleFrom(
                foregroundColor: isDark ? Colors.white70 : Colors.grey[700],
              ),
            )
          else
            const SizedBox(),

          const Spacer(),

          // Page dots
          Row(
            children: List.generate(5, (index) {
              final isActive = _currentPage == index;
              return AnimatedContainer(
                duration: const Duration(milliseconds: 300),
                width: isActive ? r.hp(2.5) : r.hp(1),
                height: r.hp(1),
                margin: EdgeInsets.symmetric(horizontal: r.spaceXS / 2),
                decoration: BoxDecoration(
                  color: isActive
                      ? colorTheme.primary
                      : colorTheme.primary.withOpacity(0.3),
                  borderRadius: BorderRadius.circular(r.hp(0.5)),
                ),
              );
            }),
          ),

          const Spacer(),

          if (_currentPage < 4)
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
                    'İleri',
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
              onPressed: () => context.pop(),
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
                    'Tamam',
                    style: TextStyle(
                      fontSize: r.fontS,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  SizedBox(width: r.spaceXS),
                  Icon(Icons.check, size: r.iconS),
                ],
              ),
            ),
        ],
      ),
    );
  }
}

// ============ ANIMATION WIDGETS ============

/// Wrapper for animated pages
class _AnimatedPage extends StatelessWidget {
  final Widget child;

  const _AnimatedPage({super.key, required this.child});

  @override
  Widget build(BuildContext context) => child;
}

/// Slide direction enum
enum SlideDirection { up, down, left, right }

/// Slide-in animation widget
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
  Widget build(BuildContext context) {
    return SlideTransition(
      position: _slideAnimation,
      child: FadeTransition(opacity: _fadeAnimation, child: widget.child),
    );
  }
}

/// Scale-in animation widget
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
  Widget build(BuildContext context) {
    return ScaleTransition(
      scale: _scaleAnimation,
      child: FadeTransition(opacity: _fadeAnimation, child: widget.child),
    );
  }
}

/// Floating particle animation
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

/// Pulse animation widget
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
