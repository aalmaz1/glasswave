import 'package:flutter/material.dart';

/// Модальное окно напоминания
class ReminderModal extends StatefulWidget {
  final DateTime? currentReminder;
  final Function(DateTime?) onSave;
  final VoidCallback onClose;

  const ReminderModal({
    super.key,
    this.currentReminder,
    required this.onSave,
    required this.onClose,
  });

  @override
  State<ReminderModal> createState() => _ReminderModalState();
}

class _ReminderModalState extends State<ReminderModal> {
  DateTime? _selectedDate;
  TimeOfDay? _selectedTime;

  @override
  void initState() {
    super.initState();
    if (widget.currentReminder != null) {
      _selectedDate = widget.currentReminder;
      _selectedTime = TimeOfDay.fromDateTime(widget.currentReminder!);
    }
  }

  Future<void> _pickDate() async {
    final date = await showDatePicker(
      context: context,
      initialDate: _selectedDate ?? DateTime.now(),
      firstDate: DateTime.now(),
      lastDate: DateTime.now().add(const Duration(days: 365)),
    );
    if (date != null) {
      setState(() => _selectedDate = date);
    }
  }

  Future<void> _pickTime() async {
    final time = await showTimePicker(
      context: context,
      initialTime: _selectedTime ?? TimeOfDay.now(),
    );
    if (time != null) {
      setState(() => _selectedTime = time);
    }
  }

  void _setQuickReminder(Duration duration) {
    final now = DateTime.now();
    final dateTime = now.add(duration);
    setState(() {
      _selectedDate = dateTime;
      _selectedTime = TimeOfDay.fromDateTime(dateTime);
    });
  }

  void _save() {
    if (_selectedDate != null && _selectedTime != null) {
      final combined = DateTime(
        _selectedDate!.year,
        _selectedDate!.month,
        _selectedDate!.day,
        _selectedTime!.hour,
        _selectedTime!.minute,
      );
      widget.onSave(combined);
    } else {
      widget.onSave(null);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        ModalBarrier(
          color: Colors.black.withOpacity(0.5),
          dismissible: true,
          onDismiss: widget.onClose,
        ),
        Center(
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 200),
            margin: const EdgeInsets.all(16),
            constraints: const BoxConstraints(maxWidth: 400),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(20),
              child: Container(
                decoration: BoxDecoration(
                  color: const Color.fromRGBO(30, 30, 30, 0.95),
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(
                    color: Colors.white.withOpacity(0.2),
                    width: 1,
                  ),
                ),
                child: Padding(
                  padding: const EdgeInsets.all(20),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Заголовок
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          const Text(
                            'Напоминание',
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 20,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                          IconButton(
                            icon: const Icon(Icons.close, color: Colors.white60),
                            onPressed: widget.onClose,
                            padding: EdgeInsets.zero,
                            constraints: const BoxConstraints(),
                          ),
                        ],
                      ),
                      const SizedBox(height: 20),
                      // Быстрые варианты
                      Wrap(
                        spacing: 8,
                        runSpacing: 8,
                        children: [
                          _quickButton('Сегодня 20:00', () {
                            final now = DateTime.now();
                            _setQuickReminder(Duration(
                              hours: 20 - now.hour,
                              minutes: 0,
                            ));
                          }),
                          _quickButton('Завтра 08:00', () {
                            final now = DateTime.now();
                            _setQuickReminder(Duration(
                              days: 1,
                              hours: 8 - now.hour,
                              minutes: 0,
                            ));
                          }),
                          _quickButton('След. неделя пн', () {
                            final now = DateTime.now();
                            final daysUntilMonday = (8 - now.weekday) % 7;
                            _setQuickReminder(Duration(
                              days: daysUntilMonday == 0 ? 7 : daysUntilMonday,
                              hours: 8 - now.hour,
                              minutes: 0,
                            ));
                          }),
                        ],
                      ),
                      const SizedBox(height: 20),
                      // Выбор даты и времени
                      Row(
                        children: [
                          Expanded(
                            child: OutlinedButton.icon(
                              onPressed: _pickDate,
                              icon: const Icon(Icons.calendar_today, size: 18),
                              label: Text(
                                _selectedDate != null
                                    ? '${_selectedDate!.day}.${_selectedDate!.month}.${_selectedDate!.year}'
                                    : 'Дата',
                              ),
                              style: OutlinedButton.styleFrom(
                                foregroundColor: Colors.white,
                                side: BorderSide(color: Colors.white.withOpacity(0.3)),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(12),
                                ),
                              ),
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: OutlinedButton.icon(
                              onPressed: _pickTime,
                              icon: const Icon(Icons.access_time, size: 18),
                              label: Text(
                                _selectedTime != null
                                    ? '${_selectedTime!.hour.toString().padLeft(2, '0')}:${_selectedTime!.minute.toString().padLeft(2, '0')}'
                                    : 'Время',
                              ),
                              style: OutlinedButton.styleFrom(
                                foregroundColor: Colors.white,
                                side: BorderSide(color: Colors.white.withOpacity(0.3)),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(12),
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 24),
                      // Кнопки действий
                      Row(
                        mainAxisAlignment: MainAxisAlignment.end,
                        children: [
                          if (widget.currentReminder != null)
                            TextButton(
                              onPressed: () => widget.onSave(null),
                              child: const Text(
                                'Удалить',
                                style: TextStyle(color: Colors.redAccent),
                              ),
                            ),
                          const SizedBox(width: 12),
                          ElevatedButton(
                            onPressed: _save,
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.white.withOpacity(0.2),
                              foregroundColor: Colors.white,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(12),
                              ),
                            ),
                            child: const Text('Сохранить'),
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

  Widget _quickButton(String label, VoidCallback onTap) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        decoration: BoxDecoration(
          color: Colors.white.withOpacity(0.1),
          borderRadius: BorderRadius.circular(8),
        ),
        child: Text(
          label,
          style: const TextStyle(color: Colors.white70, fontSize: 13),
        ),
      ),
    );
  }
}
