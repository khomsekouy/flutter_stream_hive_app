import 'package:flutter/material.dart';

/// The single source of truth for every raw colour in the app.
///
/// Widgets should never hard-code `Color(0x...)` or `Colors.red`. They either
/// reference these constants directly (for fixed brand values) or — better for
/// anything that should adapt to the theme — go through the [ColorScheme] and
/// the `AppSemanticColors` extension. One palette here means a rebrand or a
/// dark/light tweak is a single-file change.
abstract final class AppColors {
  const AppColors._();

  // ---- Brand ----
  static const Color primary = Color(0xFF6C2BD9);
  static const Color primaryDark = Color(0xFF4C1D95);
  static const Color primaryLight = Color(0xFF9F67FF);
  static const Color secondary = Color(0xFF00C2A8);

  /// Lime green — reserved for primary call-to-action buttons ONLY
  /// (e.g. "Get started"). The brand colour is [primary] (purple); don't use
  /// this as a general accent.
  static const Color cta = Color(0xFFA5E635);

  // ---- Neutrals (dark-first — this is a dark streaming UI) ----
  static const Color background = Color(0xFF0E0E12);
  static const Color surface = Color(0xFF1A1A22);
  static const Color surfaceHigh = Color(0xFF26262F);
  static const Color outline = Color(0xFF3A3A45);

  // ---- Text ----
  static const Color textPrimary = Color(0xFFF5F5F7);
  static const Color textSecondary = Color(0xFFB5B5C0);
  static const Color textDisabled = Color(0xFF6E6E78);

  // ---- Semantic ----
  static const Color live = Color(0xFFE5202E); // the "LIVE" indicator
  static const Color success = Color(0xFF2ECC71);
  static const Color warning = Color(0xFFF5A623);
  static const Color error = Color(0xFFE53935);
  static const Color info = Color(0xFF3B82F6);

  // ---- Common ----
  static const Color white = Color(0xFFFFFFFF);
  static const Color black = Color(0xFF000000);
}
