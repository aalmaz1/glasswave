import 'package:intl/intl.dart';

abstract final class GlassDates {
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
    return DateFormat(pattern, intlLocale(langCode)).format(d);
  }

  static String short(DateTime d, String langCode) {
    final pattern = switch (langCode) {
      'ru' => 'd MMM, HH:mm',
      'ko' => 'M"월 "d"일 "a hh:mm',
      _ => 'MMM d, hh:mm a',
    };
    return DateFormat(pattern, intlLocale(langCode)).format(d);
  }

  static String reminder(DateTime d, String langCode) {
    final pattern = switch (langCode) {
      'ru' => 'd MMMM, HH:mm',
      'ko' => 'M"월 "d"일 "a hh:mm',
      _ => 'MMMM d, hh:mm a',
    };
    return DateFormat(pattern, intlLocale(langCode)).format(d);
  }

  static String monthDay(DateTime d, String langCode) {
    final pattern = switch (langCode) {
      'ru' => 'd MMMM',
      'ko' => 'M"월 "d"일"',
      _ => 'MMMM d',
    };
    return DateFormat(pattern, intlLocale(langCode)).format(d);
  }
}
