import 'package:flutter/material.dart';
import 'package:flutter_stream_hive_app/core/theme/app_colors.dart';

/// App-specific colours that Material's [ColorScheme] has no slot for — the
/// live indicator, win/loss accents, score states, etc.
///
/// Exposed as a [ThemeExtension] so they're read theme-aware through the
/// [BuildContext] (and animate correctly via [lerp] when themes change),
/// instead of being hard-coded in widgets:
///
/// ```dart
/// Container(color: context.appColors.live)
/// ```
@immutable
class AppSemanticColors extends ThemeExtension<AppSemanticColors> {
  const AppSemanticColors({
    required this.live,
    required this.success,
    required this.warning,
    required this.info,
  });

  final Color live;
  final Color success;
  final Color warning;
  final Color info;

  /// The dark-theme instance, registered in `AppTheme.dark`.
  static const AppSemanticColors dark = AppSemanticColors(
    live: AppColors.live,
    success: AppColors.success,
    warning: AppColors.warning,
    info: AppColors.info,
  );

  @override
  AppSemanticColors copyWith({
    Color? live,
    Color? success,
    Color? warning,
    Color? info,
  }) {
    return AppSemanticColors(
      live: live ?? this.live,
      success: success ?? this.success,
      warning: warning ?? this.warning,
      info: info ?? this.info,
    );
  }

  @override
  AppSemanticColors lerp(ThemeExtension<AppSemanticColors>? other, double t) {
    if (other is! AppSemanticColors) return this;
    return AppSemanticColors(
      live: Color.lerp(live, other.live, t)!,
      success: Color.lerp(success, other.success, t)!,
      warning: Color.lerp(warning, other.warning, t)!,
      info: Color.lerp(info, other.info, t)!,
    );
  }
}

/// Ergonomic access: `context.appColors.live` instead of the verbose
/// `Theme.of(context).extension<AppSemanticColors>()!`.
extension AppSemanticColorsX on BuildContext {
  AppSemanticColors get appColors =>
      Theme.of(this).extension<AppSemanticColors>() ?? AppSemanticColors.dark;
}
