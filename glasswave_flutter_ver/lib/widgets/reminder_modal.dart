import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';
import 'package:intl/intl.dart';
import 'package:easy_localization/easy_localization.dart';
import '../theme/design_tokens.dart';
import 'glass_container.dart';

/// Opens the reminder modal styled 1:1 like the React Native `ReminderModal`
/// (glass 24, quick picks, custom picker, delete/save actions).
Future<void> showReminderModal(
  BuildContext context, {
  DateTime? initialDate,
  required ValueChanged<DateTime?> onSave,
}) {
  return showGeneralDialog<void>(
    context: context,
    barrierDismissible: false,
    barrierLabel: 'reminder',
    barrierColor: Colors.transparent,
    transitionDuration: const Duration(milliseconds: 220),
      transitionBuilder: (context, animation, secondaryAnimation, child) => child,
    pageBuilder: (dialogContext, animation, secondaryAnimation) {
      return ReminderModal(initialDate: initialDate, onSave: onSave);
    },
  );
}

class ReminderModal extends ConsumerStatefulWidget {
  final DateTime? initialDate;
  final ValueChanged<DateTime?> onSave;

  const ReminderModal({super.key, this.initialDate, required this.onSave});

  @override
  ConsumerState<ReminderModal> createState() => _ReminderModalState();
}

class _ReminderModalState extends ConsumerState<ReminderModal> {
  DateTime? _selectedDate;

  @override
  void initState() {
    super.initState();
    _selectedDate = widget.initialDate;
  }

  String _dateLocale(String langCode) {
    switch (langCode) {
      case 'ru':
        return 'ru_RU';
      case 'ko':
        return 'ko_KR';
      default:
        return 'en_US';
    }
  }

  DateTime _todayAt(int h) {
    final now = DateTime.now();
    var d = DateTime(now.year, now.month, now.day, h);
    if (d.isBefore(now)) d = d.add(const Duration(days: 1));
    return d;
  }

  DateTime _tomorrowAt(int h) {
    final now = DateTime.now();
    return DateTime(now.year, now.month, now.day + 1, h);
  }

  DateTime _nextMonday() {
    final now = DateTime.now();
    var d = now.add(Duration(days: (8 - now.weekday) % 7));
    if (d.day == now.day) d = d.add(const Duration(days: 7));
    return DateTime(d.year, d.month, d.day, 8);
  }

  void _pickDateTime() async {
    final minDate = DateTime.now().add(const Duration(minutes: 1));
    final date = await showDatePicker(
      context: context,
      initialDate: _selectedDate ?? minDate,
      firstDate: minDate,
      lastDate: DateTime.now().add(const Duration(days: 365)),
    );
    if (date != null && mounted) {
      final time = await showTimePicker(
        context: context,
        initialTime: TimeOfDay.fromDateTime(_selectedDate ?? minDate),
      );
      if (time != null) {
        setState(() {
          _selectedDate = DateTime(date.year, date.month, date.day, time.hour, time.minute);
        });
      }
    }
  }

  bool _isActive(DateTime val) {
    final d = _selectedDate;
    if (d == null) return false;
    return d.year == val.year &&
        d.month == val.month &&
        d.day == val.day &&
        d.hour == val.hour &&
        d.minute == val.minute;
  }

  @override
  Widget build(BuildContext context) {
    final locale = context.locale.languageCode;
    final dateLocale = _dateLocale(locale);
    final fmt = DateFormat('d MMMM, HH:mm', dateLocale);

    final quickPicks = [
      (tr('remind_today'), _todayAt(20)),
      (tr('remind_tomorrow'), _tomorrowAt(8)),
      (tr('remind_next_week'), _nextMonday()),
    ];

    return Stack(
      children: [
        Positioned.fill(
          child: GestureDetector(
            onTap: () => Navigator.pop(context),
            child: BackdropFilter(
              filter: ImageFilter.blur(sigmaX: 4, sigmaY: 4),
              child: Container(color: Colors.black.withValues(alpha: 0.55)),
            ),
          ),
        ),
        Center(
          child: Padding(
            padding: const EdgeInsets.all(24),
            child: TweenAnimationBuilder<double>(
              tween: Tween(begin: 0.0, end: 1.0),
              duration: const Duration(milliseconds: 260),
              curve: const Cubic(0.34, 1.46, 0.64, 1.0),
              builder: (context, value, child) {
                return Transform.scale(
                  scale: 0.96 + 0.04 * value,
                  child: Opacity(opacity: value, child: child),
                );
              },
              child: ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 360),
                child: GlassContainer(
                  blur: 32,
                  borderRadius: 24,
                  border: Border.all(color: Colors.white.withValues(alpha: 0.26)),
                  boxShadow: G.modalShadow,
                  padding: const EdgeInsets.fromLTRB(22, 22, 22, 20),
                                    child: Column(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Row(
                            children: [
                              const Icon(LucideIcons.calendarClock,
                                  size: 18, color: Color(0xE6FFC83C)),
                              const SizedBox(width: 10),
                              Text(
                                tr('remind_title'),
                                style: const TextStyle(
                                    fontWeight: FontWeight.w700,
                                    fontSize: 16,
                                    color: G.textPrimary),
                              ),
                            ],
                          ),
                          IconButton(
                            onPressed: () => Navigator.pop(context),
                            icon: const Icon(LucideIcons.x, size: 16, color: G.textMuted),
                            padding: EdgeInsets.zero,
                            constraints: const BoxConstraints(),
                          ),
                        ],
                      ),
                      const SizedBox(height: 20),
                      ...quickPicks.map((pick) {
                        final active = _isActive(pick.$2);
                        return Padding(
                          padding: const EdgeInsets.only(bottom: 8),
                          child: GestureDetector(
                            onTap: () => setState(() => _selectedDate = pick.$2),
                            child: Container(
                              padding:
                                  const EdgeInsets.symmetric(horizontal: 14, vertical: 11),
                              decoration: BoxDecoration(
                                color: active
                                    ? const Color(0x1FFFC83C) // rgba(255,200,60,0.12)
                                    : G.bg,
                                borderRadius: BorderRadius.circular(14),
                                border: Border.all(
                                  color: active
                                      ? const Color(0x59FFC83C) // rgba(255,200,60,0.35)
                                      : G.border,
                                ),
                              ),
                              child: Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                children: [
                                  Text(
                                    pick.$1,
                                    style: const TextStyle(
                                      fontWeight: FontWeight.w600,
                                      fontSize: 13.8,
                                      color: G.textPrimary,
                                    ),
                                  ),
                                  Text(
                                    fmt.format(pick.$2),
                                    style: const TextStyle(
                                      fontSize: 12.2,
                                      color: G.textSecondary,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        );
                      }),
                      const SizedBox(height: 12),
                      Text(
                        tr('remind_custom'),
                        style: const TextStyle(
                          fontSize: 10.9,
                          fontWeight: FontWeight.w600,
                          color: G.textMuted,
                          letterSpacing: 1.3,
                        ),
                      ),
                      const SizedBox(height: 8),
                      GestureDetector(
                        onTap: _pickDateTime,
                        child: Container(
                          width: double.infinity,
                          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
                          decoration: BoxDecoration(
                            color: Colors.white.withValues(alpha: 0.05),
                            borderRadius: BorderRadius.circular(12),
                            border: Border.all(color: G.border),
                          ),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text(
                                _selectedDate == null
                                    ? tr('remind_pick')
                                    : fmt.format(_selectedDate!),
                                style: TextStyle(
                                  fontSize: 13.8,
                                  color: _selectedDate == null
                                      ? Colors.white.withValues(alpha: 0.24)
                                      : G.textPrimary,
                                ),
                              ),
                              const Icon(LucideIcons.calendar, size: 14, color: G.textMuted),
                            ],
                          ),
                        ),
                      ),
                      const SizedBox(height: 20),
                      Row(
                        children: [
                          if (widget.initialDate != null)
                            Expanded(
                              child: Padding(
                                padding: const EdgeInsets.only(right: 8),
                                child: GestureDetector(
                                  onTap: () {
                                    widget.onSave(null);
                                    Navigator.pop(context);
                                  },
                                  child: Container(
                                    padding: const EdgeInsets.symmetric(vertical: 12),
                                    alignment: Alignment.center,
                                    decoration: BoxDecoration(
                                      color: const Color(0x14FF5050), // rgba(255,80,80,0.08)
                                      borderRadius: BorderRadius.circular(14),
                                      border: Border.all(
                                        color: const Color(0x47FF6464), // rgba(255,100,100,0.28)
                                      ),
                                    ),
                                    child: Text(
                                      tr('remind_delete'),
                                      style: const TextStyle(
                                        fontSize: 13.4,
                                        fontWeight: FontWeight.w600,
                                        color: Color(0xE6FF7878),
                                      ),
                                    ),
                                  ),
                                ),
                              ),
                            ),
                          Expanded(
                            flex: 2,
                            child: GestureDetector(
                              onTap: _selectedDate == null
                                  ? null
                                  : () {
                                      widget.onSave(_selectedDate);
                                      Navigator.pop(context);
                                    },
                              child: Container(
                                padding: const EdgeInsets.symmetric(vertical: 12),
                                alignment: Alignment.center,
                                decoration: BoxDecoration(
                                  color:
                                      _selectedDate == null
                                          ? Colors.white.withValues(alpha: 0.04)
                                          : const Color(0x24FFC83C), // rgba(255,200,60,0.14)
                                  borderRadius: BorderRadius.circular(14),
                                  border: Border.all(
                                    color: const Color(0x59FFC83C), // rgba(255,200,60,0.35)
                                  ),
                                ),
                                child: Text(
                                  tr('remind_save'),
                                  style: TextStyle(
                                    fontSize: 13.4,
                                    fontWeight: FontWeight.w700,
                                    color: _selectedDate == null
                                        ? G.textMuted
                                        : const Color(0xF2FFD250),
                                  ),
                                ),
                              ),
                            ),
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
