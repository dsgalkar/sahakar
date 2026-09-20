import 'dart:ui';
import 'package:flutter/material.dart';
import '../constants/app_colors.dart';

class GlassCard extends StatelessWidget {
  final Widget child;
  final double blur;
  final double opacity;
  final Color? borderColor;
  final BorderRadius? borderRadius;
  final EdgeInsetsGeometry? padding;
  final EdgeInsetsGeometry? margin;

  const GlassCard({
    super.key,
    required this.child,
    this.blur = 12.0,
    this.opacity = 0.65,
    this.borderColor,
    this.borderRadius,
    this.padding,
    this.margin,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final r = borderRadius ?? BorderRadius.circular(18);
    final fallbackBorder = isDark ? AppColors.darkBorder : AppColors.lightBorder;

    return Container(
      margin: margin,
      decoration: BoxDecoration(
        borderRadius: r,
        boxShadow: [
          BoxShadow(
            color: (borderColor ?? Colors.black).withValues(
              alpha: isDark ? 0.25 : 0.05,
            ),
            blurRadius: 16,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: r,
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: blur, sigmaY: blur),
          child: Container(
            padding: padding,
            decoration: BoxDecoration(
              color: (isDark ? AppColors.darkCard : Colors.white).withValues(
                alpha: isDark ? opacity : 0.9,
              ),
              borderRadius: r,
              border: Border.all(
                color: borderColor ?? fallbackBorder,
                width: borderColor != null ? 1.4 : 1.0,
              ),
            ),
            child: child,
          ),
        ),
      ),
    );
  }
}
