import 'package:flutter/material.dart';

class AppColors {
  // Brand & Primary Surfaces (Navy / Dark Blue)
  static const Color primaryNavy = Color(0xFF0F172A); // Slate 900
  static const Color primaryDark = Color(0xFF0A1128); // Deep Midnight
  static const Color primarySurface =
      Color(0xFF1E293B); // Slate 800 (Cards on dark/nav)
  static const Color primaryLight = Color(0xFF334155); // Slate 700

  // Primary Accent & Interactive Blue
  static const Color primaryBlue = Color(0xFF0284C7); // Sky 600
  static const Color primaryBlueLight = Color(0xFF38BDF8); // Sky 400
  static const Color primaryBlueDark = Color(0xFF0369A1); // Sky 700
  static const Color primaryBlueSubtle = Color(0xFFE0F2FE); // Sky 100

  // Secondary & Accent (Warm Gold / Amber for Growth)
  static const Color secondaryAmber = Color(0xFFF59E0B); // Amber 500
  static const Color secondaryAmberLight = Color(0xFFFEF3C7); // Amber 100
  static const Color secondaryAmberDark = Color(0xFFD97706); // Amber 600
  static const Color alertAmber = secondaryAmber;

  // Background & Surfaces (Light application background)
  static const Color backgroundLight = Color(0xFFF8FAFC); // Slate 50
  static const Color surfaceWhite = Color(0xFFFFFFFF);
  static const Color surfaceElevated = Color(0xFFFFFFFF);
  static const Color surfaceSubtle = Color(0xFFF1F5F9); // Slate 100
  static const Color surfaceBorder = Color(0xFFE2E8F0); // Slate 200
  static const Color divider = Color(0xFFE2E8F0);

  // Typography Colors
  static const Color textPrimary =
      Color(0xFF0F172A); // High contrast near-black
  static const Color textSecondary = Color(0xFF475569); // Slate 600
  static const Color textMuted = Color(0xFF94A3B8); // Slate 400
  static const Color textOnNavy = Color(0xFFFFFFFF);
  static const Color textOnNavySecondary = Color(0xFFCBD5E1); // Slate 300

  // Status & Semantic Indicators (Blue / Green / Amber / Red)
  static const Color successGreen = Color(0xFF10B981); // Emerald 500
  static const Color successGreenLight = Color(0xFFD1FAE5); // Emerald 100
  static const Color successGreenDark = Color(0xFF047857);

  static const Color warningOrange = Color(0xFFF59E0B);
  static const Color warningOrangeLight = Color(0xFFFEF3C7);

  static const Color errorRed = Color(0xFFEF4444); // Red 500
  static const Color errorRedLight = Color(0xFFFEE2E2); // Red 100
  static const Color errorRedDark = Color(0xFFB91C1C);

  static const Color infoBlue = Color(0xFF0284C7);
  static const Color infoBlueLight = Color(0xFFE0F2FE);

  // AI Glow & Intelligence Indicators
  static const Color aiPurple = Color(0xFF6366F1); // Indigo 500
  static const Color aiPurpleLight = Color(0xFFEEF2FF);
  static const Color aiGlow = Color(0x330284C7);
}
