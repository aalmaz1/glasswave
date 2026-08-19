/**
 * Generates `assets/translations/{ru,en,ko}.json` for the Flutter app
 * (easy_localization) from the single source of truth in
 * `src/i18n/translations.ts`.
 *
 * Run with: `npm run i18n:export`
 *
 * The Flutter app keys its strings by snake_case ids (see `tr('...')` in
 * `lib/`), while the web app uses camelCase fields on the `Translation`
 * interface. The mapping below bridges the two. Every Flutter-consumed string
 * lives in `translations.ts`, so the JSON is fully generated — never edit it
 * by hand.
 */
import { mkdirSync, writeFileSync } from "node:fs";
import { fileURLToPath } from "node:url";
import { dirname, resolve } from "node:path";
import { TRANSLATIONS, type Translation, type Language } from "../src/i18n/translations";

const __dirname = dirname(fileURLToPath(import.meta.url));
const OUT_DIR = resolve(__dirname, "../assets/translations");

/** Flutter snake_case key → field on the `Translation` interface. */
const FLUTTER_KEY_MAP: Record<string, keyof Translation> = {
  notes: "allNotes",
  archive: "tabArchive",
  trash: "tabTrash",
  search_hint: "searchPlaceholder",
  no_notes: "noNotes",
  empty_archive: "noNotesArchive",
  empty_trash: "noNotesTrash",
  not_found: "noSearchResults",
  pinned: "pinnedSection",
  others: "othersSection",
  editor_new: "newNote",
  editor_save: "save",
  editor_close: "close",
  editor_title: "noteTitlePlaceholder",
  editor_body: "noteContentPlaceholder",
  editor_words: "words",
  editor_preview: "editorPreview",
  editor_edit_mode: "editorEditMode",
  editor_no_title: "untitled",
  settings_title: "settings",
  settings_account: "account",
  settings_sync: "settingsSync",
  settings_sync_desc: "settingsSyncDesc",
  settings_auth_btn: "settingsAuthBtn",
  settings_theme: "theme",
  settings_lang: "language",
  settings_font: "settingsFont",
  settings_font_sm: "settingsFontSm",
  settings_font_md: "settingsFontMd",
  settings_font_lg: "settingsFontLg",
  settings_synced: "synced",
  note_just_now: "timeJustNow",
  note_hours_ago: "timeHoursAgoSuffix",
  note_days_ago: "timeDaysAgoSuffix",
  sort_title: "sortBy",
  sort_default: "sortDefault",
  sort_default_sub: "sortDefaultSub",
  sort_created: "sortByCreated",
  sort_created_sub: "sortCreatedSub",
  sort_updated: "sortByUpdated",
  sort_updated_sub: "sortUpdatedSub",
  remind_title: "reminder",
  remind_today: "reminderToday",
  remind_tomorrow: "reminderTomorrow",
  remind_next_week: "reminderNextWeek",
  remind_custom: "reminderCustom",
  remind_pick: "remindPick",
  remind_delete: "reminderDelete",
  remind_save: "reminderSave",
  remind_monday_at: "remindMondayAt",
  auth_login: "login",
  auth_register: "register",
  auth_email: "email",
  auth_password: "password",
  auth_name: "name",
  auth_submit_login: "loginBtn",
  auth_submit_register: "registerBtn",
  auth_footer: "authFooter",
  auth_error_email: "authErrInvalidEmail",
  auth_error_pw: "authErrPwShort",
  auth_error_name: "authErrNameShort",
  auth_success_reg: "registerOk",
  auth_err_not_found: "authErrNotFound",
  auth_err_wrong_pw: "authErrWrongPw",
  auth_err_email_in_use: "authErrEmailInUse",
  auth_err_invalid_email: "authErrInvalidEmail",
  auth_err_weak_pw: "authErrWeakPw",
  auth_err_generic: "authErrGeneric",
  language_ru: "languageNameRu",
  language_en: "languageNameEn",
  language_ko: "languageNameKo",
  language: "language",
  delete_account: "deleteAccount",
  danger_zone: "danger",
  delete_account_desc: "deleteDescription",
  delete_account_title: "deleteConfirmTitle",
  delete_account_warning: "deleteWarning",
  password: "password",
  cancel: "cancel",
  delete_forever: "deleteForever",
  deleting: "deleting",
};

/**
 * Keys whose value is intentionally empty for every language. Keeping them in
 * the output preserves easy_localization key coverage for the Flutter app.
 */
const EMPTY_KEYS = new Set(["editor_edit"]);

function buildJson(lang: Language): Record<string, string> {
  const t = TRANSLATIONS[lang];
  const out: Record<string, string> = {};

  for (const [flutterKey, field] of Object.entries(FLUTTER_KEY_MAP)) {
    out[flutterKey] = String(t[field]);
  }
  for (const key of EMPTY_KEYS) {
    out[key] = "";
  }

  return out;
}

function main() {
  mkdirSync(OUT_DIR, { recursive: true });
  for (const lang of Object.keys(TRANSLATIONS) as Language[]) {
    const json = buildJson(lang);
    const path = resolve(OUT_DIR, `${lang}.json`);
    writeFileSync(path, `${JSON.stringify(json, null, 2)}\n`, "utf8");
    console.log(`Wrote ${path} (${Object.keys(json).length} keys)`);
  }
}

main();
