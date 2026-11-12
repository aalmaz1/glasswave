import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';
import 'package:easy_localization/easy_localization.dart';
import '../services/date_formats.dart';
import '../theme/design_tokens.dart';
import 'glass_container.dart';

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
    String fmt(DateTime d) => GlassDates.reminder(d, locale);

    final quickPicks = [
      (tr('remind_today'), _todayAt(20)),
      (tr('remind_tomorrow'), _tomorrowAt(8)),
      (tr('remind_next_week'), _nextMonday()),
    ];

    return Material(
      type: MaterialType.transparency,
      child: Stack(
        children: [
          Positioned.fill(
            child: GestureDetector(
              onTap: () => Navigator.pop(context),
              child: Container(color: G.overlay),
            ),
          ),
          Center(
            child: Padding(
              padding: const EdgeInsets.all(24),
              child: ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 360),
                child: GlassContainer(
                  blur: 32,
                  borderRadius: 24,
                  border: Border.all(color: Colors.white.withValues(alpha: 0.26)),
                  boxShadow: G.modalShadow,
                  showRing: true,
                  ringColors: G.ringReminder,
                  ringStops: G.ringReminderStops,
                  padding: const EdgeInsets.fromLTRB(22, 22, 22, 20),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Expanded(
                            child: Row(
                              children: [
                                const Icon(LucideIcons.calendarClock,
                                    size: 18, color: Color(0xE6FFC83C)),
                                const SizedBox(width: 10),
                                Flexible(
                                  child: Text(
                                    tr('remind_title'),
                                    style: const TextStyle(
                                      fontWeight: FontWeight.w700,
                                      fontSize: 16,
                                      color: G.textPrimary,
                                    ),
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                ),
                              ],
                            ),
                          ),
                          GlassChip(
                            onTap: () => Navigator.pop(context),
                            child: const Icon(LucideIcons.x, size: 14, color: G.textSecondary),
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
                                    ? const Color(0x1FFFC83C)
                                    : G.bg,
                                borderRadius: BorderRadius.circular(14),
                                border: Border.all(
                                  color: active
                                      ? const Color(0x59FFC83C)
                                      : G.border,
                                ),
                              ),
                              child: Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                children: [
                                  Expanded(
                                    child: Text(
                                      pick.$1,
                                      style: const TextStyle(
                                        fontWeight: FontWeight.w600,
                                        fontSize: 13.5,
                                        color: G.textPrimary,
                                      ),
                                      overflow: TextOverflow.ellipsis,
                                    ),
                                  ),
                                  const SizedBox(width: 8),
                                  Text(
                                    fmt(pick.$2),
                                    style: const TextStyle(
                                      fontSize: 11.8,
                                      color: G.textSecondary,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        );
                      }),
                      const SizedBox(height: 10),
                      Text(
                        tr('remind_custom'),
                        style: const TextStyle(
                          fontSize: 10.9,
                          fontWeight: FontWeight.w600,
                          color: G.textMuted,
                          letterSpacing: 0.87,
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
                              Expanded(
                                child: Text(
                                  _selectedDate == null
                                      ? tr('remind_pick')
                                      : fmt(_selectedDate!),
                                  style: TextStyle(
                                    fontSize: 13.5,
                                    color: _selectedDate == null
                                        ? Colors.white.withValues(alpha: 0.24)
                                        : G.textPrimary,
                                  ),
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ),
                              const SizedBox(width: 8),
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
                                    padding: const EdgeInsets.symmetric(vertical: 11),
                                    alignment: Alignment.center,
                                    decoration: BoxDecoration(
                                      color: const Color(0x14FF5050),
                                      borderRadius: BorderRadius.circular(14),
                                      border: Border.all(
                                        color: const Color(0x47FF6464),
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
                                padding: const EdgeInsets.symmetric(vertical: 11),
                                alignment: Alignment.center,
                                decoration: BoxDecoration(
                                  color:
                                      _selectedDate == null
                                          ? Colors.white.withValues(alpha: 0.04)
                                          : const Color(0x24FFC83C),
                                  borderRadius: BorderRadius.circular(14),
                                  border: Border.all(
                                    color: const Color(0x59FFC83C),
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
        ],
      ),
    );
  }
}
