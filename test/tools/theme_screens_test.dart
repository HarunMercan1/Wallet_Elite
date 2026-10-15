// Tema inceleme aracı: her tema × parlaklık için ana ekranları sahte veriyle
// çizer ve PNG olarak kaydeder. Normal test çalıştırmasında atlanır:
//   flutter test test/tools/theme_screens_test.dart --dart-define=SHOTS=<klasör>
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
import 'package:shared_preferences/shared_preferences.dart';
import 'package:supabase_flutter/supabase_flutter.dart' hide User;
import 'package:wallet_elite/core/ads/ads_providers.dart';
import 'package:wallet_elite/core/services/app_update_service.dart';
import 'package:wallet_elite/core/theme/app_colors.dart';
import 'package:wallet_elite/core/theme/app_theme.dart';
import 'package:wallet_elite/core/theme/color_theme_provider.dart';
import 'package:wallet_elite/features/auth/data/auth_provider.dart';
import 'package:wallet_elite/features/home/presentation/dashboard_view.dart';
import 'package:wallet_elite/features/premium/data/premium_provider.dart';
import 'package:wallet_elite/features/recurring/data/recurring_provider.dart';
import 'package:wallet_elite/features/settings/data/preferences_sync.dart';
import 'package:wallet_elite/features/settings/data/settings_provider.dart';
import 'package:wallet_elite/features/settings/presentation/settings_view.dart';
import 'package:wallet_elite/features/statistics/presentation/statistics_view.dart';
import 'package:wallet_elite/features/transactions/presentation/transactions_view.dart';
import 'package:wallet_elite/features/wallet/data/wallet_provider.dart';
import 'package:wallet_elite/features/wallet/models/account_model.dart';
import 'package:wallet_elite/features/wallet/models/category_model.dart';
import 'package:wallet_elite/features/wallet/models/profile_model.dart';
import 'package:wallet_elite/features/wallet/models/transaction_model.dart';
import 'package:wallet_elite/l10n/app_localizations.dart';

const _outDir = String.fromEnvironment('SHOTS');
const _only = String.fromEnvironment('THEMES');
const _screenSize = Size(360, 760);

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
  await load('MaterialIcons', [
    'C:/src/flutter_3_47/flutter/bin/cache/artifacts/material_fonts/MaterialIcons-Regular.otf',
  ]);
}

final _now = DateTime(2026, 10, 14, 12);

List<CategoryModel> _categories() {
  CategoryModel c(String id, String name, String icon, String color, String type) =>
      CategoryModel(
        id: id,
        userId: 'u',
        name: name,
        icon: icon,
        color: color,
        type: type,
        createdAt: _now,
      );
  return [
    c('food', 'Market', 'shopping_cart', '#F97316', 'expense'),
    c('rent', 'Kira', 'home', '#8B5CF6', 'expense'),
    c('fun', 'Eğlence', 'movie', '#EC4899', 'expense'),
    c('bills', 'Faturalar', 'receipt', '#0EA5E9', 'expense'),
    c('salary', 'Maaş', 'work', '#22C55E', 'income'),
  ];
}

List<TransactionModel> _transactions() {
  var n = 0;
  TransactionModel t(String cat, double amount, String type, int daysAgo, String d) =>
      TransactionModel(
        id: 't${n++}',
        userId: 'u',
        accountId: 'a1',
        categoryId: cat,
        amount: amount,
        type: type,
        description: d,
        date: _now.subtract(Duration(days: daysAgo)),
        createdAt: _now,
      );
  return [
    t('food', 842.5, 'expense', 0, 'Migros'),
    t('salary', 42000, 'income', 1, 'Ekim maaşı'),
    t('fun', 320, 'expense', 2, 'Sinema'),
    t('bills', 1180, 'expense', 3, 'Elektrik'),
    t('rent', 15000, 'expense', 5, 'Ekim kirası'),
    t('food', 410, 'expense', 7, 'Pazar'),
    t('fun', 650, 'expense', 9, 'Konser'),
    t('bills', 560, 'expense', 12, 'İnternet'),
    t('salary', 40000, 'income', 31, 'Eylül maaşı'),
    t('rent', 15000, 'expense', 35, 'Eylül kirası'),
    t('food', 2600, 'expense', 40, 'Market'),
  ];
}

Widget _screen(ColorTheme theme, Brightness brightness, Widget child,
    SharedPreferences prefs) {
  return SizedBox.fromSize(
    size: _screenSize,
    child: ProviderScope(
      overrides: [
        sharedPreferencesProvider.overrideWithValue(prefs),
        currentColorThemeProvider.overrideWithValue(theme),
        currentUserIdProvider.overrideWithValue('u'),
        userProfileProvider.overrideWith(
          (ref) async => ProfileModel(id: 'u', fullName: 'Harun Mercan'),
        ),
        accountsProvider.overrideWith(
          (ref) async => [
            AccountModel(
              id: 'a1',
              userId: 'u',
              name: 'Nakit',
              type: 'cash',
              balance: 48250.75,
              currency: 'TRY',
              createdAt: _now,
            ),
          ],
        ),
        transactionsProvider.overrideWith((ref) async => _transactions()),
        categoriesProvider.overrideWith((ref) async => _categories()),
        isPremiumProvider.overrideWithValue(false),
        recurringStartupRunProvider.overrideWith((ref) async => 0),
        adConsentStartupProvider.overrideWith((ref) async {}),
        appUpdateInfoProvider.overrideWith((ref) async => null),
        preferencesRestoreProvider.overrideWith((ref) async {}),
        showAdsProvider.overrideWithValue(false),
      ],
      child: MaterialApp(
        debugShowCheckedModeBanner: false,
        locale: const Locale('tr'),
        localizationsDelegates: const [
          AppLocalizations.delegate,
          GlobalMaterialLocalizations.delegate,
          GlobalWidgetsLocalizations.delegate,
          GlobalCupertinoLocalizations.delegate,
        ],
        supportedLocales: AppLocalizations.supportedLocales,
        theme: AppTheme.create(colorTheme: theme, brightness: brightness),
        builder: (context, child) => MediaQuery(
          data: MediaQuery.of(context).copyWith(
            size: _screenSize,
            padding: const EdgeInsets.only(top: 24),
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

  testWidgets('theme screens', (tester) async {
    final originalOnError = FlutterError.onError;
    FlutterError.onError = (details) {
      final msg = details.exceptionAsString();
      if (msg.contains('google_fonts') || msg.contains('GoogleFonts')) return;
      if (msg.contains('overflowed')) return;
      if (msg.contains('ListTile background')) return;
      stderr.writeln('ERR: ${msg.split('\n').first}');
      stderr.writeln(details.stack.toString().split('\n').take(8).join('\n'));
    };
    SharedPreferences.setMockInitialValues({});
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
    final prefs = await SharedPreferences.getInstance();

    final width = _screenSize.width * 4 + 40;
    final height = _screenSize.height * 2 + 10;
    tester.view.physicalSize = Size(width, height);
    tester.view.devicePixelRatio = 1;

    Directory(_outDir).createSync(recursive: true);
    final themes = _only.isEmpty
        ? ColorTheme.all
        : ColorTheme.all.where((t) => _only.split(',').contains(t.id));

    for (final base in themes) {
      final key = GlobalKey();
      Widget row(Brightness b) {
        final t = base.forBrightness(b);
        return Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            for (final s in const <Widget>[
              DashboardView(),
              TransactionsView(),
              StatisticsView(),
              SettingsView(),
            ]) ...[
              _screen(t, b, s, prefs),
              const SizedBox(width: 10),
            ],
          ],
        );
      }

      await tester.pumpWidget(
        Directionality(
          textDirection: TextDirection.ltr,
          child: RepaintBoundary(
            key: key,
            child: ColoredBox(
              color: const Color(0xFF808080),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  row(Brightness.dark),
                  const SizedBox(height: 10),
                  row(Brightness.light),
                ],
              ),
            ),
          ),
        ),
      );
      for (var i = 0; i < 30; i++) {
        await tester.pump(const Duration(milliseconds: 100));
      }
      await tester.runAsync(() async {
        final boundary =
            key.currentContext!.findRenderObject()! as RenderRepaintBoundary;
        final image = await boundary.toImage(pixelRatio: 1);
        final bytes = await image.toByteData(format: ui.ImageByteFormat.png);
        File('$_outDir/${base.id}.png')
            .writeAsBytesSync(bytes!.buffer.asUint8List());
      });
    }
    await tester.pumpWidget(const SizedBox());
    await tester.pump(const Duration(seconds: 10));
    FlutterError.onError = originalOnError;
  });
}
