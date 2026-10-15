import 'package:flutter/material.dart';

/// Alt pencere (bottom sheet) zemini: üst köşeleri yuvarlak, renkli bir
/// [Material]. Zemin rengini bir `Container` dekorasyonuyla vermek, içteki
/// `InkWell`/`ListTile` dokunma dalgalarını rengin altında bırakıp gizler;
/// burada dalgalar zeminin üstünde çizilir.
///
/// Sayfalar `showModalBottomSheet(backgroundColor: Colors.transparent)` ile
/// açılır ve kökte bu yüzeyi kullanır.
class SheetSurface extends StatelessWidget {
  const SheetSurface({
    super.key,
    required this.color,
    required this.child,
    this.height,
    this.constraints,
    this.padding,
    this.margin,
    this.radius = 24,
  });

  final Color color;
  final Widget child;
  final double? height;
  final BoxConstraints? constraints;
  final EdgeInsetsGeometry? padding;

  /// Yüzeyin dışındaki boşluk (ör. klavye yüksekliği)
  final EdgeInsetsGeometry? margin;
  final double radius;

  @override
  Widget build(BuildContext context) {
    Widget surface = Material(
      color: color,
      clipBehavior: Clip.antiAlias,
      borderRadius: BorderRadius.vertical(top: Radius.circular(radius)),
      child: Container(
        height: height,
        constraints: constraints,
        padding: padding,
        child: child,
      ),
    );
    if (margin != null) surface = Padding(padding: margin!, child: surface);
    return surface;
  }
}
