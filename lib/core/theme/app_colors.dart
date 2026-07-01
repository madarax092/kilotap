import 'package:flutter/material.dart';

/// KiloTap Brand Color Palette
class AppColors {
  AppColors._();

  // ─── Primary Brand Colors ───────────────────────────────────────────────────
  /// Seller Green - Trustworthy, sustainability-focused green
  static const Color sellerGreen = Color(0xFF1B8A5A);
  static const Color sellerGreenDark = Color(0xFF136A44);
  static const Color sellerGreenLight = Color(0xFF4DAF84);
  static const Color sellerGreenSurface = Color(0xFFE8F6EF);

  /// Buyer Blue - Dependable, logistics-focused blue
  static const Color buyerBlue = Color(0xFF1A85C8);
  static const Color buyerBlueDark = Color(0xFF1165A0);
  static const Color buyerBlueLight = Color(0xFF55ABDF);
  static const Color buyerBlueSurface = Color(0xFFE5F3FB);

  // ─── Neutral Palette ────────────────────────────────────────────────────────
  /// Pure White - Card backgrounds and input fields
  static const Color pureWhite = Color(0xFFFFFFFF);

  /// App Canvas - Very soft off-white grey background
  static const Color appCanvas = Color(0xFFF8F9FA);

  /// Input/Inactive - Soft grey for tabs and form fields
  static const Color inputBackground = Color(0xFFEDF1F3);

  // ─── Text Colors ────────────────────────────────────────────────────────────
  static const Color textPrimary = Color(0xFF1A1A2E);
  static const Color textSecondary = Color(0xFF6B7280);
  static const Color textHint = Color(0xFF9CA3AF);
  static const Color textOnPrimary = Color(0xFFFFFFFF);

  // ─── Semantic Colors ────────────────────────────────────────────────────────
  static const Color success = Color(0xFF1B8A5A);
  static const Color error = Color(0xFFDC2626);
  static const Color warning = Color(0xFFF59E0B);
  static const Color info = Color(0xFF1A85C8);

  // ─── Border & Divider ───────────────────────────────────────────────────────
  static const Color border = Color(0xFFD1D5DB);
  static const Color divider = Color(0xFFE5E7EB);

  // ─── Rating Stars ───────────────────────────────────────────────────────────
  static const Color starActive = Color(0xFFF59E0B);
  static const Color starInactive = Color(0xFFD1D5DB);

  // ─── Status Badge Colors ────────────────────────────────────────────────────
  static const Color statusCompleted = Color(0xFF1B8A5A);
  static const Color statusCompletedSurface = Color(0xFFE8F6EF);
  static const Color statusPending = Color(0xFFF59E0B);
  static const Color statusPendingSurface = Color(0xFFFEF3C7);
  static const Color statusCancelled = Color(0xFFDC2626);
  static const Color statusCancelledSurface = Color(0xFFFEE2E2);

  // ─── Navigation ─────────────────────────────────────────────────────────────
  static const Color navBackground = Color(0xFFFFFFFF);
  static const Color navInactive = Color(0xFF9CA3AF);
}
