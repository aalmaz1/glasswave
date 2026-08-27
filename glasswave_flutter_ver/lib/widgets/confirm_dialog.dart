import 'dart:ui';
import 'package:flutter/material.dart';
import '../theme/design_tokens.dart';
import 'glass_container.dart';

enum GlassConfirmChoice { cancel, confirm, extra }

/// Opens a glass confirm dialog styled 1:1 like the React Native
/// `ConfirmDialog` (max 400px, radius 22, danger/neutral variants).
Future<GlassConfirmChoice?> showGlassConfirm(
  BuildContext context, {
  required String title,
  required String body,
  required String confirmLabel,
  required String cancelLabel,
  String? extraLabel,
  bool danger = true,
}) {
  return showGeneralDialog<GlassConfirmChoice>(
    context: context,
    barrierDismissible: false,
    barrierLabel: 'confirm',
    barrierColor: Colors.transparent,
    transitionDuration: const Duration(milliseconds: 220),
      transitionBuilder: (context, animation, secondaryAnimation, child) => child,
    pageBuilder: (dialogContext, animation, secondaryAnimation) {
      return GlassConfirmOverlay(
        title: title,
        body: body,
        confirmLabel: confirmLabel,
        cancelLabel: cancelLabel,
        extraLabel: extraLabel,
        danger: danger,
        onCancel: () => Navigator.pop(dialogContext, GlassConfirmChoice.cancel),
        onConfirm: () => Navigator.pop(dialogContext, GlassConfirmChoice.confirm),
        onExtra: extraLabel == null
            ? null
            : () => Navigator.pop(dialogContext, GlassConfirmChoice.extra),
      );
    },
  );
}

class GlassConfirmOverlay extends StatelessWidget {
  final String title;
  final String body;
  final String confirmLabel;
  final String cancelLabel;
  final String? extraLabel;
  final bool danger;
  final VoidCallback onCancel;
  final VoidCallback onConfirm;
  final VoidCallback? onExtra;

  const GlassConfirmOverlay({
    super.key,
    required this.title,
    required this.body,
    required this.confirmLabel,
    required this.cancelLabel,
    this.extraLabel,
    this.danger = true,
    required this.onCancel,
    required this.onConfirm,
    this.onExtra,
  });

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        Positioned.fill(
          child: GestureDetector(
            onTap: onCancel,
            child: BackdropFilter(
              filter: ImageFilter.blur(sigmaX: 5, sigmaY: 5),
              child: Container(color: Colors.black.withValues(alpha: 0.62)),
            ),
          ),
        ),
        Center(
          child: Padding(
            padding: const EdgeInsets.all(20),
            child: TweenAnimationBuilder<double>(
              tween: Tween(begin: 0.0, end: 1.0),
              duration: const Duration(milliseconds: 220),
              curve: const Cubic(0.34, 1.46, 0.64, 1.0),
              builder: (context, value, child) {
                return Transform.scale(
                  scale: 0.96 + 0.04 * value,
                  child: Opacity(opacity: value, child: child),
                );
              },
              child: ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 400),
                child: GlassContainer(
                  blur: 28,
                  borderRadius: 22,
                  border: Border.all(
                    color: danger
                        ? const Color(0x61FF7373) // rgba(255,115,115,0.38)
                        : const Color(0x38FFFFFF), // rgba(255,255,255,0.22)
                  ),
                  boxShadow: G.confirmShadow,
                  padding: const EdgeInsets.fromLTRB(22, 22, 22, 20),
                                    child: Column(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        title,
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w700,
                          color: danger
                              ? const Color(0xFAFFD7D7) // rgba(255,215,215,0.98)
                              : G.textPrimary,
                        ),
                      ),
                      const SizedBox(height: 10),
                      Text(
                        body,
                        style: const TextStyle(
                          fontSize: 13.1,
                          height: 1.55,
                          color: G.textSecondary,
                        ),
                      ),
                      const SizedBox(height: 20),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.end,
                        children: [
                          _ConfirmBtn(
                            label: cancelLabel,
                            onTap: onCancel,
                            style: _ConfirmBtnStyle.neutral,
                          ),
                          if (extraLabel != null && onExtra != null) ...[
                            const SizedBox(width: 8),
                            _ConfirmBtn(
                              label: extraLabel!,
                              onTap: onExtra!,
                              style: _ConfirmBtnStyle.light,
                            ),
                          ],
                          const SizedBox(width: 8),
                          _ConfirmBtn(
                            label: confirmLabel,
                            onTap: onConfirm,
                            style:
                                danger ? _ConfirmBtnStyle.danger : _ConfirmBtnStyle.highlight,
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }
}

enum _ConfirmBtnStyle { neutral, light, danger, highlight }

class _ConfirmBtn extends StatelessWidget {
  final String label;
  final VoidCallback onTap;
  final _ConfirmBtnStyle style;

  const _ConfirmBtn({required this.label, required this.onTap, required this.style});

  @override
  Widget build(BuildContext context) {
    final Color background;
    final Color border;
    final Color text;
    final FontWeight weight;
    switch (style) {
      case _ConfirmBtnStyle.neutral:
        background = Colors.white.withValues(alpha: 0.05);
        border = G.border;
        text = G.textSecondary;
        weight = FontWeight.w600;
        break;
      case _ConfirmBtnStyle.light:
        background = Colors.white.withValues(alpha: 0.08);
        border = G.border;
        text = G.textPrimary;
        weight = FontWeight.w600;
        break;
      case _ConfirmBtnStyle.danger:
        // rgba(225,55,65,0.42)
        background = const Color(0x6BE13741);
        border = const Color(0x8CFF6969); // rgba(255,105,105,0.55)
        text = Colors.white;
        weight = FontWeight.w700;
        break;
      case _ConfirmBtnStyle.highlight:
        background = Colors.white.withValues(alpha: 0.16);
        border = Colors.white.withValues(alpha: 0.35);
        text = Colors.white;
        weight = FontWeight.w700;
        break;
    }
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
        decoration: BoxDecoration(
          color: background,
          borderRadius: BorderRadius.circular(11),
          border: Border.all(color: border),
        ),
        child: Text(
          label,
          style: TextStyle(fontSize: 12.8, fontWeight: weight, color: text),
        ),
      ),
    );
  }
}
