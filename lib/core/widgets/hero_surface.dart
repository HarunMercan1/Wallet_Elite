import 'dart:math' as math;

import 'package:flutter/material.dart';

import '../theme/app_colors.dart';

/// Temanın hero renkleriyle boyanmış büyük vurgu yüzeyi (bakiye kartı,
/// premium kartları). Gradyan, zemine karışmasın diye gerekirse ince kenarlık,
/// renkli gölge, köşelerde tema rengi parıltısı ve açılışta bir kez kayan bir
/// ışık yansıması çizer. İçerik [ColorTheme.onHero] ile yazılmalıdır.
class HeroSurface extends StatefulWidget {
  const HeroSurface({
    super.key,
    required this.colors,
    required this.child,
    this.borderRadius = const BorderRadius.all(Radius.circular(24)),
    this.padding = EdgeInsets.zero,
    this.shadow = true,
    this.glow = true,
    this.sheen = true,
    this.onTap,
  });

  final ColorTheme colors;
  final Widget child;
  final BorderRadius borderRadius;
  final EdgeInsetsGeometry padding;
  final bool shadow;
  final bool glow;

  /// Açılışta bir kez kayan ışık yansıması
  final bool sheen;
  final VoidCallback? onTap;

  @override
  State<HeroSurface> createState() => _HeroSurfaceState();
}

class _HeroSurfaceState extends State<HeroSurface>
    with SingleTickerProviderStateMixin {
  late final AnimationController _sheen = AnimationController(
    vsync: this,
    duration: const Duration(milliseconds: 1400),
  );

  @override
  void initState() {
    super.initState();
    if (widget.sheen) {
      Future.delayed(const Duration(milliseconds: 350), () {
        if (mounted) _sheen.forward();
      });
    }
  }

  @override
  void dispose() {
    _sheen.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final c = widget.colors;
    final border = c.heroBorder;
    final reduceMotion = MediaQuery.maybeDisableAnimationsOf(context) ?? false;

    Widget content = Padding(padding: widget.padding, child: widget.child);
    if (widget.onTap != null) {
      content = Material(
        type: MaterialType.transparency,
        child: InkWell(
          onTap: widget.onTap,
          borderRadius: widget.borderRadius,
          splashColor: c.onHero.withValues(alpha: 0.12),
          highlightColor: c.onHero.withValues(alpha: 0.06),
          child: content,
        ),
      );
    }

    return AnimatedContainer(
      duration: const Duration(milliseconds: 400),
      curve: Curves.easeOut,
      clipBehavior: Clip.antiAlias,
      decoration: BoxDecoration(
        gradient: c.heroGradient,
        borderRadius: widget.borderRadius,
        border: border == null ? null : Border.all(color: border),
        boxShadow: widget.shadow
            ? [
                BoxShadow(
                  color: c.heroShadow,
                  blurRadius: 24,
                  spreadRadius: -6,
                  offset: const Offset(0, 12),
                ),
              ]
            : null,
      ),
      child: Stack(
        children: [
          if (widget.glow) ...[
            // Sağ üstte tema rengi parıltısı
            Positioned(
              top: -90,
              right: -70,
              child: _Glow(color: c.heroAccent, size: 220, alpha: 0.4),
            ),
            // Sol altta ince halka
            Positioned(
              bottom: -90,
              left: -50,
              child: Container(
                width: 190,
                height: 190,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  border: Border.all(
                    color: c.onHero.withValues(alpha: 0.08),
                    width: 22,
                  ),
                ),
              ),
            ),
          ],
          if (widget.sheen && !reduceMotion)
            Positioned.fill(
              child: IgnorePointer(
                child: AnimatedBuilder(
                  animation: _sheen,
                  builder: (context, _) {
                    final t = Curves.easeInOut.transform(_sheen.value);
                    if (t == 0 || t == 1) return const SizedBox.shrink();
                    return DecoratedBox(
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          begin: Alignment(-1 + 4 * t - 1.5, -1),
                          end: Alignment(-1 + 4 * t - 0.5, 1),
                          colors: [
                            c.onHero.withValues(alpha: 0),
                            c.onHero.withValues(alpha: 0.13),
                            c.onHero.withValues(alpha: 0),
                          ],
                          transform: const GradientRotation(math.pi / 12),
                        ),
                      ),
                    );
                  },
                ),
              ),
            ),
          content,
        ],
      ),
    );
  }
}

class _Glow extends StatelessWidget {
  const _Glow({required this.color, required this.size, required this.alpha});

  final Color color;
  final double size;
  final double alpha;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        gradient: RadialGradient(
          colors: [
            color.withValues(alpha: alpha),
            color.withValues(alpha: 0),
          ],
        ),
      ),
    );
  }
}
