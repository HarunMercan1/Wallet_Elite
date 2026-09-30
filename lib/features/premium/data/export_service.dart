// lib/features/premium/data/export_service.dart

import 'dart:convert';
import 'dart:io';

import 'package:intl/intl.dart';
import 'package:path_provider/path_provider.dart';
import 'package:share_plus/share_plus.dart';

import '../../../core/utils/category_l10n.dart';
import '../../../l10n/app_localizations.dart';
import '../../wallet/models/account_model.dart';
import '../../wallet/models/category_model.dart';
import '../../wallet/models/transaction_model.dart';

/// İşlemleri Excel'de doğrudan açılan bir CSV dosyası olarak paylaşır.
/// - UTF-8 BOM: Excel Türkçe karakterleri doğru gösterir
/// - `sep=;` + noktalı virgül: Excel'in bölgesel ayarından bağımsız sütunlara ayırır
/// - Tutarlar kullanıcının dil biçiminde (TR: 1234,50) yazılır
class ExportService {
  static Future<void> shareTransactionsCsv({
    required List<TransactionModel> transactions,
    required List<AccountModel> accounts,
    required List<CategoryModel> categories,
    required AppLocalizations l,
    required String localeCode,
  }) async {
    final accountNames = {for (final a in accounts) a.id: a.name};
    final categoriesById = {for (final c in categories) c.id: c};
    final dateFormat = DateFormat('yyyy-MM-dd HH:mm');
    final amountFormat = NumberFormat('0.00', localeCode);

    final sorted = [...transactions]..sort((a, b) => b.date.compareTo(a.date));

    final buffer = StringBuffer()
      ..write('sep=;\r\n')
      ..write(
        _row([
          l.date,
          l.transactionTypeLabel,
          l.amount,
          l.category,
          l.wallet,
          l.description,
        ]),
      );

    for (final t in sorted) {
      buffer.write(
        _row([
          dateFormat.format(t.date),
          t.isIncome ? l.income : l.expense,
          amountFormat.format(t.amount),
          localizedCategoryName(categoriesById[t.categoryId], l) ?? '',
          accountNames[t.accountId] ?? '',
          t.description ?? '',
        ]),
      );
    }

    final dir = await getTemporaryDirectory();
    final stamp = DateFormat('yyyyMMdd_HHmm').format(DateTime.now());
    final file = File('${dir.path}/wallet_elite_$stamp.csv');
    // ﻿ = UTF-8 BOM
    await file.writeAsBytes(utf8.encode('﻿${buffer.toString()}'));

    await SharePlus.instance.share(
      ShareParams(
        files: [XFile(file.path, mimeType: 'text/csv')],
        subject: 'Wallet Elite',
      ),
    );
  }

  static String _row(List<String> cells) =>
      '${cells.map(_escape).join(';')}\r\n';

  static String _escape(String raw) {
    // Excel'in =,+,-,@ ile başlayan hücreleri formül olarak çalıştırmasını engelle
    final value = raw.isNotEmpty && '=+-@'.contains(raw[0]) ? "'$raw" : raw;
    final needsQuotes =
        value.contains(';') ||
        value.contains('"') ||
        value.contains('\n') ||
        value.contains('\r');
    final escaped = value.replaceAll('"', '""');
    return needsQuotes ? '"$escaped"' : escaped;
  }
}
