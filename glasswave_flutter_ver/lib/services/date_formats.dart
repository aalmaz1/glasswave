import 'package:intl/intl.dart';

abstract final class GlassDates {
  static final Map<String, DateFormat> _formatters = {};

  static DateFormat _getFormatter(String pattern, String locale) {
    final key = '$pattern|$locale';
    return _formatters.putIfAbsent(key, () => DateFormat(pattern, locale));
  }

  static String intlLocale(String langCode) {
    switch (langCode) {
      case 'ru':
        return 'ru_RU';
      case 'ko':
        return 'ko_KR';
      default:
        return 'en_US';
    }
  }

  static String long(DateTime d, String langCode) {
    final pattern = switch (langCode) {
      'ru' => 'd MMMM y "г."',
      'ko' => 'y"년 "M"월 "d"일"',
      _ => 'MMMM d, y',
    };
    return _getFormatter(pattern, intlLocale(langCode)).format(d);
  }

  static String short(DateTime d, String langCode) {
    final pattern = switch (langCode) {
      'ru' => 'd MMM, HH:mm',
      'ko' => 'M"월 "d"일 "a hh:mm',
      _ => 'MMM d, hh:mm a',
    };
    return _getFormatter(pattern, intlLocale(langCode)).format(d);
  }

  static String reminder(DateTime d, String langCode) {
    final pattern = switch (langCode) {
      'ru' => 'd MMMM, HH:mm',
      'ko' => 'M"월 "d"일 "a hh:mm',
      _ => 'MMMM d, hh:mm a',
    };
    return _getFormatter(pattern, intlLocale(langCode)).format(d);
  }

  static String monthDay(DateTime d, String langCode) {
    final pattern = switch (langCode) {
      'ru' => 'd MMMM',
      'ko' => 'M"월 "d"일"',
      _ => 'MMMM d',
    };
    return _getFormatter(pattern, intlLocale(langCode)).format(d);
  }
}

