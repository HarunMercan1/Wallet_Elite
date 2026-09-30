import 'package:flutter_test/flutter_test.dart';
import 'package:wallet_elite/core/utils/date_utils.dart';
import 'package:wallet_elite/features/wallet/models/transaction_model.dart';

void main() {
  group('parseWallClock', () {
    test(
      'keeps the wall-clock value the app wrote (UTC echo from Postgres)',
      () {
        final d = parseWallClock('2026-09-30T23:30:00+00:00');
        expect(d.isUtc, isFalse);
        expect(d, DateTime(2026, 9, 30, 23, 30));
      },
    );

    test('late-evening transaction stays in its own month', () {
      final d = parseWallClock('2026-09-30T23:30:00+00:00');
      final octoberStart = DateTime(2026, 10, 1);
      expect(d.isBefore(octoberStart), isTrue);
    });

    test('value without offset is returned as local', () {
      expect(
        parseWallClock('2026-09-30T08:15:00'),
        DateTime(2026, 9, 30, 8, 15),
      );
    });

    test('round-trips what the app writes', () {
      final picked = DateTime(2026, 2, 28, 21, 45);
      // App writes local ISO string; Postgres returns it with +00:00
      final echoed = '${picked.toIso8601String()}+00:00';
      expect(parseWallClock(echoed), picked);
    });
  });

  test('TransactionModel.fromJson parses date as wall clock', () {
    final t = TransactionModel.fromJson({
      'id': 't1',
      'user_id': 'u1',
      'account_id': 'a1',
      'category_id': null,
      'amount': 150,
      'type': 'expense',
      'description': null,
      'date': '2026-09-30T23:30:00+00:00',
      'created_at': '2026-09-30T20:30:05.123+00:00',
    });
    expect(t.date, DateTime(2026, 9, 30, 23, 30));
    expect(t.amount, 150.0);
    expect(t.isExpense, isTrue);
  });
}
