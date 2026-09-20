import 'package:flutter/material.dart';

/// Minimalist Canvas with Maximalist Futuristic Chromatics
class AppColors {
  // Dark Futuristic Canvas (Deep Obsidian & Void Slate)
  static const Color darkBackground = Color(0xFF07090E);
  static const Color darkSurface = Color(0xFF0E121B);
  static const Color darkCard = Color(0xFF141926);
  static const Color darkCardSubtle = Color(0xFF1A2234);
  static const Color darkBorder = Color(0xFF252F48);
  static const Color darkTextPrimary = Color(0xFFF8FAFC);
  static const Color darkTextSecondary = Color(0xFF94A3B8);
  static const Color darkTextMuted = Color(0xFF64748B);

  // Light Minimalist Canvas (Crisp Porcelain & Alabaster)
  static const Color lightBackground = Color(0xFFF8FAFC);
  static const Color lightSurface = Color(0xFFFFFFFF);
  static const Color lightCard = Color(0xFFFFFFFF);
  static const Color lightCardSubtle = Color(0xFFF1F5F9);
  static const Color lightBorder = Color(0xFFE2E8F0);
  static const Color lightTextPrimary = Color(0xFF090D16);
  static const Color lightTextSecondary = Color(0xFF475569);
  static const Color lightTextMuted = Color(0xFF94A3B8);

  // High-Voltage Neon Chromatics (Maximalist Accents)
  static const Color neonCyan = Color(0xFF00F0FF); // Cyber Electric Cyan
  static const Color neonCyanDark = Color(0xFF00B4D8);
  static const Color neonGreen = Color(0xFF00FF85); // Laser Lime / Emerald
  static const Color neonGreenDark = Color(0xFF059669);
  static const Color neonPurple = Color(0xFFB026FF); // Hyper Violet
  static const Color neonPurpleDark = Color(0xFF7C3AED);
  static const Color neonGold = Color(0xFFFFB800); // Solar Amber / Gold
  static const Color neonGoldDark = Color(0xFFD97706);
  static const Color neonCoral = Color(0xFFFF2A6D); // Hot Laser Coral / Crimson SOS
  static const Color neonPink = Color(0xFFFF007F); // Neon Synth Magenta
  static const Color neonBlue = Color(0xFF3B82F6); // Vibrant Royal Pulse

  // Backward compatibility aliases for existing references
  static const Color primaryBlue = Color(0xFF00F0FF);
  static const Color primaryBlueLight = Color(0xFF00F0FF);
  static const Color accentGold = Color(0xFFFFB800);
  static const Color accentGoldLight = Color(0xFFFFB800);
  static const Color successGreen = Color(0xFF00FF85);
  static const Color successGreenLight = Color(0xFF00FF85);
  static const Color emergencyRed = Color(0xFFFF2A6D);
  static const Color emergencyRedLight = Color(0xFFFF2A6D);

  static const Color background = darkBackground;
  static const Color surface = darkSurface;
  static const Color surfaceLight = darkCard;
  static const Color surfaceBorder = darkBorder;

  // Futuristic Gradients
  static const LinearGradient cyberCyanGradient = LinearGradient(
    colors: [Color(0xFF00F0FF), Color(0xFF0077FE)],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  static const LinearGradient cyberPurpleGradient = LinearGradient(
    colors: [Color(0xFFB026FF), Color(0xFF6366F1)],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  static const LinearGradient cyberGoldGradient = LinearGradient(
    colors: [Color(0xFFFFD600), Color(0xFFFF8A00)],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  static const LinearGradient cyberGreenGradient = LinearGradient(
    colors: [Color(0xFF00FF85), Color(0xFF00B4D8)],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  static const LinearGradient cyberCoralGradient = LinearGradient(
    colors: [Color(0xFFFF2A6D), Color(0xFFFF6F00)],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  static const LinearGradient holographicBorder = LinearGradient(
    colors: [
      Color(0xFF00F0FF),
      Color(0xFFB026FF),
      Color(0xFFFFB800),
      Color(0xFF00FF85),
    ],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );
}
