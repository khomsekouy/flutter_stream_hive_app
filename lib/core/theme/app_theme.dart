import 'package:flutter/material.dart';
import 'package:flutter_stream_hive_app/core/theme/app_colors.dart';
import 'package:flutter_stream_hive_app/core/theme/app_semantic_colors.dart';

/// Builds the app's [ThemeData] from [AppColors].
///
/// Material 3's [ColorScheme.fromSeed] generates a harmonious scheme from the
/// brand seed; we lock the key brand slots to the exact palette values and
/// attach [AppSemanticColors] so streaming-specific colours travel with the
/// theme. `app.dart` just does `theme: AppTheme.dark`.
abstract final class AppTheme {
  const AppTheme._();

  static ThemeData get dark {
    final colorScheme = ColorScheme.fromSeed(
      seedColor: AppColors.primary,
      brightness: Brightness.dark,
      primary: AppColors.primary,
      secondary: AppColors.secondary,
      surface: AppColors.surface,
      error: AppColors.error,
    );

    return ThemeData(
      useMaterial3: true,
      colorScheme: colorScheme,
      scaffoldBackgroundColor: AppColors.background,
      extensions: const <ThemeExtension<dynamic>>[AppSemanticColors.dark],
    );
  }
}
