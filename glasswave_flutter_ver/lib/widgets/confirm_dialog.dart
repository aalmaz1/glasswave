import 'package:flutter/material.dart';
import '../theme/design_tokens.dart';
import 'glass_container.dart';

enum GlassConfirmChoice { cancel, confirm, extra }

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
    transitionDuration: const Duration(milliseconds: 240),
    transitionBuilder: (context, animation, secondaryAnimation, child) {
      final curvedAnimation = CurvedAnimation(
        parent: animation,
        curve: Curves.easeOutCubic,
        reverseCurve: Curves.easeInCubic,
      );
      return FadeTransition(
        opacity: curvedAnimation,
        child: ScaleTransition(
          scale: Tween<double>(begin: 0.94, end: 1.0).animate(curvedAnimation),
          child: child,
        ),
      );
    },
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
    return Material(
      type: MaterialType.transparency,
      child: Stack(
        children: [
          Positioned.fill(
            child: GestureDetector(
              onTap: onCancel,
              child: Container(color: G.overlay),
            ),
          ),
          Center(
            child: Padding(
              padding: const EdgeInsets.all(20),
              child: ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 400),
                child: GlassContainer(
                  blur: 28,
                  borderRadius: 22,
                  border: Border.all(
                    color: danger
                        ? const Color(0x61FF7373)
                        : const Color(0x38FFFFFF),
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
                              ? const Color(0xFAFFD7D7)
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
                      Wrap(
                        alignment: WrapAlignment.end,
                        runAlignment: WrapAlignment.end,
                        spacing: 8,
                        runSpacing: 8,
                        children: [
                          _ConfirmBtn(
                            label: cancelLabel,
                            onTap: onCancel,
                            style: _ConfirmBtnStyle.neutral,
                          ),
                          if (extraLabel != null && onExtra != null)
                            _ConfirmBtn(
                              label: extraLabel!,
                              onTap: onExtra!,
                              style: _ConfirmBtnStyle.light,
                            ),
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
        ],
      ),
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
        background = const Color(0x6BE13741);
        border = const Color(0x8CFF6969);
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
