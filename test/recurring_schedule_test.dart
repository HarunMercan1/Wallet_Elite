import 'package:flutter_test/flutter_test.dart';
import 'package:wallet_elite/core/utils/amount_input.dart';
import 'package:wallet_elite/features/budgets/models/budget_model.dart';
import 'package:wallet_elite/features/recurring/models/recurring_transaction_model.dart';
import 'package:wallet_elite/features/transactions/presentation/transaction_filter_state.dart';

void main() {
  group('firstRecurringDate', () {
    // 13 Ekim 2026 Salı
    final today = DateTime(2026, 10, 13);

    test('daily starts today when the start date is today or past', () {
      expect(
        firstRecurringDate(
          frequency: RecurringFrequency.daily,
          startDate: DateTime(2026, 10, 1),
          notBefore: today,
        ),
        today,
      );
    });

    test('a future start date is respected', () {
      expect(
        firstRecurringDate(
          frequency: RecurringFrequency.daily,
          startDate: DateTime(2026, 11, 5),
          notBefore: today,
        ),
        DateTime(2026, 11, 5),
      );
    });

    test('monthly keeps this month when the day is still ahead', () {
      expect(
        firstRecurringDate(
          frequency: RecurringFrequency.monthly,
          startDate: DateTime(2026, 10, 1),
          notBefore: today,
          dayOfMonth: 20,
        ),
        DateTime(2026, 10, 20),
      );
    });

    test('monthly runs today when today is the chosen day', () {
      expect(
        firstRecurringDate(
          frequency: RecurringFrequency.monthly,
          startDate: today,
          notBefore: today,
          dayOfMonth: 13,
        ),
        today,
      );
    });

    test('monthly moves to next month when the day has passed', () {
      expect(
        firstRecurringDate(
          frequency: RecurringFrequency.monthly,
          startDate: DateTime(2026, 10, 1),
          notBefore: today,
          dayOfMonth: 5,
        ),
        DateTime(2026, 11, 5),
      );
    });

    test('monthly clamps day 31 to the end of short months', () {
      expect(
        firstRecurringDate(
          frequency: RecurringFrequency.monthly,
          startDate: DateTime(2027, 2, 1),
          notBefore: today,
          dayOfMonth: 31,
        ),
        DateTime(2027, 2, 28),
      );
    });

    test('weekly lands on the chosen weekday (0 = Sunday)', () {
      final sunday = firstRecurringDate(
        frequency: RecurringFrequency.weekly,
        startDate: today,
        notBefore: today,
        dayOfWeek: 0,
      );
      expect(sunday, DateTime(2026, 10, 18));
      expect(sunday.weekday, DateTime.sunday);

      // Salı = 2 → bugün
      expect(
        firstRecurringDate(
          frequency: RecurringFrequency.weekly,
          startDate: today,
          notBefore: today,
          dayOfWeek: 2,
        ),
        today,
      );
    });

    test('yearly uses the start month and day', () {
      expect(
        firstRecurringDate(
          frequency: RecurringFrequency.yearly,
          startDate: DateTime(2025, 3, 10),
          notBefore: today,
        ),
        DateTime(2027, 3, 10),
      );
    });
  });

  test('nextDateFrom never repeats a day that already ran', () {
    final r = RecurringTransactionModel(
      id: '1',
      userId: 'u',
      accountId: 'a',
      amount: 10,
      type: 'expense',
      frequency: RecurringFrequency.daily,
      startDate: DateTime(2026, 10, 1),
      nextExecutionDate: DateTime(2026, 10, 14),
      lastExecutionDate: DateTime(2026, 10, 13),
      createdAt: DateTime(2026, 10, 1),
      updatedAt: DateTime(2026, 10, 1),
    );
    expect(r.nextDateFrom(DateTime(2026, 10, 13)), DateTime(2026, 10, 14));
  });

  group('copyWith can clear optional fields', () {
    test('budget category', () {
      final budget = BudgetModel(
        id: '1',
        userId: 'u',
        name: 'Market',
        categoryId: 'c1',
        amount: 100,
        period: BudgetPeriod.monthly,
        createdAt: DateTime(2026),
        updatedAt: DateTime(2026),
      );
      expect(budget.copyWith(name: 'x').categoryId, 'c1');
      expect(budget.copyWith(categoryId: null).categoryId, isNull);
    });

    test('recurring end date and description', () {
      final r = RecurringTransactionModel(
        id: '1',
        userId: 'u',
        accountId: 'a',
        amount: 10,
        type: 'expense',
        description: 'Kira',
        frequency: RecurringFrequency.monthly,
        dayOfMonth: 5,
        startDate: DateTime(2026, 1, 1),
        endDate: DateTime(2027, 1, 1),
        nextExecutionDate: DateTime(2026, 11, 5),
        createdAt: DateTime(2026),
        updatedAt: DateTime(2026),
      );
      expect(r.copyWith(amount: 20).endDate, DateTime(2027, 1, 1));
      final cleared = r.copyWith(endDate: null, description: null);
      expect(cleared.endDate, isNull);
      expect(cleared.description, isNull);
      expect(cleared.dayOfMonth, 5);
    });

    test('transaction filter dates', () {
      final state = TransactionFilterState(startDate: DateTime(2026, 1, 1));
      expect(state.copyWith(type: 'income').startDate, DateTime(2026, 1, 1));
      final cleared = state.copyWith(startDate: null);
      expect(cleared.startDate, isNull);
      expect(cleared.hasFilters, isFalse);
    });
  });

  group('amount input', () {
    test('parseAmount accepts comma and dot', () {
      expect(parseAmount('12,5'), 12.5);
      expect(parseAmount('12.50'), 12.5);
      expect(parseAmount(' 7 '), 7);
      expect(parseAmount('0'), isNull);
      expect(parseAmount(''), isNull);
      expect(parseAmount('abc'), isNull);
    });

    test('amountToInputText drops trailing zeros', () {
      expect(amountToInputText(6000), '6000');
      expect(amountToInputText(12.5), '12.5');
      expect(amountToInputText(0.05), '0.05');
      expect(amountToInputText(100.10), '100.1');
    });

    test('formatter turns a comma into a dot and limits decimals', () {
      const formatter = AmountInputFormatter();
      TextEditingValue type(String oldText, String newText) =>
          formatter.formatEditUpdate(
            TextEditingValue(text: oldText),
            TextEditingValue(text: newText),
          );
      expect(type('12', '12,').text, '12.');
      expect(type('12.5', '12.55').text, '12.55');
      expect(type('12.55', '12.555').text, '12.55');
      expect(type('12', '12a').text, '12');
    });

    test('Arabic and Persian digits are accepted', () {
      const formatter = AmountInputFormatter();
      final typed = formatter.formatEditUpdate(
        TextEditingValue.empty,
        const TextEditingValue(text: '١٢٫٥'),
      );
      expect(typed.text, '12.5');
      expect(parseAmount('۲۵۰'), 250);
      expect(parseAmount('٣,٧٥'), 3.75);
    });
  });
}
