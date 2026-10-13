import 'package:flutter_test/flutter_test.dart';
import 'package:wallet_elite/core/ads/full_screen_ad_gate.dart';

void main() {
  test('only one full-screen ad counts as showing at a time', () {
    expect(FullScreenAdGate.isShowing, isFalse);
    FullScreenAdGate.opened();
    expect(FullScreenAdGate.isShowing, isTrue);
    FullScreenAdGate.closed();
    expect(FullScreenAdGate.isShowing, isFalse);
    expect(FullScreenAdGate.closedWithin(const Duration(minutes: 1)), isTrue);
  });

  test('returning from an external flow is reported once', () {
    expect(FullScreenAdGate.consumeExternalFlow(), isFalse);
    FullScreenAdGate.externalFlowStarted();
    expect(FullScreenAdGate.consumeExternalFlow(), isTrue);
    // İşaret tüketildi: sonraki dönüş normal bir dönüş sayılır
    expect(FullScreenAdGate.consumeExternalFlow(), isFalse);
  });
}
