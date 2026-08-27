/**
 * Generates `glasswave_flutter_ver/assets/translations/{ru,en,ko}.json` for the
 * Flutter app
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
const OUT_DIR = resolve(__dirname, "../glasswave_flutter_ver/assets/translations");

/** Placeholder easy_localization interpolates through `namedArgs: {"n": …}`. */
const N = "{n}";

/** Flutter snake_case key → field on the `Translation` interface. */
const FLUTTER_KEY_MAP: Record<string, keyof Translation> = {
  notes: "tabNotes",
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
  note_yesterday: "timeYesterday",
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
  create_note: "createNote",
  no_notes_subtitle: "noNotesSubtitle",
  empty_trash_btn: "emptyTrash",
  empty_trash_confirm_title: "emptyTrashConfirmTitle",
  empty_trash_confirm_body: "emptyTrashConfirmBody",
  confirm_delete_title: "confirmDeleteNoteTitle",
  confirm_delete_body: "confirmDeleteNoteBody",
  unsaved_changes_title: "unsavedChangesTitle",
  unsaved_changes_body: "unsavedChangesBody",
  unsaved_save: "unsavedSave",
  unsaved_discard: "unsavedDiscard",
  welcome_note1_title: "welcomeNote1Title",
  welcome_note1_body: "welcomeNote1Body",
  welcome_note2_title: "welcomeNote2Title",
  welcome_note2_body: "welcomeNote2Body",
  welcome_note3_title: "welcomeNote3Title",
  welcome_note3_body: "welcomeNote3Body",
  welcome_note4_title: "welcomeNote4Title",
  welcome_note4_body: "welcomeNote4Body",
};

/**
 * Keys built from a parameterized string. easy_localization interpolates
 * `{n}` through `tr(key, namedArgs: {"n": ...})`.
 */
const FLUTTER_COMPUTED: Record<string, (t: Translation) => string> = {
  note_min_ago: (t) => t.timeMinAgo(N as unknown as number),
  note_hours_ago: (t) => t.timeHoursAgo(N as unknown as number),
  note_days_ago: (t) => t.timeDaysAgo(N as unknown as number),
};

/**
 * Plural keys for easy_localization (`plural(key, n)`): it picks one/few/many
 * with the locale's CLDR rules, matching the hand-rolled plural logic the web
 * app uses for the same strings.
 */
const FLUTTER_PLURALS: Record<string, (t: Translation) => Record<string, string>> = {
  editor_words_count: (t) => ({
    one: t.wordsCount(1).replace("1", "{}"),
    few: t.wordsCount(2).replace("2", "{}"),
    many: t.wordsCount(5).replace("5", "{}"),
    other: t.wordsCount(5).replace("5", "{}"),
  }),
};

/**
 * Keys whose value is intentionally empty for every language. Keeping them in
 * the output preserves easy_localization key coverage for the Flutter app.
 */
const EMPTY_KEYS = new Set(["editor_edit"]);

type FlutterValue = string | Record<string, string>;

function buildJson(lang: Language): Record<string, FlutterValue> {
  const t = TRANSLATIONS[lang];
  const out: Record<string, FlutterValue> = {};

  for (const [flutterKey, field] of Object.entries(FLUTTER_KEY_MAP)) {
    out[flutterKey] = String(t[field]);
  }
  for (const [flutterKey, build] of Object.entries(FLUTTER_COMPUTED)) {
    out[flutterKey] = build(t);
  }
  for (const [flutterKey, build] of Object.entries(FLUTTER_PLURALS)) {
    out[flutterKey] = build(t);
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
