import 'package:flutter_test/flutter_test.dart';
import 'package:wallet_elite/features/budgets/models/budget_model.dart';

BudgetModel _budget(BudgetPeriod period, {int startDay = 1}) => BudgetModel(
  id: 'b1',
  userId: 'u1',
  name: 'Test',
  amount: 1000,
  period: period,
  startDay: startDay,
  createdAt: DateTime(2026, 1, 1),
  updatedAt: DateTime(2026, 1, 1),
);

void main() {
  group('monthly budget period', () {
    test('start day already reached this month', () {
      final b = _budget(BudgetPeriod.monthly, startDay: 15);
      final now = DateTime(2026, 9, 20);
      expect(b.getPeriodStartDate(now: now), DateTime(2026, 9, 15));
      expect(b.getPeriodEndDate(now: now), DateTime(2026, 10, 15));
    });

    test('start day not reached yet uses previous month', () {
      final b = _budget(BudgetPeriod.monthly, startDay: 15);
      final now = DateTime(2026, 9, 10);
      expect(b.getPeriodStartDate(now: now), DateTime(2026, 8, 15));
      expect(b.getPeriodEndDate(now: now), DateTime(2026, 9, 15));
    });

    test('start day 30 in March falls back to end of February', () {
      final b = _budget(BudgetPeriod.monthly, startDay: 30);
      final now = DateTime(2026, 3, 1);
      final start = b.getPeriodStartDate(now: now);
      expect(start, DateTime(2026, 2, 28));
      expect(start.isAfter(now), isFalse);
      expect(b.getPeriodEndDate(now: now), DateTime(2026, 3, 30));
    });

    test('start day 31 clamps to short month end', () {
      final b = _budget(BudgetPeriod.monthly, startDay: 31);
      expect(
        b.getPeriodStartDate(now: DateTime(2026, 4, 30)),
        DateTime(2026, 4, 30),
      );
      expect(
        b.getPeriodEndDate(now: DateTime(2026, 4, 30)),
        DateTime(2026, 5, 31),
      );
    });

    test('January start rolls back to previous December', () {
      final b = _budget(BudgetPeriod.monthly, startDay: 10);
      expect(
        b.getPeriodStartDate(now: DateTime(2026, 1, 5)),
        DateTime(2025, 12, 10),
      );
    });
  });

  test('weekly period starts on Monday and lasts 7 days', () {
    final b = _budget(BudgetPeriod.weekly);
    final now = DateTime(2026, 9, 30); // Wednesday
    expect(b.getPeriodStartDate(now: now), DateTime(2026, 9, 28));
    expect(b.getPeriodEndDate(now: now), DateTime(2026, 10, 5));
  });

  test('yearly period', () {
    final b = _budget(BudgetPeriod.yearly);
    final now = DateTime(2026, 9, 30);
    expect(b.getPeriodStartDate(now: now), DateTime(2026, 1, 1));
    expect(b.getPeriodEndDate(now: now), DateTime(2027, 1, 1));
  });
}
