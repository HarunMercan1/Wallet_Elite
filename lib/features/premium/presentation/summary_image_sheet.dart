// lib/features/premium/presentation/summary_image_sheet.dart

import 'dart:io';
import 'dart:typed_data';
import 'dart:ui' as ui;

import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:gal/gal.dart';
import 'package:intl/intl.dart';
import 'package:path_provider/path_provider.dart';
import 'package:share_plus/share_plus.dart';

import '../../../core/theme/app_colors.dart';
import '../../../core/utils/category_l10n.dart';
import '../../../core/widgets/app_logo.dart';
import '../../../core/utils/currency_utils.dart';
import '../../../l10n/app_localizations.dart';
import '../../settings/data/settings_provider.dart';
import '../../wallet/data/wallet_provider.dart';
import '../../wallet/models/category_model.dart';
import '../../wallet/models/transaction_model.dart';

/// Bu ayın özetini (gelir, gider, net, en çok harcanan kategoriler) tek bir
/// görsel olarak gösterir; görsel galeriye kaydedilebilir veya paylaşılabilir.
Future<void> showSummaryImageSheet(BuildContext context) {
  return showModalBottomSheet(
    context: context,
    isScrollControlled: true,
    backgroundColor: Colors.transparent,
    builder: (_) => const SummaryImageSheet(),
  );
}

class SummaryImageSheet extends ConsumerStatefulWidget {
  const SummaryImageSheet({super.key});

  @override
  ConsumerState<SummaryImageSheet> createState() => _SummaryImageSheetState();
}

class _SummaryImageSheetState extends ConsumerState<SummaryImageSheet> {
  final _captureKey = GlobalKey();
  bool _busy = false;
  String? _message;
  bool _messageIsError = false;

  /// Önizlemedeki kartı PNG olarak yakalar (3x çözünürlük)
  Future<Uint8List> _capture() async {
    final boundary =
        _captureKey.currentContext!.findRenderObject()!
            as RenderRepaintBoundary;
    final image = await boundary.toImage(pixelRatio: 3);
    final data = await image.toByteData(format: ui.ImageByteFormat.png);
    image.dispose();
    return data!.buffer.asUint8List();
  }

  String get _fileName =>
      'wallet_elite_${DateFormat('yyyyMMdd_HHmm').format(DateTime.now())}';

  Future<void> _run(
    Future<String?> Function(AppLocalizations l) action,
    String Function(AppLocalizations l) failure,
  ) async {
    if (_busy) return;
    final l = AppLocalizations.of(context)!;
    setState(() {
      _busy = true;
      _message = null;
    });
    String? message;
    var isError = false;
    try {
      message = await action(l);
    } catch (e) {
      debugPrint('Özet görseli işlemi başarısız: $e');
      message = failure(l);
      isError = true;
    }
    if (!mounted) return;
    setState(() {
      _busy = false;
      _message = message;
      _messageIsError = isError;
    });
  }

  Future<void> _saveToGallery() => _run((l) async {
    final bytes = await _capture();
    if (!await Gal.hasAccess() && !await Gal.requestAccess()) {
      throw const FileSystemException('Gallery access denied');
    }
    await Gal.putImageBytes(bytes, name: _fileName);
    return l.imageSaved;
  }, (l) => l.imageSaveFailed);

  Future<void> _share() => _run((l) async {
    final bytes = await _capture();
    final dir = await getTemporaryDirectory();
    final file = File('${dir.path}/$_fileName.png');
    await file.writeAsBytes(bytes);
    await SharePlus.instance.share(
      ShareParams(
        files: [XFile(file.path, mimeType: 'image/png')],
        subject: 'Wallet Elite',
      ),
    );
    return null;
  }, (l) => l.exportFailed);

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context)!;
    final colors = context.colors;
    final transactions = ref.watch(transactionsProvider);
    final categories =
        ref.watch(categoriesProvider).valueOrNull ?? const <CategoryModel>[];
    final currencySymbol = CurrencyUtils.getSymbol(ref.watch(currencyProvider));
    final localeCode = ref.watch(localeProvider);

    return Container(
      constraints: BoxConstraints(
        maxHeight: MediaQuery.sizeOf(context).height * 0.92,
      ),
      decoration: BoxDecoration(
        color: colors.cardColor,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
      ),
      child: SafeArea(
        top: false,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const SizedBox(height: 12),
            Container(
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                color: colors.outline,
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 14, 20, 12),
              child: Text(
                l.summaryImage,
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: colors.textPrimary,
                ),
              ),
            ),
            Flexible(
              child: SingleChildScrollView(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: transactions.when(
                  data: (list) => Center(
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(20),
                      child: RepaintBoundary(
                        key: _captureKey,
                        child: MonthlySummaryCard(
                          transactions: list,
                          categories: categories,
                          currencySymbol: currencySymbol,
                          localeCode: localeCode,
                        ),
                      ),
                    ),
                  ),
                  loading: () => const Padding(
                    padding: EdgeInsets.all(48),
                    child: Center(child: CircularProgressIndicator()),
                  ),
                  error: (_, _) => Padding(
                    padding: const EdgeInsets.all(48),
                    child: Text(l.error),
                  ),
                ),
              ),
            ),
            if (_message != null)
              Padding(
                padding: const EdgeInsets.fromLTRB(20, 10, 20, 0),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(
                      _messageIsError
                          ? Icons.error_outline
                          : Icons.check_circle_outline,
                      size: 18,
                      color: _messageIsError ? colors.error : colors.success,
                    ),
                    const SizedBox(width: 6),
                    Flexible(
                      child: Text(
                        _message!,
                        style: TextStyle(
                          fontSize: 13,
                          fontWeight: FontWeight.w600,
                          color: _messageIsError
                              ? colors.error
                              : colors.success,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 12, 16, 12),
              child: Row(
                children: [
                  Expanded(
                    child: SizedBox(
                      height: 50,
                      child: OutlinedButton.icon(
                        onPressed: _busy || !transactions.hasValue
                            ? null
                            : _share,
                        icon: const Icon(Icons.share_rounded, size: 18),
                        label: FittedBox(child: Text(l.share)),
                      ),
                    ),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: SizedBox(
                      height: 50,
                      child: ElevatedButton.icon(
                        onPressed: _busy || !transactions.hasValue
                            ? null
                            : _saveToGallery,
                        icon: _busy
                            ? SizedBox(
                                width: 16,
                                height: 16,
                                child: CircularProgressIndicator(
                                  strokeWidth: 2,
                                  color: colors.textSecondary,
                                ),
                              )
                            : const Icon(Icons.download_rounded, size: 18),
                        label: FittedBox(child: Text(l.saveToGallery)),
                        style: ElevatedButton.styleFrom(
                          padding: const EdgeInsets.symmetric(horizontal: 12),
                        ),
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
}

/// Görsele dönüştürülen kart. Etkin temanın renkleriyle çizilir.
class MonthlySummaryCard extends StatelessWidget {
  final List<TransactionModel> transactions;
  final List<CategoryModel> categories;
  final String currencySymbol;
  final String localeCode;

  const MonthlySummaryCard({
    super.key,
    required this.transactions,
    required this.categories,
    required this.currencySymbol,
    required this.localeCode,
  });

  static const int _maxCategories = 4;

  String _money(double value) {
    final formatted = NumberFormat('#,##0.00', 'tr_TR').format(value.abs());
    return '${value < 0 ? '-' : ''}$currencySymbol$formatted';
  }

  @override
  Widget build(BuildContext context) {
    final c = context.colors;
    final l = AppLocalizations.of(context)!;
    final now = DateTime.now();

    var income = 0.0;
    var expense = 0.0;
    var count = 0;
    final expenseByCategory = <String?, double>{};
    for (final t in transactions) {
      if (t.date.year != now.year || t.date.month != now.month) continue;
      if (t.isIncome) {
        income += t.amount;
        count++;
      } else if (t.isExpense) {
        expense += t.amount;
        count++;
        expenseByCategory[t.categoryId] =
            (expenseByCategory[t.categoryId] ?? 0) + t.amount;
      }
    }
    final net = income - expense;
    final topCategories = expenseByCategory.entries.toList()
      ..sort((a, b) => b.value.compareTo(a.value));
    final categoriesById = {for (final cat in categories) cat.id: cat};
    final barColors = [c.primary, c.tertiary, c.warning, c.info];

    return Container(
      width: 340,
      padding: const EdgeInsets.all(18),
      color: c.background,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          // Başlık
          Row(
            children: [
              const AppLogo(size: 34),
              const SizedBox(width: 10),
              Expanded(
                child: Text(
                  'Wallet Elite',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w800,
                    color: c.textPrimary,
                  ),
                ),
              ),
              Text(
                DateFormat.yMMMM(localeCode).format(now),
                style: TextStyle(
                  fontSize: 12.5,
                  fontWeight: FontWeight.w600,
                  color: c.textSecondary,
                ),
              ),
            ],
          ),
          const SizedBox(height: 14),

          // Net durum
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [c.primary, c.primaryLight],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              borderRadius: BorderRadius.circular(18),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  l.balance,
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                    color: c.onPrimary.withValues(alpha: 0.85),
                  ),
                ),
                const SizedBox(height: 2),
                FittedBox(
                  fit: BoxFit.scaleDown,
                  alignment: Alignment.centerLeft,
                  child: Text(
                    _money(net),
                    style: TextStyle(
                      fontSize: 28,
                      fontWeight: FontWeight.w800,
                      letterSpacing: -0.5,
                      color: c.onPrimary,
                    ),
                  ),
                ),
                const SizedBox(height: 12),
                Row(
                  children: [
                    Expanded(
                      child: _stat(
                        c,
                        l.income,
                        _money(income),
                        Icons.arrow_upward_rounded,
                        c.success,
                      ),
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: _stat(
                        c,
                        l.expense,
                        _money(expense),
                        Icons.arrow_downward_rounded,
                        c.error,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          const SizedBox(height: 10),

          // Küçük bilgi kutuları
          Row(
            children: [
              Expanded(
                child: _infoTile(
                  c,
                  l.transactions,
                  '$count',
                  Icons.receipt_long_outlined,
                  c.info,
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: _infoTile(
                  c,
                  l.averageDailySpending,
                  _money(expense / now.day),
                  Icons.calendar_today_outlined,
                  c.warning,
                ),
              ),
            ],
          ),

          // En çok harcanan kategoriler
          if (topCategories.isNotEmpty) ...[
            const SizedBox(height: 10),
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(14),
              decoration: BoxDecoration(
                color: c.cardColor,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: c.outline),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    l.topCategories,
                    style: TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.w700,
                      color: c.textPrimary,
                    ),
                  ),
                  for (
                    var i = 0;
                    i < topCategories.length && i < _maxCategories;
                    i++
                  )
                    _categoryRow(
                      c,
                      localizedCategoryName(
                            categoriesById[topCategories[i].key],
                            l,
                          ) ??
                          l.cat_other,
                      topCategories[i].value,
                      expense,
                      barColors[i % barColors.length],
                    ),
                ],
              ),
            ),
          ],
          const SizedBox(height: 12),
          Center(
            child: Text(
              'Wallet Elite · ${DateFormat('dd.MM.yyyy').format(now)}',
              style: TextStyle(fontSize: 10.5, color: c.textMuted),
            ),
          ),
        ],
      ),
    );
  }

  Widget _stat(
    ColorTheme c,
    String label,
    String value,
    IconData icon,
    Color iconColor,
  ) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
      decoration: BoxDecoration(
        color: c.onPrimary.withValues(alpha: 0.14),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        children: [
          Container(
            width: 24,
            height: 24,
            decoration: const BoxDecoration(
              color: Colors.white,
              shape: BoxShape.circle,
            ),
            child: Icon(icon, size: 14, color: iconColor),
          ),
          const SizedBox(width: 7),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    fontSize: 10,
                    color: c.onPrimary.withValues(alpha: 0.8),
                  ),
                ),
                FittedBox(
                  fit: BoxFit.scaleDown,
                  alignment: Alignment.centerLeft,
                  child: Text(
                    value,
                    style: TextStyle(
                      fontSize: 12.5,
                      fontWeight: FontWeight.bold,
                      color: c.onPrimary,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _infoTile(
    ColorTheme c,
    String label,
    String value,
    IconData icon,
    Color color,
  ) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: c.cardColor,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: c.outline),
      ),
      child: Row(
        children: [
          Container(
            width: 32,
            height: 32,
            decoration: BoxDecoration(
              color: color.withValues(alpha: 0.14),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Icon(icon, size: 17, color: color),
          ),
          const SizedBox(width: 9),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(fontSize: 10.5, color: c.textSecondary),
                ),
                Text(
                  value,
                  style: TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.w800,
                    color: c.textPrimary,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _categoryRow(
    ColorTheme c,
    String name,
    double amount,
    double totalExpense,
    Color barColor,
  ) {
    final share = totalExpense > 0 ? amount / totalExpense : 0.0;
    return Padding(
      padding: const EdgeInsets.only(top: 10),
      child: Column(
        children: [
          Row(
            children: [
              Expanded(
                child: Text(
                  name,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                    color: c.textPrimary,
                  ),
                ),
              ),
              Text(
                '${_money(amount)}  ·  %${(share * 100).toStringAsFixed(0)}',
                style: TextStyle(fontSize: 11.5, color: c.textSecondary),
              ),
            ],
          ),
          const SizedBox(height: 5),
          ClipRRect(
            borderRadius: BorderRadius.circular(3),
            child: LinearProgressIndicator(
              value: share.clamp(0.0, 1.0),
              minHeight: 6,
              backgroundColor: c.surfaceVariant,
              valueColor: AlwaysStoppedAnimation<Color>(barColor),
            ),
          ),
        ],
      ),
    );
  }
}
