// lib/features/statistics/presentation/date_range_picker_view.dart

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import '../../../l10n/app_localizations.dart';

import '../../../core/theme/color_theme_provider.dart';

class DateRangeResult {
  final DateTime startDate;
  final DateTime endDate;
  final String label;

  DateRangeResult({
    required this.startDate,
    required this.endDate,
    required this.label,
  });
}

class DateRangePickerView extends ConsumerStatefulWidget {
  final DateTime? initialStartDate;
  final DateTime? initialEndDate;

  const DateRangePickerView({
    super.key,
    this.initialStartDate,
    this.initialEndDate,
  });

  @override
  ConsumerState<DateRangePickerView> createState() =>
      _DateRangePickerViewState();
}

class _DateRangePickerViewState extends ConsumerState<DateRangePickerView> {
  DateTime? _startDate;
  DateTime? _endDate;
  String? _selectedPreset;

  @override
  void initState() {
    super.initState();
    _startDate = widget.initialStartDate;
    _endDate = widget.initialEndDate;
  }

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context)!;
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final colorTheme = ref.watch(currentColorThemeProvider);

    return Scaffold(
      backgroundColor: isDark
          ? colorTheme.backgroundDark
          : colorTheme.backgroundLight,
      appBar: AppBar(
        title: Text(l.selectDateRange),
        backgroundColor: Colors.transparent,
        elevation: 0,
        centerTitle: true,
        leading: IconButton(
          icon: Icon(
            Icons.close,
            color: isDark ? Colors.white : Colors.black87,
          ),
          onPressed: () => Navigator.pop(context),
        ),
        actions: [
          if (_startDate != null && _endDate != null)
            TextButton(
              onPressed: _applyDateRange,
              child: Text(
                l.apply,
                style: TextStyle(
                  color: colorTheme.primary,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Quick presets
            Text(
              l.periodFilter,
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: isDark ? Colors.white : Colors.black87,
              ),
            ),
            const SizedBox(height: 16),
            _buildPresetGrid(l, isDark, colorTheme),

            const SizedBox(height: 32),

            // Custom date selection
            Text(
              l.customDateRange,
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: isDark ? Colors.white : Colors.black87,
              ),
            ),
            const SizedBox(height: 16),

            // Start date picker
            _buildDatePicker(
              label: l.startDate,
              date: _startDate,
              onTap: () => _selectDate(true),
              isDark: isDark,
              colorTheme: colorTheme,
            ),
            const SizedBox(height: 12),

            // End date picker
            _buildDatePicker(
              label: l.endDate,
              date: _endDate,
              onTap: () => _selectDate(false),
              isDark: isDark,
              colorTheme: colorTheme,
            ),

            const SizedBox(height: 32),

            // Selected range preview
            if (_startDate != null && _endDate != null)
              _buildRangePreview(l, isDark, colorTheme),

            const SizedBox(height: 24),

            // Reset button
            if (_startDate != null || _endDate != null)
              Center(
                child: TextButton.icon(
                  onPressed: _resetDates,
                  icon: Icon(Icons.refresh, color: Colors.grey[500]),
                  label: Text(
                    l.reset,
                    style: TextStyle(color: Colors.grey[500]),
                  ),
                ),
              ),
          ],
        ),
      ),
      bottomNavigationBar: _startDate != null && _endDate != null
          ? Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: isDark ? colorTheme.surfaceDark : Colors.white,
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.05),
                    blurRadius: 10,
                    offset: const Offset(0, -4),
                  ),
                ],
              ),
              child: SafeArea(
                child: ElevatedButton(
                  onPressed: _applyDateRange,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: colorTheme.primary,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  child: Text(
                    l.apply,
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ),
            )
          : null,
    );
  }

  Widget _buildPresetGrid(AppLocalizations l, bool isDark, dynamic colorTheme) {
    final now = DateTime.now();
    final presets = [
      {
        'key': 'thisWeek',
        'label': l.thisWeek,
        'start': now.subtract(Duration(days: now.weekday - 1)),
        'end': now,
      },
      {
        'key': 'lastWeek',
        'label': l.lastWeek,
        'start': now.subtract(Duration(days: now.weekday + 6)),
        'end': now.subtract(Duration(days: now.weekday)),
      },
      {
        'key': 'thisMonth',
        'label': l.thisMonth,
        'start': DateTime(now.year, now.month, 1),
        'end': now,
      },
      {
        'key': 'lastMonth',
        'label': l.lastMonth,
        'start': DateTime(now.year, now.month - 1, 1),
        'end': DateTime(now.year, now.month, 0),
      },
      {
        'key': 'last3Months',
        'label': l.last3Months,
        'start': DateTime(now.year, now.month - 2, 1),
        'end': now,
      },
      {
        'key': 'last6Months',
        'label': l.last6Months,
        'start': DateTime(now.year, now.month - 5, 1),
        'end': now,
      },
      {
        'key': 'thisYear',
        'label': l.thisYear,
        'start': DateTime(now.year, 1, 1),
        'end': now,
      },
      {
        'key': 'allTime',
        'label': l.allTime,
        'start': DateTime(2000, 1, 1),
        'end': now,
      },
    ];

    return Wrap(
      spacing: 10,
      runSpacing: 10,
      children: presets.map((preset) {
        final isSelected = _selectedPreset == preset['key'];
        return GestureDetector(
          onTap: () {
            setState(() {
              _selectedPreset = preset['key'] as String;
              _startDate = preset['start'] as DateTime;
              _endDate = preset['end'] as DateTime;
            });
          },
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            decoration: BoxDecoration(
              color: isSelected
                  ? colorTheme.primary
                  : (isDark ? colorTheme.surfaceDark : Colors.white),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(
                color: isSelected
                    ? colorTheme.primary
                    : (isDark ? Colors.white24 : Colors.grey[300]!),
              ),
              boxShadow: isSelected
                  ? [
                      BoxShadow(
                        color: colorTheme.primary.withOpacity(0.3),
                        blurRadius: 8,
                        offset: const Offset(0, 2),
                      ),
                    ]
                  : null,
            ),
            child: Text(
              preset['label'] as String,
              style: TextStyle(
                color: isSelected
                    ? Colors.white
                    : (isDark ? Colors.white : Colors.black87),
                fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                fontSize: 13,
              ),
            ),
          ),
        );
      }).toList(),
    );
  }

  Widget _buildDatePicker({
    required String label,
    required DateTime? date,
    required VoidCallback onTap,
    required bool isDark,
    required dynamic colorTheme,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: isDark ? colorTheme.surfaceDark : Colors.white,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: date != null
                ? colorTheme.primary.withOpacity(0.5)
                : (isDark ? Colors.white24 : Colors.grey[300]!),
          ),
        ),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: colorTheme.primary.withOpacity(0.1),
                borderRadius: BorderRadius.circular(10),
              ),
              child: Icon(
                Icons.calendar_today,
                color: colorTheme.primary,
                size: 20,
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    label,
                    style: TextStyle(fontSize: 12, color: Colors.grey[500]),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    date != null
                        ? DateFormat('d MMMM yyyy', 'tr').format(date)
                        : '---',
                    style: TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.w600,
                      color: date != null
                          ? (isDark ? Colors.white : Colors.black87)
                          : Colors.grey[400],
                    ),
                  ),
                ],
              ),
            ),
            Icon(Icons.chevron_right, color: Colors.grey[400]),
          ],
        ),
      ),
    );
  }

  Widget _buildRangePreview(
    AppLocalizations l,
    bool isDark,
    dynamic colorTheme,
  ) {
    final days = _endDate!.difference(_startDate!).inDays + 1;

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: colorTheme.primary.withOpacity(0.1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: colorTheme.primary.withOpacity(0.2)),
      ),
      child: Row(
        children: [
          Icon(Icons.date_range, color: colorTheme.primary, size: 24),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  '${DateFormat('d MMM', 'tr').format(_startDate!)} - ${DateFormat('d MMM yyyy', 'tr').format(_endDate!)}',
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.bold,
                    color: isDark ? Colors.white : Colors.black87,
                  ),
                ),
                Text(
                  '$days ${l.daily.toLowerCase()}',
                  style: TextStyle(fontSize: 12, color: Colors.grey[500]),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _selectDate(bool isStart) async {
    final colorTheme = ref.read(currentColorThemeProvider);
    final now = DateTime.now();

    final picked = await showDatePicker(
      context: context,
      initialDate: isStart ? (_startDate ?? now) : (_endDate ?? now),
      firstDate: DateTime(2000),
      lastDate: now,
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: ColorScheme.light(
              primary: colorTheme.primary,
              onPrimary: Colors.white,
              surface: Colors.white,
              onSurface: Colors.black87,
            ),
          ),
          child: child!,
        );
      },
    );

    if (picked != null) {
      setState(() {
        _selectedPreset = null;
        if (isStart) {
          _startDate = picked;
          if (_endDate != null && _endDate!.isBefore(picked)) {
            _endDate = picked;
          }
        } else {
          _endDate = picked;
          if (_startDate != null && _startDate!.isAfter(picked)) {
            _startDate = picked;
          }
        }
      });
    }
  }

  void _resetDates() {
    setState(() {
      _startDate = null;
      _endDate = null;
      _selectedPreset = null;
    });
  }

  void _applyDateRange() {
    if (_startDate != null && _endDate != null) {
      final label = _selectedPreset != null
          ? _getPresetLabel(_selectedPreset!)
          : '${DateFormat('d MMM', 'tr').format(_startDate!)} - ${DateFormat('d MMM', 'tr').format(_endDate!)}';

      Navigator.pop(
        context,
        DateRangeResult(
          startDate: _startDate!,
          endDate: _endDate!,
          label: label,
        ),
      );
    }
  }

  String _getPresetLabel(String key) {
    final l = AppLocalizations.of(context)!;
    switch (key) {
      case 'thisWeek':
        return l.thisWeek;
      case 'lastWeek':
        return l.lastWeek;
      case 'thisMonth':
        return l.thisMonth;
      case 'lastMonth':
        return l.lastMonth;
      case 'last3Months':
        return l.last3Months;
      case 'last6Months':
        return l.last6Months;
      case 'thisYear':
        return l.thisYear;
      case 'allTime':
        return l.allTime;
      default:
        return key;
    }
  }
}
