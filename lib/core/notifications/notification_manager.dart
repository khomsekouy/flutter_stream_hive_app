import 'package:flutter/material.dart';
import 'package:flutter_stream_hive_app/core/theme/app_colors.dart';
import 'package:top_snackbar_flutter/top_snack_bar.dart';

/// App-wide entry point for transient, top-of-screen notifications.
///
/// Renders the custom [CompactSnackBar] pill via `top_snackbar_flutter` so the
/// rest of the app never touches the package directly. Prefer the
/// [success] / [info] / [error] helpers; [show] is the flexible escape hatch.
class NotificationManager {
  const NotificationManager._();

  static const Color _successColor = Color(0xFF34C759);
  static const Color _errorColor = Color(0xFFFF3B30);
  static const Color _infoColor = Color(0xFF2196F3);

  /// Green success toast.
  static void success(BuildContext context, String message) =>
      show(context, message: message);

  /// Blue informational toast.
  static void info(BuildContext context, String message) => show(
    context,
    message: message,
    backgroundColor: _infoColor,
    icon: Icons.info_rounded,
  );

  /// Red error toast.
  static void error(BuildContext context, String message) => show(
    context,
    message: message,
    backgroundColor: _errorColor,
    icon: Icons.error_rounded,
  );

  /// Shows a top snackbar. The flavour (success / info / error) is inferred
  /// from [backgroundColor] / [icon], defaulting to success.
  ///
  /// No-ops if there is no [Overlay] in scope, so it is always safe to call.
  static void show(
    BuildContext context, {
    required String message,
    Color backgroundColor = _successColor,
    IconData icon = Icons.check_circle_rounded,
  }) {
    final overlay = Overlay.maybeOf(context, rootOverlay: true);
    if (overlay == null) return;

    final bar = _barFor(backgroundColor, icon, message);

    void display() {
      if (!overlay.mounted) return;
      showTopSnackBar(overlay, bar);
    }

    WidgetsBinding.instance.addPostFrameCallback((_) => display());
  }

  static CompactSnackBar _barFor(Color color, IconData icon, String message) {
    final isError =
        color == _errorColor ||
        color == Colors.red ||
        icon == Icons.error ||
        icon == Icons.error_rounded ||
        icon == Icons.error_outline;
    if (isError) return CompactSnackBar.error(message: message);

    final isInfo =
        color == _infoColor ||
        icon == Icons.info ||
        icon == Icons.info_rounded ||
        icon == Icons.info_outline;
    if (isInfo) return CompactSnackBar.info(message: message);

    return CompactSnackBar.success(message: message);
  }
}

/// A compact, rounded notification pill: a leading status icon beside a short
/// message. Built outside the Material tree (it lives in an overlay), so text
/// styling and [TextDecoration.none] are set explicitly.
class CompactSnackBar extends StatelessWidget {
  const CompactSnackBar({
    required this.message,
    required this.color,
    required this.icon,
    super.key,
  });

  factory CompactSnackBar.success({required String message}) {
    return CompactSnackBar(
      message: message,
      color: const Color(0xFF34C759),
      icon: Icons.check_circle_rounded,
    );
  }

  factory CompactSnackBar.error({required String message}) {
    return CompactSnackBar(
      message: message,
      color: const Color(0xFFFF3B30),
      icon: Icons.error_rounded,
    );
  }

  factory CompactSnackBar.info({required String message}) {
    return CompactSnackBar(
      message: message,
      color: const Color(0xFF2196F3),
      icon: Icons.info_rounded,
    );
  }

  final String message;
  final Color color;
  final IconData icon;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        color: color,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: color.withValues(alpha: 0.3),
            blurRadius: 8,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Row(
        children: [
          Icon(icon, color: AppColors.white, size: 20),
          const SizedBox(width: 10),
          Expanded(
            child: Text(
              message,
              style: const TextStyle(
                color: AppColors.white,
                fontSize: 14,
                fontWeight: FontWeight.w500,
                decoration: TextDecoration.none,
              ),
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
            ),
          ),
        ],
      ),
    );
  }
}
