import 'dart:io';
import 'dart:convert';

void main() {
  final dir = Directory('lib/l10n');
  final files = dir.listSync().whereType<File>().where(
    (f) => f.path.endsWith('.arb'),
  );

  final additions = {
    'de': {
      'paymentHistory': 'Zahlungshistorie',
      'noPaymentsYet': 'Noch keine Zahlungen',
      'payment': 'Zahlung',
    },
    'es': {
      'paymentHistory': 'Historial de pagos',
      'noPaymentsYet': 'Aún no hay pagos',
      'payment': 'Pago',
    },
    'fr': {
      'paymentHistory': 'Historique des paiements',
      'noPaymentsYet': 'Aucun paiement pour le moment',
      'payment': 'Paiement',
    },
    'it': {
      'paymentHistory': 'Cronologia pagamenti',
      'noPaymentsYet': 'Nessun pagamento ancora',
      'payment': 'Pagamento',
    },
    'pt': {
      'paymentHistory': 'Histórico de pagamentos',
      'noPaymentsYet': 'Ainda sem pagamentos',
      'payment': 'Pagamento',
    },
    'ru': {
      'paymentHistory': 'История платежей',
      'noPaymentsYet': 'Платежей пока нет',
      'payment': 'Платеж',
    },
    'ja': {
      'paymentHistory': '支払い履歴',
      'noPaymentsYet': '支払いはまだありません',
      'payment': '支払い',
    },
    'ko': {
      'paymentHistory': '결제 내역',
      'noPaymentsYet': '아직 결제 없음',
      'payment': '결제',
    },
    'zh': {'paymentHistory': '支付历史', 'noPaymentsYet': '尚无支付', 'payment': '支付'},
    'ar': {
      'paymentHistory': 'سجل الدفعات',
      'noPaymentsYet': 'لا توجد دفعات بعد',
      'payment': 'دفعة',
    },
    'id': {
      'paymentHistory': 'Riwayat Pembayaran',
      'noPaymentsYet': 'Belum ada pembayaran',
      'payment': 'Pembayaran',
    },
  };

  for (final file in files) {
    final filename = file.path.split(Platform.pathSeparator).last;
    final locale = filename.replaceAll('app_', '').replaceAll('.arb', '');

    if (locale == 'en' || locale == 'tr') continue;

    print('Processing $locale...');

    try {
      final content = file.readAsStringSync();
      final Map<String, dynamic> json = jsonDecode(content);

      if (additions.containsKey(locale)) {
        json.addAll(additions[locale]!);
        const encoder = JsonEncoder.withIndent('    ');
        file.writeAsStringSync(encoder.convert(json));
        print('Updated $locale');
      } else {
        print('Skipping $locale (no translations defined)');
      }
    } catch (e) {
      print('Error processing $locale: $e');
    }
  }
}
