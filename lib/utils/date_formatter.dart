import 'package:intl/intl.dart';

/// Форматирование дат для отображения
class DateFormatter {
  /// Форматирует дату в формате "Сегодня, 14:30" или "Вчера, 10:00" или "15 янв, 09:00"
  static String formatRelative(DateTime date) {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final yesterday = today.subtract(const Duration(days: 1));
    final dateOnly = DateTime(date.year, date.month, date.day);

    final timeFormat = DateFormat('HH:mm');
    final dateFormat = DateFormat('dd MMM');

    if (dateOnly == today) {
      return 'Сегодня, ${timeFormat.format(date)}';
    } else if (dateOnly == yesterday) {
      return 'Вчера, ${timeFormat.format(date)}';
    } else {
      return '${dateFormat.format(date)}, ${timeFormat.format(date)}';
    }
  }

  /// Форматирует дату напоминания
  static String formatReminder(DateTime date) {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final tomorrow = today.add(const Duration(days: 1));
    final dateOnly = DateTime(date.year, date.month, date.day);

    final timeFormat = DateFormat('HH:mm');
    final dateFormat = DateFormat('dd MMM HH:mm');

    if (dateOnly == today) {
      return 'Сегодня в ${timeFormat.format(date)}';
    } else if (dateOnly == tomorrow) {
      return 'Завтра в ${timeFormat.format(date)}';
    } else {
      return dateFormat.format(date);
    }
  }

  /// Форматирует полную дату
  static String formatFull(DateTime date) {
    return DateFormat('dd MMMM yyyy, HH:mm', 'ru_RU').format(date);
  }
}
