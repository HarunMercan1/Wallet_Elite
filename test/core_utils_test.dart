import 'package:flutter_test/flutter_test.dart';
import 'package:intl/intl.dart';
import 'package:wallet_elite/core/utils/app_languages.dart';
import 'package:wallet_elite/core/utils/currency_utils.dart';
import 'package:wallet_elite/core/utils/number_utils.dart';
import 'package:wallet_elite/l10n/app_localizations.dart';

void main() {
  test('every translated language can be picked in the app', () {
    final translated = AppLocalizations.supportedLocales
        .map((locale) => locale.languageCode)
        .toSet();
    final selectable = appLanguages.map((language) => language.code).toSet();
    expect(selectable, translated);
  });

  test('default language follows the device, falling back to English', () {
    expect(defaultLanguageFor('tr'), 'tr');
    expect(defaultLanguageFor('de'), 'de');
    expect(defaultLanguageFor('sv'), 'en');
  });

  test('language names', () {
    expect(appLanguageName('tr'), 'Türkçe');
    expect(appLanguageName('pl'), 'Polski');
    expect(appLanguageName('xx'), 'XX');
  });

  test('currencies offered during onboarding have a symbol', () {
    expect(CurrencyUtils.getSymbol('TRY'), '₺');
    expect(CurrencyUtils.getSymbol('JPY'), '¥');
    expect(CurrencyUtils.getSymbol('RUB'), '₽');
    expect(CurrencyUtils.getSymbol('CHF'), 'CHF ');
  });

  test('percent follows the app language', () {
    final previous = Intl.defaultLocale;
    addTearDown(() => Intl.defaultLocale = previous);

    Intl.defaultLocale = 'tr';
    expect(formatPercent(12), '%12');
    expect(formatPercent(12.5, decimals: 1), '%12,5');

    Intl.defaultLocale = 'en';
    expect(formatPercent(12), '12%');
    expect(formatPercent(0), '0%');
  });

  test('dateOnly drops the time of day', () {
    expect(dateOnly(DateTime(2026, 10, 13, 16, 41)), DateTime(2026, 10, 13));
  });
}
