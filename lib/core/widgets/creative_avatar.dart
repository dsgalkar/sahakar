import 'package:flutter/material.dart';
import '../constants/app_colors.dart';
import '../models/app_models.dart';

enum AvatarTrade {
  citizen,
  electrician,
  plumber,
  appliance,
  caregiver,
  cleaning,
  carpenter,
  admin,
}

class CreativeAvatar extends StatelessWidget {
  final double size;
  final AvatarTrade? trade;
  final String? tradeName;
  final UserRole? role;
  final String? name;
  final bool isOnline;
  final bool isVerified;
  final int? nsqfLevel;
  final VoidCallback? onTap;
  final bool showGlow;

  CreativeAvatar({
    super.key,
    double? size,
    double? radius,
    this.trade,
    this.tradeName,
    this.role,
    this.name,
    bool? isOnline,
    bool? isLiveOnline,
    this.isVerified = true,
    this.nsqfLevel,
    this.onTap,
    this.showGlow = true,
  })  : size = size ?? (radius != null ? radius * 2 : 52.0),
        isOnline = isOnline ?? isLiveOnline ?? true;

  AvatarTrade get _resolvedTrade {
    if (trade != null) return trade!;
    if (role == UserRole.admin) return AvatarTrade.admin;
    if (role == UserRole.user) return AvatarTrade.citizen;

    final lower = (tradeName ?? '').toLowerCase();
    if (lower.contains('electr') || lower.contains('wire')) return AvatarTrade.electrician;
    if (lower.contains('plumb') || lower.contains('pipe')) return AvatarTrade.plumber;
    if (lower.contains('appliance') || lower.contains('ac') || lower.contains('tech')) return AvatarTrade.appliance;
    if (lower.contains('care') || lower.contains('nurse') || lower.contains('elder')) return AvatarTrade.caregiver;
    if (lower.contains('clean') || lower.contains('sanit')) return AvatarTrade.cleaning;
    if (lower.contains('carpent') || lower.contains('wood')) return AvatarTrade.carpenter;

    return AvatarTrade.citizen;
  }

  IconData _getIcon(AvatarTrade t) {
    switch (t) {
      case AvatarTrade.electrician:
        return Icons.bolt_rounded;
      case AvatarTrade.plumber:
        return Icons.water_drop_rounded;
      case AvatarTrade.appliance:
        return Icons.precision_manufacturing_rounded;
      case AvatarTrade.caregiver:
        return Icons.volunteer_activism_rounded;
      case AvatarTrade.cleaning:
        return Icons.auto_awesome_rounded;
      case AvatarTrade.carpenter:
        return Icons.architecture_rounded;
      case AvatarTrade.admin:
        return Icons.shield_rounded;
      case AvatarTrade.citizen:
        return Icons.fingerprint_rounded;
    }
  }

  LinearGradient _getGradient(AvatarTrade t) {
    switch (t) {
      case AvatarTrade.electrician:
        return AppColors.cyberCyanGradient;
      case AvatarTrade.plumber:
        return const LinearGradient(
          colors: [Color(0xFF00E5FF), Color(0xFF0072FF)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        );
      case AvatarTrade.appliance:
        return AppColors.cyberPurpleGradient;
      case AvatarTrade.caregiver:
        return AppColors.cyberGreenGradient;
      case AvatarTrade.cleaning:
        return const LinearGradient(
          colors: [Color(0xFFFF007F), Color(0xFF7928CA)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        );
      case AvatarTrade.carpenter:
        return AppColors.cyberGoldGradient;
      case AvatarTrade.admin:
        return const LinearGradient(
          colors: [Color(0xFFB026FF), Color(0xFF00F0FF)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        );
      case AvatarTrade.citizen:
        return const LinearGradient(
          colors: [Color(0xFF00F0FF), Color(0xFF00FF85)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        );
    }
  }

  Color _getAccentColor(AvatarTrade t) {
    switch (t) {
      case AvatarTrade.electrician:
        return AppColors.neonCyan;
      case AvatarTrade.plumber:
        return const Color(0xFF00E5FF);
      case AvatarTrade.appliance:
        return AppColors.neonPurple;
      case AvatarTrade.caregiver:
        return AppColors.neonGreen;
      case AvatarTrade.cleaning:
        return AppColors.neonPink;
      case AvatarTrade.carpenter:
        return AppColors.neonGold;
      case AvatarTrade.admin:
        return AppColors.neonPurple;
      case AvatarTrade.citizen:
        return AppColors.neonCyan;
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final resolved = _resolvedTrade;
    final gradient = _getGradient(resolved);
    final accent = _getAccentColor(resolved);
    final icon = _getIcon(resolved);

    Widget avatarWidget = Stack(
      clipBehavior: Clip.none,
      children: [
        // Outer glowing cyber ring
        Container(
          width: size,
          height: size,
          padding: EdgeInsets.all(size * 0.05),
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            gradient: gradient,
            boxShadow: [
              BoxShadow(
                color: accent.withValues(alpha: isDark ? 0.45 : 0.25),
                blurRadius: size * 0.25,
                spreadRadius: 1,
              ),
            ],
          ),
          child: Container(
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: isDark ? AppColors.darkSurface : AppColors.lightSurface,
            ),
            child: Center(
              child: Icon(
                icon,
                size: size * 0.52,
                color: accent,
              ),
            ),
          ),
        ),

        // Live Presence Beacon Dot
        if (isOnline)
          Positioned(
            right: 0,
            bottom: 0,
            child: Container(
              width: size * 0.28,
              height: size * 0.28,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: AppColors.neonGreen,
                border: Border.all(
                  color: isDark ? AppColors.darkSurface : Colors.white,
                  width: 2,
                ),
                boxShadow: [
                  BoxShadow(
                    color: AppColors.neonGreen.withValues(alpha: 0.8),
                    blurRadius: 6,
                    spreadRadius: 1,
                  ),
                ],
              ),
            ),
          ),

        // Verified Shield or NSQF Level Badge
        if (nsqfLevel != null)
          Positioned(
            left: -2,
            bottom: -2,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 1.5),
              decoration: BoxDecoration(
                color: AppColors.neonGold,
                borderRadius: BorderRadius.circular(6),
                border: Border.all(
                  color: isDark ? AppColors.darkSurface : Colors.white,
                  width: 1,
                ),
              ),
              child: Text(
                'L$nsqfLevel',
                style: const TextStyle(
                  color: Color(0xFF07090E),
                  fontSize: 8.5,
                  fontWeight: FontWeight.w900,
                  letterSpacing: -0.2,
                ),
              ),
            ),
          ),
      ],
    );

    if (onTap != null) {
      return InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(size),
        child: avatarWidget,
      );
    }

    return avatarWidget;
  }
}
