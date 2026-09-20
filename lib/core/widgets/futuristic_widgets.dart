import 'dart:ui';
import 'package:flutter/material.dart';
import '../constants/app_colors.dart';

/// Minimalist Glass Card with Neon Specular Borders
class GlassNeonCard extends StatelessWidget {
  final Widget child;
  final double blur;
  final double opacity;
  final Color? neonBorderColor;
  final double? glowSpread;
  final LinearGradient? borderGradient;
  final BorderRadius? borderRadius;
  final EdgeInsetsGeometry? padding;
  final EdgeInsetsGeometry? margin;
  final VoidCallback? onTap;

  const GlassNeonCard({
    super.key,
    required this.child,
    this.blur = 16.0,
    this.opacity = 0.65,
    Color? neonBorderColor,
    Color? neonGlowColor,
    this.glowSpread,
    this.borderGradient,
    this.borderRadius,
    this.padding,
    this.margin,
    this.onTap,
  }) : neonBorderColor = neonGlowColor ?? neonBorderColor;

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final r = borderRadius ?? BorderRadius.circular(18);
    final borderColor = neonBorderColor ??
        (isDark ? AppColors.darkBorder : AppColors.lightBorder);

    Widget content = Container(
      margin: margin,
      decoration: BoxDecoration(
        borderRadius: r,
        boxShadow: [
          BoxShadow(
            color: (neonBorderColor ?? Colors.black).withValues(
              alpha: isDark ? (glowSpread ?? 0.22) : 0.06,
            ),
            blurRadius: 18,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: r,
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: blur, sigmaY: blur),
          child: Container(
            padding: padding ?? const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: (isDark ? AppColors.darkCard : Colors.white).withValues(
                alpha: isDark ? opacity : 0.95,
              ),
              borderRadius: r,
              border: Border.all(
                color: borderColor,
                width: neonBorderColor != null ? 1.5 : 1.2,
              ),
            ),
            child: child,
          ),
        ),
      ),
    );

    if (onTap != null) {
      return InkWell(
        onTap: onTap,
        borderRadius: r,
        child: content,
      );
    }
    return content;
  }
}

/// Futuristic Neon Tag / Pill
class NeonPill extends StatelessWidget {
  final String text;
  final IconData? icon;
  final Color color;
  final bool isFilled;
  final VoidCallback? onTap;

  const NeonPill({
    super.key,
    String? text,
    String? label,
    this.icon,
    this.color = AppColors.neonCyan,
    this.isFilled = false,
    this.onTap,
  }) : text = text ?? label ?? '';

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    Widget pill = Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
      decoration: BoxDecoration(
        color: isFilled
            ? color.withValues(alpha: 0.18)
            : (isDark ? AppColors.darkSurface : Colors.white),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: color.withValues(alpha: isDark ? 0.65 : 0.8),
          width: 1.2,
        ),
        boxShadow: [
          if (isDark)
            BoxShadow(
              color: color.withValues(alpha: 0.2),
              blurRadius: 8,
              spreadRadius: 0,
            ),
        ],
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (icon != null) ...[
            Icon(icon, size: 13, color: color),
            const SizedBox(width: 5),
          ],
          Text(
            text,
            style: TextStyle(
              fontSize: 11,
              fontWeight: FontWeight.w800,
              letterSpacing: 0.4,
              color: color,
            ),
          ),
        ],
      ),
    );

    if (onTap != null) {
      return InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(20),
        child: pill,
      );
    }
    return pill;
  }
}

/// Minimalist Telemetry Metric HUD
class TelemetryCard extends StatelessWidget {
  final String label;
  final String value;
  final String? subtext;
  final IconData icon;
  final Color color;

  const TelemetryCard({
    super.key,
    required this.label,
    required this.value,
    this.subtext,
    required this.icon,
    this.color = AppColors.neonCyan,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: isDark ? AppColors.darkCard : Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: color.withValues(alpha: isDark ? 0.35 : 0.4),
          width: 1.2,
        ),
        boxShadow: [
          BoxShadow(
            color: color.withValues(alpha: isDark ? 0.08 : 0.04),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                label.toUpperCase(),
                style: TextStyle(
                  fontSize: 10,
                  fontWeight: FontWeight.w800,
                  letterSpacing: 0.8,
                  color: isDark ? AppColors.darkTextSecondary : AppColors.lightTextSecondary,
                ),
              ),
              Container(
                padding: const EdgeInsets.all(4),
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: color.withValues(alpha: 0.15),
                ),
                child: Icon(icon, size: 14, color: color),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            value,
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w900,
              letterSpacing: -0.5,
              color: isDark ? Colors.white : AppColors.lightTextPrimary,
            ),
          ),
          if (subtext != null) ...[
            const SizedBox(height: 2),
            Text(
              subtext!,
              style: TextStyle(
                fontSize: 10,
                fontWeight: FontWeight.w600,
                color: color,
              ),
            ),
          ],
        ],
      ),
    );
  }
}
