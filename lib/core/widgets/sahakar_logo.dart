import 'package:flutter/material.dart';
import '../constants/app_colors.dart';

class SahakarLogo extends StatelessWidget {
  final double size;
  final bool showBadgeBorder;
  final VoidCallback? onTap;
  final bool isCompact;

  const SahakarLogo({
    super.key,
    this.size = 40.0,
    this.showBadgeBorder = true,
    this.onTap,
    this.isCompact = false,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final borderRadius = BorderRadius.circular(size > 60 ? 22 : 12);

    Widget logoImage = Container(
      width: size,
      height: size,
      padding: EdgeInsets.all(size > 60 ? 4 : 2),
      decoration: BoxDecoration(
        borderRadius: borderRadius,
        gradient: showBadgeBorder ? AppColors.holographicBorder : null,
        color: showBadgeBorder ? null : (isDark ? AppColors.darkSurface : Colors.white),
        boxShadow: [
          if (showBadgeBorder)
            BoxShadow(
              color: AppColors.neonCyan.withValues(alpha: isDark ? 0.35 : 0.15),
              blurRadius: size * 0.25,
              offset: const Offset(0, 2),
            ),
        ],
      ),
      child: Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(size > 60 ? 18 : 10),
          color: isDark ? AppColors.darkSurface : Colors.white,
        ),
        padding: EdgeInsets.all(size > 60 ? 6 : 4),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(size > 60 ? 14 : 8),
          child: Image.asset(
            'assets/img/logo.jpg',
            width: size,
            height: size,
            fit: BoxFit.contain,
            errorBuilder: (context, error, stackTrace) {
              return Center(
                child: Icon(
                  Icons.hub_rounded,
                  size: size * 0.52,
                  color: AppColors.neonCyan,
                ),
              );
            },
          ),
        ),
      ),
    );

    if (isCompact || onTap == null) {
      return onTap != null
          ? InkWell(
              onTap: onTap,
              borderRadius: borderRadius,
              child: logoImage,
            )
          : logoImage;
    }

    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(14),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 4.0, vertical: 2.0),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            logoImage,
            const SizedBox(width: 10),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      'SAHAKAR',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w900,
                        letterSpacing: 1.5,
                        color: isDark ? Colors.white : AppColors.lightTextPrimary,
                      ),
                    ),
                    const SizedBox(width: 5),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 1),
                      decoration: BoxDecoration(
                        color: AppColors.neonCyan.withValues(alpha: 0.15),
                        borderRadius: BorderRadius.circular(4),
                      ),
                      child: const Text(
                        'GRID',
                        style: TextStyle(
                          fontSize: 8.5,
                          fontWeight: FontWeight.w900,
                          color: AppColors.neonCyan,
                          letterSpacing: 0.8,
                        ),
                      ),
                    ),
                  ],
                ),
                Text(
                  'सहकार • Instant Gig Support',
                  style: TextStyle(
                    fontSize: 10,
                    fontWeight: FontWeight.w600,
                    color: isDark ? AppColors.neonCyan : AppColors.neonCyanDark,
                    letterSpacing: 0.2,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

