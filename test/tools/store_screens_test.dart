// Mağaza ekran görüntüsü aracı: ana ekranları tool/store_locales.json'daki
// demo veriyle her dil için
// başlıklı 1080x1920 mağaza görseli ve 1024x500 öne çıkan grafik olarak çizer
// (<SHOTS>/screenshots/<dil>/, <SHOTS>/feature/<dil>.png).
// Normal test çalıştırmasında atlanır:
//   flutter test test/tools/store_screens_test.dart --dart-define=SHOTS=<klasör>
//     [--dart-define=LOCALES=de,ja]
library;

import 'dart:convert';
import 'dart:io';
import 'dart:ui' as ui;

import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter/services.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart' show Intl;
import 'package:shared_preferences/shared_preferences.dart';
import 'package:supabase_flutter/supabase_flutter.dart' hide User;
import 'package:wallet_elite/core/ads/ads_providers.dart';
import 'package:wallet_elite/core/services/app_update_service.dart';
import 'package:wallet_elite/core/theme/app_colors.dart';
import 'package:wallet_elite/core/theme/app_theme.dart';
import 'package:wallet_elite/core/theme/color_theme_provider.dart';
import 'package:wallet_elite/features/auth/data/auth_provider.dart';
import 'package:wallet_elite/features/budgets/data/budget_provider.dart';
import 'package:wallet_elite/features/budgets/models/budget_model.dart';
import 'package:wallet_elite/features/budgets/presentation/budgets_view.dart';
import 'package:wallet_elite/features/debts/presentation/debts_view.dart';
import 'package:wallet_elite/features/home/presentation/dashboard_view.dart';
import 'package:wallet_elite/features/premium/data/premium_provider.dart';
import 'package:wallet_elite/features/recurring/data/recurring_provider.dart';
import 'package:wallet_elite/features/settings/data/preferences_sync.dart';
import 'package:wallet_elite/features/settings/data/settings_provider.dart';
import 'package:wallet_elite/features/statistics/presentation/statistics_view.dart';
import 'package:wallet_elite/features/transactions/presentation/transactions_view.dart';
import 'package:wallet_elite/features/wallet/data/debt_provider.dart';
import 'package:wallet_elite/features/wallet/data/wallet_provider.dart';
import 'package:wallet_elite/features/wallet/models/account_model.dart';
import 'package:wallet_elite/features/wallet/models/category_model.dart';
import 'package:wallet_elite/features/wallet/models/debt_model.dart';
import 'package:wallet_elite/features/wallet/models/profile_model.dart';
import 'package:wallet_elite/features/wallet/models/transaction_model.dart';
import 'package:wallet_elite/l10n/app_localizations.dart';

const _outDir = String.fromEnvironment('SHOTS');
const _only = String.fromEnvironment('LOCALES');
const _screenSize = Size(360, 760);
const _pixelRatio = 3.0;
const _shotSize = Size(360, 640); // 1080x1920 mağaza görseli
const _featureSize = Size(1024, 500);
const _gold = Color(0xFFE39A1C);
const _goldLight = Color(0xFFFFE08A);

Future<void> _loadFonts() async {
  Future<void> load(String family, List<String> files) async {
    final loader = FontLoader(family);
    for (final f in files) {
      final file = File(f);
      if (file.existsSync()) {
        loader.addFont(
          Future.value(ByteData.view(file.readAsBytesSync().buffer)),
        );
      }
    }
    await loader.load();
  }

  const fonts = 'C:/Windows/Fonts';
  for (final entry in {
    'regular': 'segoeui.ttf',
    '300': 'segoeuil.ttf',
    '500': 'seguisb.ttf',
    '600': 'seguisb.ttf',
    '700': 'segoeuib.ttf',
    '800': 'segoeuib.ttf',
    '900': 'seguibl.ttf',
  }.entries) {
    await load('Inter_${entry.key}', ['$fonts/${entry.value}']);
  }
  await load('Roboto', [
    '$fonts/segoeui.ttf',
    '$fonts/seguisb.ttf',
    '$fonts/segoeuib.ttf',
  ]);
  await load('Emoji', ['$fonts/seguiemj.ttf']);
  await load('Devanagari', ['$fonts/NIRMALA.TTF']);
  await load('Thai', ['$fonts/LeelawUI.ttf']);
  await load('JaFont', ['$fonts/YuGothM.ttc']);
  await load('KoFont', ['$fonts/malgun.ttf']);
  await load('ZhFont', ['$fonts/msyh.ttc']);
  await load('MaterialIcons', [
    'C:/src/flutter_3_47/flutter/bin/cache/artifacts/material_fonts/MaterialIcons-Regular.otf',
  ]);
}

final _now = DateTime(2026, 10, 18, 12);

/// Dile göre demo içerik; tool/store_locales.json'dan okunur.
class _Demo {
  final String locale;
  final String currency;
  final String name;
  final Map<String, String> words;
  final double scale; // para tutarları için çarpan
  final String appName;
  final String feature;
  final List<List<String>> captions;

  _Demo.fromJson(Map<String, dynamic> j)
      : locale = j['app_locale'] as String,
        appName = j['app_name'] as String,
        feature = j['feature'] as String,
        captions = [
          for (final c in j['captions'] as List) List<String>.from(c as List),
        ],
        currency = j['currency'] as String,
        name = j['person'] as String,
        scale = (j['scale'] as num).toDouble(),
        words = Map<String, String>.from(j['words'] as Map);

  String w(String key) => words[key]!;

  TextDirection get direction =>
      locale == 'ar' ? TextDirection.rtl : TextDirection.ltr;

  /// Latin dışı yazılar için yedek fontlar; CJK'da dilin kendi fontu önce gelsin.
  List<String> get fallback => switch (locale) {
        'ja' => const ['Emoji', 'JaFont', 'ZhFont', 'KoFont'],
        'ko' => const ['Emoji', 'KoFont', 'JaFont', 'ZhFont'],
        'zh' => const ['Emoji', 'ZhFont', 'JaFont', 'KoFont'],
        _ => const ['Emoji', 'Devanagari', 'Thai', 'ZhFont', 'JaFont', 'KoFont'],
      };
}

List<_Demo> _loadDemos() {
  final json = jsonDecode(File('tool/store_locales.json').readAsStringSync())
      as Map<String, dynamic>;
  final all = (json['locales'] as List)
      .map((e) => _Demo.fromJson(e as Map<String, dynamic>))
      .toList();
  if (_only.isEmpty) return all;
  final wanted = _only.split(',');
  return all.where((d) => wanted.contains(d.locale)).toList();
}

List<CategoryModel> _categories(_Demo d) {
  CategoryModel c(String id, String icon, String color, String type) =>
      CategoryModel(
        id: id,
        userId: 'u',
        name: d.w(id),
        icon: icon,
        color: color,
        type: type,
        createdAt: _now,
      );
  return [
    c('food', 'shopping_cart', '#F97316', 'expense'),
    c('rent', 'home', '#8B5CF6', 'expense'),
    c('fun', 'movie', '#EC4899', 'expense'),
    c('bills', 'receipt', '#0EA5E9', 'expense'),
    c('transport', 'directions_car', '#EAB308', 'expense'),
    c('salary', 'attach_money', '#22C55E', 'income'),
    c('freelance', 'laptop', '#14B8A6', 'income'),
  ];
}

List<TransactionModel> _transactions(_Demo d) {
  var n = 0;
  TransactionModel t(String cat, double amount, String type, int daysAgo,
          String desc, [String account = 'a1']) =>
      TransactionModel(
        id: 't${n++}',
        userId: 'u',
        accountId: account,
        categoryId: cat,
        amount: (amount * d.scale).roundToDouble(),
        type: type,
        description: d.w(desc),
        date: _now.subtract(Duration(days: daysAgo, hours: n)),
        createdAt: _now,
      );
  return [
    t('food', 842, 'expense', 0, 'd_food1'),
    t('transport', 1250, 'expense', 1, 'd_transport1'),
    t('salary', 42000, 'income', 2, 'd_salary1', 'a2'),
    t('fun', 320, 'expense', 3, 'd_fun1'),
    t('bills', 1180, 'expense', 4, 'd_bills1', 'a2'),
    t('freelance', 7500, 'income', 5, 'd_freelance1', 'a2'),
    t('rent', 15000, 'expense', 6, 'd_rent1', 'a2'),
    t('food', 410, 'expense', 8, 'd_food2'),
    t('fun', 650, 'expense', 10, 'd_fun2'),
    t('bills', 560, 'expense', 12, 'd_bills2', 'a2'),
    t('food', 1900, 'expense', 15, 'd_food3'),
    t('salary', 40000, 'income', 32, 'd_salary2', 'a2'),
    t('rent', 15000, 'expense', 36, 'd_rent2', 'a2'),
    t('food', 2600, 'expense', 40, 'd_food3'),
    t('fun', 1200, 'expense', 45, 'd_fun2'),
    t('transport', 900, 'expense', 50, 'd_transport1'),
    t('salary', 40000, 'income', 62, 'd_salary2', 'a2'),
    t('rent', 14000, 'expense', 66, 'd_rent2', 'a2'),
    t('food', 3100, 'expense', 70, 'd_food3'),
  ];
}

List<BudgetModel> _budgets(_Demo d) {
  BudgetModel b(String id, String cat, String icon, double amount, double spent) =>
      BudgetModel(
        id: id,
        userId: 'u',
        name: d.w('b_$cat'),
        categoryId: cat,
        categoryName: d.w(cat),
        categoryIcon: icon,
        amount: amount * d.scale,
        spent: spent * d.scale,
        period: BudgetPeriod.monthly,
        createdAt: _now,
        updatedAt: _now,
      );
  return [
    b('b1', 'food', 'shopping_cart', 6000, 3152),
    b('b2', 'fun', 'movie', 2000, 1720),
    b('b3', 'transport', 'directions_car', 2500, 1250),
  ];
}

List<DebtModel> _debts(_Demo d) {
  DebtModel x(String id, String p, double amount, double remaining, String type,
          int dueInDays) =>
      DebtModel(
        id: id,
        userId: 'u',
        personName: d.w(p),
        amount: amount * d.scale,
        remainingAmount: remaining * d.scale,
        type: type,
        dueDate: _now.add(Duration(days: dueInDays)),
        createdAt: _now,
      );
  return [
    x('x1', 'p1', 2500, 1500, 'lend', 12),
    x('x2', 'p2', 5000, 5000, 'borrow', 25),
    x('x3', 'p3', 800, 300, 'lend', 4),
  ];
}

/// Test ortamında sistem fontları yok; 👑 ve Latin dışı yazılar Windows
/// fontlarından gelsin.
ThemeData _withFallback(ThemeData t, List<String> fallback) => t.copyWith(
      textTheme: t.textTheme.apply(fontFamilyFallback: fallback),
      primaryTextTheme: t.primaryTextTheme.apply(fontFamilyFallback: fallback),
      appBarTheme: t.appBarTheme.copyWith(
        titleTextStyle:
            t.appBarTheme.titleTextStyle?.copyWith(fontFamilyFallback: fallback),
      ),
      textButtonTheme: TextButtonThemeData(
        style: _buttonFallback(t.textButtonTheme.style, fallback),
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: _buttonFallback(t.elevatedButtonTheme.style, fallback),
      ),
      outlinedButtonTheme: OutlinedButtonThemeData(
        style: _buttonFallback(t.outlinedButtonTheme.style, fallback),
      ),
    );

ButtonStyle? _buttonFallback(ButtonStyle? style, List<String> fallback) {
  final text = style?.textStyle?.resolve(const {});
  if (style == null || text == null) return style;
  return style.copyWith(
    textStyle: WidgetStatePropertyAll(
      text.copyWith(fontFamilyFallback: fallback),
    ),
  );
}

Widget _screen(_Demo d, Widget child, SharedPreferences prefs) {
  final theme = ColorTheme.midnight;
  final debts = _debts(d);
  double sum(String type) => debts
      .where((e) => e.type == type)
      .fold(0.0, (a, e) => a + e.remainingAmount);
  return SizedBox.fromSize(
    size: _screenSize,
    child: ProviderScope(
      overrides: [
        sharedPreferencesProvider.overrideWithValue(prefs),
        currentColorThemeProvider.overrideWithValue(theme),
        currentUserIdProvider.overrideWithValue('u'),
        userProfileProvider.overrideWith(
          (ref) async =>
              ProfileModel(id: 'u', fullName: d.name, isPremium: true),
        ),
        accountsProvider.overrideWith(
          (ref) async => [
            AccountModel(
              id: 'a1',
              userId: 'u',
              name: d.w('cash'),
              type: 'cash',
              balance: 4250 * d.scale,
              currency: d.currency,
              createdAt: _now,
            ),
            AccountModel(
              id: 'a2',
              userId: 'u',
              name: d.w('bank'),
              type: 'bank',
              balance: 44000 * d.scale,
              currency: d.currency,
              createdAt: _now,
            ),
          ],
        ),
        transactionsProvider.overrideWith((ref) async => _transactions(d)),
        categoriesProvider.overrideWith((ref) async => _categories(d)),
        budgetsProvider.overrideWith((ref) async => _budgets(d)),
        debtsProvider.overrideWith((ref) async => debts),
        totalLentProvider.overrideWith((ref) async => sum('lend')),
        totalBorrowedProvider.overrideWith((ref) async => sum('borrow')),
        debtPeopleCountProvider.overrideWith((ref) async => debts.length),
        isPremiumProvider.overrideWithValue(true),
        recurringStartupRunProvider.overrideWith((ref) async => 0),
        adConsentStartupProvider.overrideWith((ref) async {}),
        appUpdateInfoProvider.overrideWith((ref) async => null),
        preferencesRestoreProvider.overrideWith((ref) async {}),
        showAdsProvider.overrideWithValue(false),
      ],
      child: MaterialApp(
        debugShowCheckedModeBanner: false,
        locale: Locale(d.locale),
        localizationsDelegates: const [
          AppLocalizations.delegate,
          GlobalMaterialLocalizations.delegate,
          GlobalWidgetsLocalizations.delegate,
          GlobalCupertinoLocalizations.delegate,
        ],
        supportedLocales: AppLocalizations.supportedLocales,
        theme: _withFallback(
          AppTheme.create(colorTheme: theme, brightness: Brightness.dark),
          d.fallback,
        ),
        builder: (context, child) => MediaQuery(
          data: MediaQuery.of(context).copyWith(
            size: _screenSize,
            padding: const EdgeInsets.only(top: 28),
          ),
          child: child!,
        ),
        home: child,
      ),
    ),
  );
}

void main() {
  if (_outDir.isEmpty) return;
  TestWidgetsFlutterBinding.ensureInitialized();
  GoogleFonts.config.allowRuntimeFetching = false;

  testWidgets('store screens', (tester) async {
    final originalOnError = FlutterError.onError;
    FlutterError.onError = (details) {
      final msg = details.exceptionAsString();
      if (msg.contains('google_fonts') || msg.contains('GoogleFonts')) return;
      if (msg.contains('ListTile background')) return;
      stderr.writeln('ERR: ${msg.split('\n').first}');
      stderr.writeln(details.stack.toString().split('\n').take(8).join('\n'));
    };
    await tester.runAsync(_loadFonts);
    await tester.runAsync(() async {
      try {
        await Supabase.initialize(
          url: 'http://localhost:1',
          anonKey: 'test',
          authOptions: const FlutterAuthClientOptions(
            localStorage: EmptyLocalStorage(),
            autoRefreshToken: false,
            detectSessionInUri: false,
          ),
        );
      } catch (e) {
        stderr.writeln('supabase init: $e');
      }
    });

    const screens = <String, Widget>{
      '01_home': DashboardView(),
      '02_transactions': TransactionsView(),
      '03_statistics': StatisticsView(),
      '04_budgets': BudgetsView(),
      '05_debts': DebtsView(),
    };

    Future<void> capture(Widget child, double ratio, String path) async {
      final key = GlobalKey();
      await tester.pumpWidget(RepaintBoundary(key: key, child: child));
      for (var i = 0; i < 40; i++) {
        await tester.pump(const Duration(milliseconds: 100));
      }
      await tester.runAsync(() async {
        final boundary =
            key.currentContext!.findRenderObject()! as RenderRepaintBoundary;
        final image = await boundary.toImage(pixelRatio: ratio);
        final bytes = await image.toByteData(format: ui.ImageByteFormat.png);
        File(path)
          ..parent.createSync(recursive: true)
          ..writeAsBytesSync(bytes!.buffer.asUint8List());
      });
      await tester.pumpWidget(const SizedBox());
      await tester.pump(const Duration(seconds: 1));
    }

    for (final d in _loadDemos()) {
      Intl.defaultLocale = d.locale; // main.dart'taki gibi
      SharedPreferences.resetStatic();
      SharedPreferences.setMockInitialValues({
        'currency': d.currency,
        'locale': d.locale,
      });
      final prefs = await SharedPreferences.getInstance();

      tester.view.physicalSize = _shotSize * _pixelRatio;
      tester.view.devicePixelRatio = _pixelRatio;
      var i = 0;
      for (final entry in screens.entries) {
        await capture(
          _Framed(
            demo: d,
            caption: d.captions[i++],
            screen: _screen(d, entry.value, prefs),
          ),
          _pixelRatio,
          '$_outDir/screenshots/${d.locale}/${entry.key}.png',
        );
      }

      tester.view.physicalSize = _featureSize;
      tester.view.devicePixelRatio = 1;
      await capture(_Feature(demo: d), 1, '$_outDir/feature/${d.locale}.png');
    }
    await tester.pump(const Duration(seconds: 10));
    FlutterError.onError = originalOnError;
  });
}

/// Mağaza ekran görüntüsü: üstte iki satır başlık, altta çerçeveli telefon.
class _Framed extends StatelessWidget {
  final _Demo demo;
  final List<String> caption;
  final Widget screen;

  const _Framed({
    required this.demo,
    required this.caption,
    required this.screen,
  });

  @override
  Widget build(BuildContext context) {
    const phoneTop = 113.0;
    const bezel = 6.0;
    const screenWidth = 286.7;
    Widget line(String text, Color color) => FittedBox(
          fit: BoxFit.scaleDown,
          child: Text(
            text,
            textDirection: demo.direction,
            style: TextStyle(
              fontFamily: 'Inter_700',
              fontFamilyFallback: demo.fallback,
              fontSize: 28,
              height: 1.2,
              color: color,
            ),
          ),
        );
    return Directionality(
      textDirection: TextDirection.ltr,
      child: SizedBox.fromSize(
        size: _shotSize,
        child: Stack(
          children: [
            const Positioned.fill(child: ColoredBox(color: Colors.black)),
            const Positioned.fill(
              child: DecoratedBox(
                decoration: BoxDecoration(
                  gradient: RadialGradient(
                    center: Alignment(0, -1.1),
                    radius: 0.75,
                    colors: [Color(0x55E39A1C), Color(0x00E39A1C)],
                  ),
                ),
              ),
            ),
            Positioned(
              left: 12,
              right: 12,
              top: 20,
              child: Column(
                children: [
                  line(caption[0], Colors.white),
                  line(caption[1], _goldLight),
                ],
              ),
            ),
            Positioned(
              top: phoneTop,
              left: (_shotSize.width - screenWidth) / 2 - bezel,
              width: screenWidth + bezel * 2,
              bottom: 0,
              child: Container(
                padding: const EdgeInsets.fromLTRB(bezel, bezel, bezel, 0),
                decoration: const BoxDecoration(
                  color: Color(0xFF2A2A2E),
                  borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
                ),
                child: ClipRRect(
                  borderRadius:
                      const BorderRadius.vertical(top: Radius.circular(18.7)),
                  child: OverflowBox(
                    alignment: Alignment.topLeft,
                    minWidth: 0,
                    minHeight: 0,
                    maxWidth: double.infinity,
                    maxHeight: double.infinity,
                    child: Transform.scale(
                      scale: screenWidth / _screenSize.width,
                      alignment: Alignment.topLeft,
                      child: screen,
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// Öne çıkan grafik (1024x500): solda logo, sağda uygulama adı ve alt yazı.
class _Feature extends StatelessWidget {
  final _Demo demo;

  const _Feature({required this.demo});

  @override
  Widget build(BuildContext context) {
    TextStyle style(String family, double size, Color color) => TextStyle(
          fontFamily: family,
          fontFamilyFallback: demo.fallback,
          fontSize: size,
          color: color,
        );
    return Directionality(
      textDirection: TextDirection.ltr,
      child: SizedBox.fromSize(
        size: _featureSize,
        child: Stack(
          children: [
            const Positioned.fill(child: ColoredBox(color: Colors.black)),
            const Positioned.fill(
              child: DecoratedBox(
                decoration: BoxDecoration(
                  gradient: RadialGradient(
                    center: Alignment(-0.5, 0),
                    radius: 0.55,
                    colors: [Color(0x40E39A1C), Color(0x00E39A1C)],
                  ),
                ),
              ),
            ),
            const Positioned(
              left: 60,
              top: 60,
              width: 380,
              height: 380,
              child: CustomPaint(painter: _CoinPainter()),
            ),
            Positioned(
              left: 470,
              right: 40,
              top: 150,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  FittedBox(
                    fit: BoxFit.scaleDown,
                    child: Text(
                      demo.appName,
                      textDirection: demo.direction,
                      style: style('Inter_700', 84, Colors.white),
                    ),
                  ),
                  const SizedBox(height: 14),
                  Container(
                    width: 100,
                    height: 8,
                    decoration: BoxDecoration(
                      color: _gold,
                      borderRadius: BorderRadius.circular(4),
                    ),
                  ),
                  const SizedBox(height: 22),
                  FittedBox(
                    fit: BoxFit.scaleDown,
                    child: Text(
                      demo.feature,
                      textDirection: demo.direction,
                      style: style('Inter_regular', 36, const Color(0xFFC9C2B0)),
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
}

/// assets/icon/logo.svg ile aynı geometri: altın halka + taç (512 birim).
class _CoinPainter extends CustomPainter {
  const _CoinPainter();

  @override
  void paint(Canvas canvas, Size size) {
    final k = size.width / 512;
    final shader = const LinearGradient(
      colors: [_goldLight, _gold],
      begin: Alignment.topLeft,
      end: Alignment.bottomRight,
    ).createShader(Offset.zero & size);
    canvas.drawCircle(
      Offset(256 * k, 256 * k),
      150 * k,
      Paint()
        ..shader = shader
        ..style = PaintingStyle.stroke
        ..strokeWidth = 34 * k,
    );
    final crown = Path()
      ..moveTo(186 * k, 300 * k)
      ..lineTo(186 * k, 214 * k)
      ..lineTo(221 * k, 244 * k)
      ..lineTo(256 * k, 196 * k)
      ..lineTo(291 * k, 244 * k)
      ..lineTo(326 * k, 214 * k)
      ..lineTo(326 * k, 300 * k)
      ..close();
    canvas.drawPath(crown, Paint()..shader = shader);
    canvas.drawPath(
      crown,
      Paint()
        ..shader = shader
        ..style = PaintingStyle.stroke
        ..strokeWidth = 16 * k
        ..strokeJoin = StrokeJoin.round,
    );
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
