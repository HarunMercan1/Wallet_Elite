// Mağaza ekran görüntüsü aracı: ana ekranları demo veriyle her dil için
// 1080x2280 PNG olarak çizer. Çerçeve ve başlıkları tool/gen_store_shots.py ekler.
// Normal test çalıştırmasında atlanır:
//   flutter test test/tools/store_screens_test.dart --dart-define=SHOTS=<klasör>
library;

import 'dart:io';
import 'dart:ui' as ui;

import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter/services.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
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
const _screenSize = Size(360, 760);
const _pixelRatio = 3.0;

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
  await load('MaterialIcons', [
    'C:/src/flutter_3_47/flutter/bin/cache/artifacts/material_fonts/MaterialIcons-Regular.otf',
  ]);
}

final _now = DateTime(2026, 10, 18, 12);

/// Dile göre demo içerik.
class _Demo {
  final String locale;
  final String currency;
  final String name;
  final Map<String, String> words;
  final double scale; // para tutarları için çarpan

  const _Demo(this.locale, this.currency, this.name, this.scale, this.words);

  String w(String key) => words[key]!;
}

const _demos = [
  _Demo('en', 'USD', 'Alex Morgan', 0.1, {
    'cash': 'Cash',
    'bank': 'Bank account',
    'food': 'Groceries',
    'rent': 'Rent',
    'fun': 'Entertainment',
    'bills': 'Bills',
    'transport': 'Transport',
    'salary': 'Salary',
    'freelance': 'Freelance',
    'd_food1': 'Whole Foods',
    'd_salary1': 'October salary',
    'd_fun1': 'Cinema',
    'd_bills1': 'Electricity',
    'd_rent1': 'October rent',
    'd_food2': 'Farmers market',
    'd_transport1': 'Fuel',
    'd_fun2': 'Concert tickets',
    'd_bills2': 'Internet',
    'd_freelance1': 'Logo project',
    'd_salary2': 'September salary',
    'd_rent2': 'September rent',
    'd_food3': 'Groceries',
    'b_food': 'Groceries',
    'b_fun': 'Fun money',
    'b_transport': 'Transport',
    'p1': 'Emma',
    'p2': 'Daniel',
    'p3': 'Sophie',
  }),
  _Demo('tr', 'TRY', 'Elif Yılmaz', 1, {
    'cash': 'Nakit',
    'bank': 'Banka hesabı',
    'food': 'Market',
    'rent': 'Kira',
    'fun': 'Eğlence',
    'bills': 'Faturalar',
    'transport': 'Ulaşım',
    'salary': 'Maaş',
    'freelance': 'Serbest iş',
    'd_food1': 'Migros',
    'd_salary1': 'Ekim maaşı',
    'd_fun1': 'Sinema',
    'd_bills1': 'Elektrik',
    'd_rent1': 'Ekim kirası',
    'd_food2': 'Pazar',
    'd_transport1': 'Benzin',
    'd_fun2': 'Konser bileti',
    'd_bills2': 'İnternet',
    'd_freelance1': 'Logo projesi',
    'd_salary2': 'Eylül maaşı',
    'd_rent2': 'Eylül kirası',
    'd_food3': 'Market alışverişi',
    'b_food': 'Market',
    'b_fun': 'Eğlence',
    'b_transport': 'Ulaşım',
    'p1': 'Ayşe',
    'p2': 'Mehmet',
    'p3': 'Zeynep',
  }),
];

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

/// Test ortamında sistem emoji fontu yok; 👑 gibi glifler Segoe UI Emoji'den gelsin.
ThemeData _withEmoji(ThemeData t) => t.copyWith(
      textTheme: t.textTheme.apply(fontFamilyFallback: const ['Emoji']),
      primaryTextTheme:
          t.primaryTextTheme.apply(fontFamilyFallback: const ['Emoji']),
    );

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
        theme: _withEmoji(
          AppTheme.create(colorTheme: theme, brightness: Brightness.dark),
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

    tester.view.physicalSize = _screenSize * _pixelRatio;
    tester.view.devicePixelRatio = _pixelRatio;

    const screens = <String, Widget>{
      '01_home': DashboardView(),
      '02_transactions': TransactionsView(),
      '03_statistics': StatisticsView(),
      '04_budgets': BudgetsView(),
      '05_debts': DebtsView(),
    };

    for (final d in _demos) {
      Intl.defaultLocale = d.locale; // main.dart'taki gibi
      SharedPreferences.resetStatic();
      SharedPreferences.setMockInitialValues({
        'currency': d.currency,
        'locale': d.locale,
      });
      final prefs = await SharedPreferences.getInstance();
      final dir = Directory('$_outDir/${d.locale}')..createSync(recursive: true);
      for (final entry in screens.entries) {
        final key = GlobalKey();
        await tester.pumpWidget(
          RepaintBoundary(key: key, child: _screen(d, entry.value, prefs)),
        );
        for (var i = 0; i < 40; i++) {
          await tester.pump(const Duration(milliseconds: 100));
        }
        await tester.runAsync(() async {
          final boundary =
              key.currentContext!.findRenderObject()! as RenderRepaintBoundary;
          final image = await boundary.toImage(pixelRatio: _pixelRatio);
          final bytes = await image.toByteData(format: ui.ImageByteFormat.png);
          File('${dir.path}/${entry.key}.png')
              .writeAsBytesSync(bytes!.buffer.asUint8List());
        });
        await tester.pumpWidget(const SizedBox());
        await tester.pump(const Duration(seconds: 1));
      }
    }
    await tester.pump(const Duration(seconds: 10));
    FlutterError.onError = originalOnError;
  });
}
