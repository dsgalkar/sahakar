import 'package:flutter/material.dart';
import '../theme/app_theme.dart';

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
    final borderRadius = BorderRadius.circular(size > 60 ? 20 : 10);

    Widget logoImage = Container(
      width: size,
      height: size,
      padding: EdgeInsets.all(size > 60 ? 4 : 2),
      decoration: BoxDecoration(
        borderRadius: borderRadius,
        color: Colors.white,
        border: showBadgeBorder
            ? Border.all(
                color: isDark ? AppColors.accentGoldLight : AppColors.primaryBlue,
                width: size > 60 ? 2.5 : 1.5,
              )
            : null,
        boxShadow: [
          BoxShadow(
            color: (isDark ? Colors.black : AppColors.primaryBlue).withOpacity(0.18),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(size > 60 ? 16 : 8),
        child: Image.asset(
          'assets/img/logo.jpg',
          width: size,
          height: size,
          fit: BoxFit.contain,
          errorBuilder: (context, error, stackTrace) {
            return Container(
              color: isDark ? AppColors.darkSurface : AppColors.primaryBlue,
              alignment: Alignment.center,
              child: Icon(
                Icons.handshake_rounded,
                size: size * 0.55,
                color: isDark ? AppColors.accentGoldLight : Colors.white,
              ),
            );
          },
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
      borderRadius: BorderRadius.circular(12),
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
                Text(
                  'SAHAKAR',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w900,
                    letterSpacing: 1.1,
                    color: isDark ? Colors.white : AppColors.primaryBlue,
                  ),
                ),
                Text(
                  'Instant Gig Support',
                  style: TextStyle(
                    fontSize: 10,
                    fontWeight: FontWeight.w600,
                    color: isDark ? AppColors.accentGoldLight : AppColors.accentGold,
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
