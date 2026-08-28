/**
 * Single source of truth for all GlassWave UI strings.
 *
 * Both the React web app (via `index.tsx`) and the Flutter app (via the
 * `npm run i18n:export` script, which generates `assets/translations/*.json`)
 * are derived from this file. Do NOT hand-edit the JSON files — run the export
 * script instead. Add new strings here, in all three languages.
 */

export type Language = "ru" | "en" | "ko";

export interface Translation {
  // Settings screen
  settings: string;
  account: string;
  theme: string;
  language: string;
  danger: string;
  deleteAccount: string;
  deleteDescription: string;
  deleteConfirmTitle: string;
  deleteWarning: string;
  deleteSuffix: string;
  confirmPassword: string;
  passwordPlaceholder: string;
  cancel: string;
  deleteForever: string;
  deleting: string;
  synced: string;
  logout: string;
  selectLanguage: string;

  // Dashboard & Navigation
  dashboard: string;
  allNotes: string;
  pinned: string;
  pinnedSection: string;
  othersSection: string;
  archived: string;
  trash: string;
  tabNotes: string;
  tabArchive: string;
  tabTrash: string;
  search: string;
  searchPlaceholder: string;
  createNote: string;
  createNewNote: string;
  noNotes: string;
  noNotesSubtitle: string;
  noNotesArchive: string;
  noNotesTrash: string;
  noSearchResults: string;
  emptyTrash: string;
  emptyTrashConfirmTitle: string;
  emptyTrashConfirmBody: string;
  confirmDeleteNoteTitle: string;
  confirmDeleteNoteBody: string;
  unsavedChangesTitle: string;
  unsavedChangesBody: string;
  unsavedSave: string;
  unsavedDiscard: string;
  fmtH1: string;
  fmtH2: string;
  fmtBold: string;
  fmtItalic: string;
  fmtStrike: string;
  fmtUnderline: string;
  fmtBullet: string;
  fmtOrdered: string;
  fmtQuote: string;
  fmtCode: string;
  fmtHr: string;
  fmtUndo: string;
  fmtRedo: string;
  loadingNotes: string;
  loadMore: string;
  notesLoadError: string;
  retry: string;

  // Note card
  untitled: string;
  pin: string;
  unpin: string;
  pinNote: string;
  unpinNote: string;
  edit: string;
  archive: string;
  unarchive: string;
  archiveNote: string;
  delete: string;
  deleteNote: string;
  restore: string;
  deleteForeverAction: string;
  reminderAction: string;
  reminderBadge: string;
  word: string;
  words: string;
  wordsCount: (n: number) => string;

  // Note editor
  noteTitlePlaceholder: string;
  noteContentPlaceholder: string;
  save: string;
  saving: string;
  saved: string;
  noteSyncError: string;
  close: string;
  closeEditor: string;
  newNote: string;
  editingNote: string;
  todayAt: string;

  // Error boundary
  errorTitle: string;
  errorMessage: string;
  errorReload: string;

  // Reminder modal
  reminder: string;
  setReminder: string;
  clearReminder: string;
  reminderScheduled: string;
  reminderCleared: string;
  reminderToday: string;
  reminderTomorrow: string;
  reminderNextWeek: string;
  reminderCustom: string;
  reminderDelete: string;
  reminderSave: string;

  // Sort sheet
  sort: string;
  sortBy: string;
  sortDefault: string;
  sortByCreated: string;
  sortByUpdated: string;
  sortDefaultSub: string;
  sortCreatedSub: string;
  sortUpdatedSub: string;

  // Auth
  welcomeBack: string;
  login: string;
  loginBtn: string;
  register: string;
  registerBtn: string;
  email: string;
  emailPlaceholder: string;
  password: string;
  passwordPlaceholderLogin: string;
  name: string;
  namePlaceholder: string;
  noAccount: string;
  haveAccount: string;
  guestMode: string;
  loading: string;
  authHint: string;
  showPassword: string;
  hidePassword: string;
  closeModal: string;
  authErrInvalidEmail: string;
  authErrNameShort: string;
  authErrPwShort: string;
  authErrEmailPassRequired: string;
  authErrBadCreds: string;
  authErrEmailUsed: string;
  authErrWeakPw: string;
  authErrNotAllowed: string;
  authErrNotConfigured: string;
  authErrUnauthorizedDomain: string;
  authErrNetwork: string;
  authErrInvalidApiKey: string;
  authErrTooMany: string;
  authErrGeneric: string;
  authErrLoggedOut: string;
  authErrPasswordRequired: string;
  authErrDeleteBadPw: string;
  authErrReauth: string;
  authErrDeletePerm: string;
  authErrDeleteGeneric: string;
  registerOk: string;
  // Password reset
  forgotPassword: string;
  resetSent: string;
  authErrResetGeneric: string;

  // Themes
  themeSunset: string;
  themeIce: string;
  themeMono: string;
  themeCyber: string;
  themeAurora: string;
  themeRose: string;
  themeCosmos: string;
  themeForest: string;
  themeObsidian: string;
  themeGraphite: string;
  themeMidnight: string;
  themeEspresso: string;

  // Time ago
  timeJustNow: string;
  timeMinAgo: (n: number) => string;
  timeHoursAgo: (n: number) => string;
  timeDaysAgo: (n: number) => string;
  timeYesterday: string;

  // Locale for dates
  localeTag: string;
  dateFormatLong: Intl.DateTimeFormatOptions;
  dateFormatShort: Intl.DateTimeFormatOptions;
  dateFormatReminder: Intl.DateTimeFormatOptions;

  // Welcome notes (facts about GlassWave, shown to brand-new guests)
  welcomeNote1Title: string;
  welcomeNote1Body: string;
  welcomeNote2Title: string;
  welcomeNote2Body: string;
  welcomeNote3Title: string;
  welcomeNote3Body: string;
  welcomeNote4Title: string;
  welcomeNote4Body: string;

  // ── Flutter-only strings (consumed by `npm run i18n:export`) ──────────
  // Kept in the same source of truth so the two apps never drift.
  settingsSync: string;
  settingsSyncDesc: string;
  settingsAuthBtn: string;
  settingsFont: string;
  settingsFontSm: string;
  settingsFontMd: string;
  settingsFontLg: string;
  editorPreview: string;
  editorEditMode: string;
  remindPick: string;
  remindMondayAt: string;
  authFooter: string;
  authErrNotFound: string;
  authErrWrongPw: string;
  authErrEmailInUse: string;
  timeHoursAgoSuffix: string;
  timeDaysAgoSuffix: string;
  languageNameRu: string;
  languageNameEn: string;
  languageNameKo: string;
}

export const LANGUAGES: Language[] = ["ru", "en", "ko"];

/** Language data is loaded on demand; see ./index.tsx for the cache + prefetch. */
export const LOADERS: Record<Language, () => Promise<{ default: Translation }>> = {
  ru: () => import("./lang/ru"),
  en: () => import("./lang/en"),
  ko: () => import("./lang/ko"),
};

export function themeNameByLang(themeId: string, t: Translation): string {
  const key = `theme${themeId.charAt(0).toUpperCase()}${themeId.slice(1)}` as keyof Translation;
  return (t[key] as string) || themeId;
}

export const LANGUAGE_OPTIONS = [
  { code: "ru" as Language, nativeName: "Русский" },
  { code: "en" as Language, nativeName: "English" },
  { code: "ko" as Language, nativeName: "한국어" },
] as const;
