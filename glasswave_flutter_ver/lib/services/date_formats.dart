import 'package:intl/intl.dart';

/// Locale-aware date patterns that reproduce the exact strings the React
/// reference renders.
///
/// The web app formats every date through `Intl.DateTimeFormat(language, …)`
/// with per-language option objects (`dateFormatLong`, `dateFormatShort`,
/// `dateFormatReminder` in `src/i18n/lang/*.ts`). `DateFormat` cannot take
/// those option objects, so each of them is spelled out here as the equivalent
/// ICU pattern for the three supported languages.
abstract final class GlassDates {
  /// `localeTag` from the React translations ("ru-RU" / "en-US" / "ko-KR").
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

  /// `dateFormatLong` — the editor meta row.
  /// ru: "29 августа 2026 г." · en: "August 29, 2026" · ko: "2026년 8월 29일"
  static String long(DateTime d, String langCode) {
    final pattern = switch (langCode) {
      'ru' => 'd MMMM y "г."',
      'ko' => 'y"년 "M"월 "d"일"',
      _ => 'MMMM d, y',
    };
    return DateFormat(pattern, intlLocale(langCode)).format(d);
  }

  /// `dateFormatShort` — the amber reminder badge on a note card.
  /// ru: "29 авг., 14:30" · en: "Aug 29, 02:30 PM" · ko: "8월 29일 오후 02:30"
  static String short(DateTime d, String langCode) {
    final pattern = switch (langCode) {
      'ru' => 'd MMM, HH:mm',
      'ko' => 'M"월 "d"일 "a hh:mm',
      _ => 'MMM d, hh:mm a',
    };
    return DateFormat(pattern, intlLocale(langCode)).format(d);
  }

  /// `dateFormatReminder` — the quick-pick rows in the reminder modal.
  /// ru: "29 августа, 14:30" · en: "August 29, 02:30 PM" · ko: "8월 29일 오후 02:30"
  static String reminder(DateTime d, String langCode) {
    final pattern = switch (langCode) {
      'ru' => 'd MMMM, HH:mm',
      'ko' => 'M"월 "d"일 "a hh:mm',
      _ => 'MMMM d, hh:mm a',
    };
    return DateFormat(pattern, intlLocale(langCode)).format(d);
  }

  /// `fmtDate()` in `src/app/utils.ts` falls back to day + long month once a
  /// note is older than a week.
  /// ru: "29 августа" · en: "August 29" · ko: "8월 29일"
  static String monthDay(DateTime d, String langCode) {
    final pattern = switch (langCode) {
      'ru' => 'd MMMM',
      'ko' => 'M"월 "d"일"',
      _ => 'MMMM d',
    };
    return DateFormat(pattern, intlLocale(langCode)).format(d);
  }
}
