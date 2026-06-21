import 'package:flutter/material.dart';

abstract final class AppColors {
  // --- Cubby brand ---
  static const primary = Color(0xFFFF6B45);
  static const primaryLight = Color(0xFFFF8C6E);
  static const secondary = Color(0xFFE8502B);
  static const accent = Color(0xFFFFB347);

  // --- Surfaces ---
  static const background = Color(0xFFFFF3E8);
  static const surface = Color(0xFFFFFFFF);
  static const surfaceElevated = Color(0xFFFFF8F3);

  // --- Text ---
  static const textPrimary = Color(0xFF2D2A26);
  static const textSecondary = Color(0xFF8C7B6E);
  static const textDisabled = Color(0xFFC4B5AB);

  // --- Borders & dividers ---
  static const divider = Color(0xFFEDE0D4);
  static const border = Color(0xFFE0CEBF);

  // --- Functional ---
  static const income = Color(0xFF2E9B5E);
  static const expense = Color(0xFFE74C3C);

  // --- Navigation (iOS/macOS style — white sidebar) ---
  static const navBackground = Color(0xFFFFFFFF);
  static const navItem = Color(0xFFB5A09A);
  static const navItemSelected = Color(0xFFFF6B45);
  static const navAccentLine = Color(0xFFFF6B45);

  // --- Account palette ---
  static const List<Color> accountColors = [
    Color(0xFFFF6B45),
    Color(0xFF2E9B5E),
    Color(0xFFFFB347),
    Color(0xFFE74C3C),
    Color(0xFF7C6EE8),
    Color(0xFF00A3B4),
    Color(0xFF8D6E63),
    Color(0xFF546E7A),
  ];
}
