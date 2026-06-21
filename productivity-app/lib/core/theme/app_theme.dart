import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'app_colors.dart';

final appTheme = ThemeData(
  useMaterial3: true,
  colorScheme: ColorScheme.light(
    primary: AppColors.primary,
    secondary: AppColors.accent,
    surface: AppColors.surface,
    onPrimary: Colors.white,
    onSecondary: AppColors.textPrimary,
    onSurface: AppColors.textPrimary,
  ),
  scaffoldBackgroundColor: AppColors.background,
  textTheme: GoogleFonts.interTextTheme(ThemeData.light().textTheme),
  dividerTheme: const DividerThemeData(
    color: AppColors.divider,
    thickness: 1,
    space: 0,
  ),
  // --- Cards: soft shadow, generous radius ---
  cardTheme: CardThemeData(
    color: AppColors.surface,
    elevation: 0,
    surfaceTintColor: Colors.transparent,
    shape: RoundedRectangleBorder(
      borderRadius: BorderRadius.circular(16),
    ),
    margin: EdgeInsets.zero,
  ),
  // --- Inputs: warm fill, soft border ---
  inputDecorationTheme: InputDecorationTheme(
    filled: true,
    fillColor: AppColors.surfaceElevated,
    border: OutlineInputBorder(
      borderRadius: BorderRadius.circular(12),
      borderSide: const BorderSide(color: AppColors.border),
    ),
    enabledBorder: OutlineInputBorder(
      borderRadius: BorderRadius.circular(12),
      borderSide: const BorderSide(color: AppColors.border),
    ),
    focusedBorder: OutlineInputBorder(
      borderRadius: BorderRadius.circular(12),
      borderSide: const BorderSide(color: AppColors.primary, width: 1.5),
    ),
    contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
    labelStyle:
        const TextStyle(color: AppColors.textSecondary, fontSize: 14),
    hintStyle: const TextStyle(color: AppColors.textDisabled, fontSize: 14),
  ),
  // --- Buttons: coral, rounded ---
  elevatedButtonTheme: ElevatedButtonThemeData(
    style: ElevatedButton.styleFrom(
      backgroundColor: AppColors.primary,
      foregroundColor: Colors.white,
      elevation: 0,
      shadowColor: Colors.transparent,
      padding:
          const EdgeInsets.symmetric(horizontal: 20, vertical: 13),
      shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12)),
      textStyle: const TextStyle(
        fontSize: 14,
        fontWeight: FontWeight.w600,
        letterSpacing: 0.1,
      ),
    ),
  ),
  textButtonTheme: TextButtonThemeData(
    style: TextButton.styleFrom(
      foregroundColor: AppColors.primary,
      padding:
          const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
      shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(10)),
    ),
  ),
  outlinedButtonTheme: OutlinedButtonThemeData(
    style: OutlinedButton.styleFrom(
      foregroundColor: AppColors.primary,
      side: const BorderSide(color: AppColors.primary),
      padding:
          const EdgeInsets.symmetric(horizontal: 20, vertical: 13),
      shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12)),
    ),
  ),
  // --- Dialogs: Apple-style large radius, soft shadow ---
  dialogTheme: DialogThemeData(
    backgroundColor: AppColors.surface,
    surfaceTintColor: Colors.transparent,
    elevation: 0,
    shadowColor: Colors.transparent,
    shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(20)),
    titleTextStyle: const TextStyle(
      fontSize: 17,
      fontWeight: FontWeight.w600,
      color: AppColors.textPrimary,
    ),
  ),
  // --- Chips ---
  chipTheme: ChipThemeData(
    backgroundColor: AppColors.surfaceElevated,
    selectedColor: AppColors.primary.withValues(alpha: 0.12),
    labelStyle: const TextStyle(
        fontSize: 13,
        fontWeight: FontWeight.w500,
        color: AppColors.textPrimary),
    side: const BorderSide(color: AppColors.border),
    shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(8)),
    padding:
        const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
    showCheckmark: false,
  ),
  // --- PopupMenu ---
  popupMenuTheme: PopupMenuThemeData(
    color: AppColors.surface,
    surfaceTintColor: Colors.transparent,
    elevation: 0,
    shadowColor: Colors.transparent,
    shape: RoundedRectangleBorder(
      borderRadius: BorderRadius.circular(14),
      side: const BorderSide(color: AppColors.border),
    ),
    textStyle: const TextStyle(
        fontSize: 13,
        fontWeight: FontWeight.w500,
        color: AppColors.textPrimary),
  ),
  // --- Checkbox ---
  checkboxTheme: CheckboxThemeData(
    fillColor: WidgetStateProperty.resolveWith((states) {
      if (states.contains(WidgetState.selected)) {
        return AppColors.primary;
      }
      return Colors.transparent;
    }),
    checkColor: WidgetStateProperty.all(Colors.white),
    side: const BorderSide(color: AppColors.border, width: 1.5),
    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(4)),
  ),
  // --- SnackBar ---
  snackBarTheme: SnackBarThemeData(
    behavior: SnackBarBehavior.floating,
    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
  ),
);

// Reusable card shadow used across the app
const cardShadow = [
  BoxShadow(
    color: Color(0x142D2A26),
    blurRadius: 16,
    offset: Offset(0, 4),
  ),
  BoxShadow(
    color: Color(0x0A2D2A26),
    blurRadius: 4,
    offset: Offset(0, 1),
  ),
];

// Lighter shadow for nested surfaces
const subtleShadow = [
  BoxShadow(
    color: Color(0x0D2D2A26),
    blurRadius: 8,
    offset: Offset(0, 2),
  ),
];
