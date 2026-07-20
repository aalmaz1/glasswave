import 'package:flutter/material.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';
import 'glass_container.dart';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:easy_localization/easy_localization.dart';

class ReminderModal extends ConsumerStatefulWidget {
  final DateTime? initialDate;
  final Function(DateTime?) onSave;

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

  @override
  Widget build(BuildContext context) {
    final locale = context.locale.languageCode;
    final dateLocale = locale == 'ru' ? 'ru_RU' : 'en_US';

    return Dialog(
      backgroundColor: Colors.transparent,
      child: GlassContainer(
        borderRadius: 24,
        blur: 32,
        color: const Color(0xE6121218),
        child: Padding(
          padding: const EdgeInsets.all(22),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Row(
                    children: [
                      const Icon(LucideIcons.calendarClock, size: 18, color: Colors.amber),
                      const SizedBox(width: 10),
                      Text(tr('remind_title'), style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16, color: Colors.white)),
                    ],
                  ),
                  IconButton(
                    onPressed: () => Navigator.pop(context),
                    icon: const Icon(LucideIcons.x, size: 16, color: Colors.white30),
                  ),
                ],
              ),
              const SizedBox(height: 20),
              _quickPick(tr('remind_today'), "20:00", _todayAt(20), dateLocale),
              const SizedBox(height: 8),
              _quickPick(tr('remind_tomorrow'), "08:00", _tomorrowAt(8), dateLocale),
              const SizedBox(height: 8),
              _quickPick(tr('remind_next_week'), tr('remind_monday_at'), _nextMonday(), dateLocale),
              const SizedBox(height: 20),
              Align(
                alignment: Alignment.centerLeft,
                child: Text(tr('remind_custom'), style: const TextStyle(fontSize: 9, fontWeight: FontWeight.bold, color: Colors.white30, letterSpacing: 1.2)),
              ),
              const SizedBox(height: 8),
              InkWell(
                onTap: _pickDateTime,
                child: Container(
                  width: double.infinity,
                  padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
                  decoration: BoxDecoration(
                    color: Colors.white.withValues(alpha: 0.05),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: Colors.white10),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        _selectedDate == null ? tr('remind_pick') : DateFormat("d MMM, HH:mm", dateLocale).format(_selectedDate!),
                        style: TextStyle(color: _selectedDate == null ? Colors.white24 : Colors.white, fontSize: 14),
                      ),
                      const Icon(LucideIcons.calendar, size: 14, color: Colors.white30),
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
                        child: TextButton(
                          onPressed: () {
                            widget.onSave(null);
                            Navigator.pop(context);
                          },
                          style: TextButton.styleFrom(
                            backgroundColor: Colors.red.withValues(alpha: 0.1),
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14), side: BorderSide(color: Colors.red.withValues(alpha: 0.2))),
                            padding: const EdgeInsets.symmetric(vertical: 12),
                          ),
                          child: Text(tr('remind_delete'), style: const TextStyle(color: Colors.redAccent, fontWeight: FontWeight.bold)),
                        ),
                      ),
                    ),
                  Expanded(
                    flex: 2,
                    child: TextButton(
                      onPressed: _selectedDate == null ? null : () {
                        widget.onSave(_selectedDate);
                        Navigator.pop(context);
                      },
                      style: TextButton.styleFrom(
                        backgroundColor: _selectedDate == null ? Colors.white10 : Colors.amber.withValues(alpha: 0.14),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14), side: BorderSide(color: _selectedDate == null ? Colors.white10 : Colors.amber.withValues(alpha: 0.35))),
                        padding: const EdgeInsets.symmetric(vertical: 12),
                      ),
                      child: Text(tr('remind_save'), style: TextStyle(color: _selectedDate == null ? Colors.white24 : Colors.amber, fontWeight: FontWeight.bold)),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _quickPick(String label, String sub, DateTime val, String dateLocale) {
    final active = _selectedDate != null &&
        _selectedDate!.year == val.year &&
        _selectedDate!.month == val.month &&
        _selectedDate!.day == val.day &&
        _selectedDate!.hour == val.hour;

    return InkWell(
      onTap: () => setState(() => _selectedDate = val),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 11),
        decoration: BoxDecoration(
          color: active ? Colors.amber.withValues(alpha: 0.12) : Colors.white.withValues(alpha: 0.02),
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: active ? Colors.amber.withValues(alpha: 0.3) : Colors.white10),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(label, style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 14, color: Colors.white)),
            Text(DateFormat("d MMM, HH:mm", dateLocale).format(val), style: const TextStyle(fontSize: 12, color: Colors.white38)),
          ],
        ),
      ),
    );
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
}
