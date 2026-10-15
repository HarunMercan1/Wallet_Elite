// Ekran denetimi: tüm ana ekranları ve alt pencereleri sahte veriyle, normal
// ve küçük telefon (büyük yazı boyutu) koşullarında çizer; taşma ve çalışma
// zamanı hatalarını ekran adıyla raporlar, görüntüleri PNG olarak kaydeder.
//   flutter test test/tools/screen_audit_test.dart --dart-define=SHOTS=<klasör>
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
import 'package:intl/intl.dart' hide TextDirection;
import 'package:shared_preferences/shared_preferences.dart';
import 'package:supabase_flutter/supabase_flutter.dart' hide User;
import 'package:wallet_elite/core/ads/ads_providers.dart';
import 'package:wallet_elite/core/theme/app_colors.dart';
import 'package:wallet_elite/core/theme/app_theme.dart';
import 'package:wallet_elite/core/theme/color_theme_provider.dart';
import 'package:wallet_elite/features/auth/data/auth_provider.dart';
import 'package:wallet_elite/features/budgets/data/budget_provider.dart';
import 'package:wallet_elite/features/budgets/models/budget_model.dart';
import 'package:wallet_elite/features/budgets/presentation/add_budget_sheet.dart';
import 'package:wallet_elite/features/budgets/presentation/budgets_view.dart';
import 'package:wallet_elite/features/debts/presentation/add_debt_sheet.dart';
import 'package:wallet_elite/features/debts/presentation/debt_detail_sheet.dart';
import 'package:wallet_elite/features/debts/presentation/debts_view.dart';
import 'package:wallet_elite/features/home/presentation/dashboard_view.dart';
import 'package:wallet_elite/features/premium/data/premium_provider.dart';
import 'package:wallet_elite/features/premium/presentation/paywall_view.dart';
import 'package:wallet_elite/features/premium/presentation/summary_image_sheet.dart';
import 'package:wallet_elite/features/recurring/data/recurring_provider.dart';
import 'package:wallet_elite/features/recurring/models/recurring_transaction_model.dart';
import 'package:wallet_elite/features/recurring/presentation/add_recurring_sheet.dart';
import 'package:wallet_elite/features/recurring/presentation/recurring_transactions_view.dart';
import 'package:wallet_elite/features/settings/data/settings_provider.dart';
import 'package:wallet_elite/features/settings/presentation/settings_view.dart';
import 'package:wallet_elite/features/settings/presentation/theme_picker_sheet.dart';
import 'package:wallet_elite/features/statistics/presentation/category_analysis_view.dart';
import 'package:wallet_elite/features/statistics/presentation/month_comparison_view.dart';
import 'package:wallet_elite/features/statistics/presentation/statistics_view.dart';
import 'package:wallet_elite/features/statistics/presentation/trend_detail_view.dart';
import 'package:wallet_elite/features/transactions/presentation/transaction_filter_sheet.dart';
import 'package:wallet_elite/features/transactions/presentation/transaction_filter_state.dart';
import 'package:wallet_elite/features/transactions/presentation/transactions_view.dart';
import 'package:wallet_elite/features/wallet/data/debt_provider.dart';
import 'package:wallet_elite/features/wallet/data/wallet_provider.dart';
import 'package:wallet_elite/features/wallet/models/account_model.dart';
import 'package:wallet_elite/features/wallet/models/category_model.dart';
import 'package:wallet_elite/features/wallet/models/debt_model.dart';
import 'package:wallet_elite/features/wallet/models/profile_model.dart';
import 'package:wallet_elite/features/wallet/models/transaction_model.dart';
import 'package:wallet_elite/features/wallet/presentation/add_transaction_sheet.dart';
import 'package:wallet_elite/features/wallet/presentation/edit_transaction_sheet.dart';
import 'package:wallet_elite/features/wallet/presentation/wallet_selection_sheet.dart';
import 'package:wallet_elite/l10n/app_localizations.dart';

const _outDir = String.fromEnvironment('SHOTS');
const _only = String.fromEnvironment('SCREENS');
const _locale = String.fromEnvironment('LOCALE', defaultValue: 'tr');

final _now = DateTime.now();

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
  await load('Roboto', ['$fonts/segoeui.ttf']);
  await load('MaterialIcons', [
    'C:/src/flutter_3_47/flutter/bin/cache/artifacts/material_fonts/MaterialIcons-Regular.otf',
  ]);
}

final _categories = [
  for (final c in [
    ('food', 'Market', 'shopping_cart', '#F97316', 'expense'),
    ('rent', 'Kira', 'home', '#8B5CF6', 'expense'),
    ('fun', 'Eğlence', 'movie', '#EC4899', 'expense'),
    ('bills', 'Faturalar', 'receipt', '#0EA5E9', 'expense'),
    ('salary', 'Maaş', 'work', '#22C55E', 'income'),
  ])
    CategoryModel(
      id: c.$1,
      userId: 'u',
      name: c.$2,
      icon: c.$3,
      color: c.$4,
      type: c.$5,
      createdAt: _now,
    ),
];

final _transactions = () {
  var n = 0;
  TransactionModel t(String cat, double amount, String type, int days, String d) =>
      TransactionModel(
        id: 't${n++}',
        userId: 'u',
        accountId: 'a1',
        categoryId: cat,
        amount: amount,
        type: type,
        description: d,
        date: _now.subtract(Duration(days: days)),
        createdAt: _now,
      );
  return [
    t('food', 842.5, 'expense', 0, 'Migros'),
    t('salary', 42000, 'income', 1, 'Ekim maaşı'),
    t('fun', 320, 'expense', 2, 'Sinema ve akşam yemeği, uzun bir açıklama'),
    t('bills', 1180, 'expense', 3, 'Elektrik'),
    t('rent', 15000, 'expense', 5, 'Kira'),
    t('food', 410, 'expense', 7, 'Pazar'),
    t('fun', 650, 'expense', 9, 'Konser'),
    t('bills', 560, 'expense', 12, 'İnternet'),
    t('salary', 40000, 'income', 31, 'Eylül maaşı'),
    t('rent', 15000, 'expense', 35, 'Kira'),
    t('food', 2600, 'expense', 40, 'Market'),
    t('salary', 39000, 'income', 62, 'Ağustos maaşı'),
    t('food', 3100, 'expense', 65, 'Market'),
  ];
}();

final _accounts = [
  AccountModel(
    id: 'a1',
    userId: 'u',
    name: 'Nakit',
    type: 'cash',
    balance: 48250.75,
    currency: 'TRY',
    createdAt: _now,
  ),
  AccountModel(
    id: 'a2',
    userId: 'u',
    name: 'Ziraat Bankası Maaş Hesabı',
    type: 'bank',
    balance: 1234567.89,
    currency: 'TRY',
    createdAt: _now,
  ),
];

final _debts = [
  DebtModel(
    id: 'd1',
    userId: 'u',
    personName: 'Ahmet Yılmaz',
    amount: 5000,
    remainingAmount: 2000,
    dueDate: _now.add(const Duration(days: 10)),
    type: 'lend',
    description: 'Tatil için',
    createdAt: _now,
  ),
  DebtModel(
    id: 'd2',
    userId: 'u',
    personName: 'Ayşe',
    amount: 1200,
    remainingAmount: 1200,
    dueDate: _now.subtract(const Duration(days: 3)),
    type: 'borrow',
    createdAt: _now,
  ),
];

final _budgets = [
  BudgetModel(
    id: 'b1',
    userId: 'u',
    name: 'Market bütçesi',
    categoryId: 'food',
    amount: 5000,
    period: BudgetPeriod.monthly,
    createdAt: _now,
    updatedAt: _now,
    categoryName: 'Market',
    categoryIcon: 'shopping_cart',
    spent: 4300,
  ),
  BudgetModel(
    id: 'b2',
    userId: 'u',
    name: 'Eğlence',
    amount: 800,
    period: BudgetPeriod.weekly,
    createdAt: _now,
    updatedAt: _now,
    spent: 970,
  ),
];

final _recurring = [
  RecurringTransactionModel(
    id: 'r1',
    userId: 'u',
    accountId: 'a1',
    categoryId: 'rent',
    amount: 15000,
    type: 'expense',
    description: 'Kira',
    frequency: RecurringFrequency.monthly,
    dayOfMonth: 5,
    startDate: _now.subtract(const Duration(days: 60)),
    nextExecutionDate: _now.add(const Duration(days: 20)),
    createdAt: _now,
    updatedAt: _now,
  ),
];

Map<String, Widget Function()> _screens() => {
  'dashboard': () => const DashboardView(),
  'transactions': () => const TransactionsView(),
  'statistics': () => const StatisticsView(),
  'settings': () => const SettingsView(),
  'budgets': () => const BudgetsView(),
  'debts': () => const DebtsView(),
  'recurring': () => const RecurringTransactionsView(),
  'paywall': () => const PaywallView(),
  'trend': () => TrendDetailView(
    transactions: _transactions,
    allTransactions: _transactions,
    periodLabel: 'Bu Ay',
  ),
  'category_analysis': () =>
      CategoryAnalysisView(transactions: _transactions, periodLabel: 'Bu Ay'),
  'month_comparison': () => MonthComparisonView(
    allTransactions: _transactions,
    categoryMap: {for (final c in _categories) c.id: c},
  ),
  'sheet_add_tx': () => const _Sheet(AddTransactionSheet()),
  'sheet_edit_tx': () => _Sheet(EditTransactionSheet(transaction: _transactions[2])),
  'sheet_filter': () => const _Sheet(
    TransactionFilterSheet(initialState: TransactionFilterState()),
  ),
  'sheet_wallets': () => const _Sheet(WalletSelectionSheet()),
  'sheet_add_budget': () => const _Sheet(AddBudgetSheet()),
  'sheet_add_debt': () => const _Sheet(AddDebtSheet()),
  'sheet_debt_detail': () => _Sheet(DebtDetailSheet(debt: _debts.first)),
  'sheet_add_recurring': () => const _Sheet(AddRecurringSheet()),
  'sheet_theme_picker': () => const _Sheet(ThemePickerSheet()),
  'sheet_summary_image': () => const _Sheet(SummaryImageSheet()),
};

class _Sheet extends StatelessWidget {
  const _Sheet(this.child);
  final Widget child;

  @override
  Widget build(BuildContext context) => Scaffold(
    backgroundColor: Colors.black54,
    body: Align(alignment: Alignment.bottomCenter, child: child),
  );
}

Widget _app({
  required ColorTheme theme,
  required Brightness brightness,
  required Size size,
  required double textScale,
  required SharedPreferences prefs,
  required Widget child,
}) {
  return SizedBox.fromSize(
    size: size,
    child: ProviderScope(
      overrides: [
        sharedPreferencesProvider.overrideWithValue(prefs),
        currentColorThemeProvider.overrideWithValue(theme),
        currentUserIdProvider.overrideWithValue('u'),
        userProfileProvider.overrideWith(
          (ref) async => ProfileModel(id: 'u', fullName: 'Harun Reşit Mercan'),
        ),
        accountsProvider.overrideWith((ref) async => _accounts),
        transactionsProvider.overrideWith((ref) async => _transactions),
        categoriesProvider.overrideWith((ref) async => _categories),
        expenseCategoriesProvider.overrideWith(
          (ref) async => _categories.where((c) => c.type == 'expense').toList(),
        ),
        incomeCategoriesProvider.overrideWith(
          (ref) async => _categories.where((c) => c.type == 'income').toList(),
        ),
        isPremiumProvider.overrideWithValue(true),
        recurringStartupRunProvider.overrideWith((ref) async => 0),
        adConsentStartupProvider.overrideWith((ref) async {}),
        showAdsProvider.overrideWithValue(false),
        budgetsProvider.overrideWith((ref) async => _budgets),
        activeBudgetsProvider.overrideWith((ref) async => _budgets),
        debtsProvider.overrideWith((ref) async => _debts),
        totalLentProvider.overrideWith((ref) async => 2000),
        totalBorrowedProvider.overrideWith((ref) async => 1200),
        debtPeopleCountProvider.overrideWith((ref) async => 2),
        debtPaymentsProvider.overrideWith((ref, id) async => const []),
        recurringTransactionsProvider.overrideWith((ref) async => _recurring),
        activeRecurringTransactionsProvider.overrideWith(
          (ref) async => _recurring,
        ),
      ],
      child: MaterialApp(
        debugShowCheckedModeBanner: false,
        locale: const Locale(_locale),
        localizationsDelegates: const [
          AppLocalizations.delegate,
          GlobalMaterialLocalizations.delegate,
          GlobalWidgetsLocalizations.delegate,
          GlobalCupertinoLocalizations.delegate,
        ],
        supportedLocales: AppLocalizations.supportedLocales,
        theme: AppTheme.create(colorTheme: theme, brightness: brightness),
        builder: (context, c) => MediaQuery(
          data: MediaQuery.of(context).copyWith(
            size: size,
            padding: const EdgeInsets.only(top: 24, bottom: 16),
            viewPadding: const EdgeInsets.only(top: 24, bottom: 16),
            textScaler: TextScaler.linear(textScale),
          ),
          child: c!,
        ),
        home: child,
      ),
    ),
  );
}

void main() {
  if (_outDir.isEmpty) return;
  GoogleFonts.config.allowRuntimeFetching = false;
  Intl.defaultLocale = _locale;

  const variants = [
    ('normal', Size(360, 760), 1.0),
    ('small', Size(320, 568), 1.3),
  ];

  testWidgets('screen audit', (tester) async {
    final problems = <String>{};
    var current = '';
    final originalOnError = FlutterError.onError;
    FlutterError.onError = (details) {
      final msg = details.exceptionAsString();
      if (msg.contains('google_fonts') || msg.contains('GoogleFonts')) return;
      final first = msg.split('\n').first;
      final where = details.context?.toDescription() ?? '';
      final stack = details.stack
          .toString()
          .split('\n')
          .where((l) => l.contains('package:wallet_elite'))
          .take(3)
          .join(' | ');
      final full = details.toString().split('\n');
      final i = full.indexWhere((l) => l.contains('relevant error-causing'));
      final culprit = i < 0
          ? full
                .where((l) => l.contains('creator:') || l.contains('dart:'))
                .take(2)
                .join(' ')
          : full.skip(i + 1).take(2).join(' ').trim();
      problems.add('[$current] $first :: $where :: $stack :: $culprit');
      if (msg.contains('overflowed')) {
        File('$_outDir/overflow_${current.replaceAll('/', '__')}.txt')
            .writeAsStringSync(details.toString());
      }
    };

    SharedPreferences.setMockInitialValues({});
    await tester.runAsync(_loadFonts);
    await tester.runAsync(() async {
      await Supabase.initialize(
        url: 'http://localhost:1',
        anonKey: 'test',
        authOptions: const FlutterAuthClientOptions(
          localStorage: EmptyLocalStorage(),
          autoRefreshToken: false,
          detectSessionInUri: false,
        ),
      );
    });
    final prefs = await SharedPreferences.getInstance();
    Directory(_outDir).createSync(recursive: true);

    tester.view.devicePixelRatio = 1;
    final screens = _screens().entries.where(
      (e) => _only.isEmpty || _only.split(',').contains(e.key),
    );
    for (final screen in screens) {
      for (final variant in variants) {
        current = '${screen.key}/${variant.$1}';
        final size = variant.$2;
        tester.view.physicalSize = Size(size.width * 2 + 10, size.height);
        final key = GlobalKey();
        await tester.pumpWidget(
          Directionality(
            textDirection: TextDirection.ltr,
            child: RepaintBoundary(
              key: key,
              child: ColoredBox(
                color: const Color(0xFF808080),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    for (final b in [Brightness.dark, Brightness.light]) ...[
                      _app(
                        theme: ColorTheme.midnight.forBrightness(b),
                        brightness: b,
                        size: size,
                        textScale: variant.$3,
                        prefs: prefs,
                        child: screen.value(),
                      ),
                      if (b == Brightness.dark) const SizedBox(width: 10),
                    ],
                  ],
                ),
              ),
            ),
          ),
        );
        for (var i = 0; i < 25; i++) {
          await tester.pump(const Duration(milliseconds: 100));
        }
        await tester.runAsync(() async {
          final boundary =
              key.currentContext!.findRenderObject()! as RenderRepaintBoundary;
          final image = await boundary.toImage();
          final bytes = await image.toByteData(format: ui.ImageByteFormat.png);
          File(
            '$_outDir/${current.replaceAll('/', '__')}.png',
          ).writeAsBytesSync(bytes!.buffer.asUint8List());
        });
        await tester.pumpWidget(const SizedBox());
      }
    }
    await tester.pump(const Duration(seconds: 10));
    FlutterError.onError = originalOnError;
    File('$_outDir/problems.txt').writeAsStringSync(problems.join('\n'));
  });
}
