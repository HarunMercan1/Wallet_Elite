import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:wallet_elite/core/theme/app_colors.dart';

/// WCAG contrast ratio between two opaque colours.
double contrast(Color a, Color b) {
  final la = a.computeLuminance();
  final lb = b.computeLuminance();
  final hi = la > lb ? la : lb;
  final lo = la > lb ? lb : la;
  return (hi + 0.05) / (lo + 0.05);
}

void main() {
  // Every theme in both brightnesses must keep icons, text and buttons
  // readable. These are the rules documented on [ColorTheme].
  for (final base in ColorTheme.all) {
    for (final brightness in Brightness.values) {
      final c = base.forBrightness(brightness);
      final label = '${c.id} ${brightness.name}';

      test('$label: palette belongs to the requested brightness', () {
        expect(c.brightness, brightness);
        expect(c.id, base.id);
        expect(c.cardColor, c.isDark ? c.surfaceDark : c.surfaceLight);
      });

      test('$label: text is readable on surfaces', () {
        expect(contrast(c.textPrimary, c.cardColor), greaterThanOrEqualTo(7));
        expect(contrast(c.textPrimary, c.background), greaterThanOrEqualTo(7));
        expect(
          contrast(c.textSecondary, c.cardColor),
          greaterThanOrEqualTo(4.5),
        );
        expect(
          contrast(c.textSecondary, c.background),
          greaterThanOrEqualTo(4.5),
        );
        expect(
          contrast(c.onSurfaceVariant, c.surfaceVariant),
          greaterThanOrEqualTo(4.5),
        );
      });

      test('$label: accent colours are visible as icons', () {
        final onSurfaces = {
          'primary': c.primary,
          'accent': c.accent,
          'tertiary': c.tertiary,
          'success': c.success,
          'error': c.error,
          'warning': c.warning,
          'info': c.info,
        };
        onSurfaces.forEach((name, color) {
          expect(
            contrast(color, c.cardColor),
            greaterThanOrEqualTo(3),
            reason: '$name on card',
          );
        });
        expect(contrast(c.primary, c.background), greaterThanOrEqualTo(3));
        expect(contrast(c.primary, c.subtleCardColor), greaterThanOrEqualTo(3));
      });

      test('$label: content on filled colours is readable', () {
        expect(contrast(c.onPrimary, c.primary), greaterThanOrEqualTo(4));
        expect(contrast(c.onPrimary, c.primaryLight), greaterThanOrEqualTo(3));
        expect(contrast(c.onPrimary, c.primaryDark), greaterThanOrEqualTo(3));
        expect(contrast(c.onTertiary, c.tertiary), greaterThanOrEqualTo(4.5));
        // Save / delete buttons draw white text on success and error.
        expect(contrast(Colors.white, c.success), greaterThanOrEqualTo(3));
        expect(contrast(Colors.white, c.error), greaterThanOrEqualTo(3));
      });
    }
  }

  test('unknown theme id falls back to midnight', () {
    expect(ColorTheme.fromString('does-not-exist').id, 'midnight');
  });
}
