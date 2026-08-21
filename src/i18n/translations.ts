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

const ru: Translation = {
  settings: "Настройки",
  account: "Аккаунт",
  theme: "Цветовая тема",
  language: "Язык интерфейса",
  danger: "Опасная зона",
  deleteAccount: "Удалить аккаунт",
  deleteDescription: "Будут безвозвратно удалены профиль, настройки и все заметки.",
  deleteConfirmTitle: "Удалить аккаунт?",
  deleteWarning: "Это действие необратимо: профиль, настройки и все заметки для",
  deleteSuffix: " будут удалены.",
  confirmPassword: "Подтвердите пароль",
  passwordPlaceholder: "Ваш пароль",
  cancel: "Отмена",
  deleteForever: "Удалить навсегда",
  deleting: "Удаляем…",
  synced: "Синхронизировано",
  logout: "Выйти",
  selectLanguage: "Выберите язык интерфейса",

  dashboard: "Заметки",
  allNotes: "Все",
  pinned: "Закреплённые",
  pinnedSection: "Закреплённые",
  othersSection: "Остальные",
  archived: "Архив",
  trash: "Корзина",
  tabNotes: "Заметки",
  tabArchive: "Архив",
  tabTrash: "Корзина",
  search: "Поиск",
  searchPlaceholder: "Поиск заметок...",
  createNote: "Создать заметку",
  createNewNote: "Создать новую заметку",
  noNotes: "Заметок пока нет",
  noNotesSubtitle: "Создайте первую заметку — она сохранится на этом устройстве.",
  noNotesArchive: "Архив пуст",
  noNotesTrash: "Корзина пуста",
  noSearchResults: "Ничего не найдено",
  emptyTrash: "Очистить корзину",
  emptyTrashConfirmTitle: "Очистить корзину?",
  emptyTrashConfirmBody: "Все заметки в корзине будут удалены навсегда. Это нельзя отменить.",
  confirmDeleteNoteTitle: "Удалить заметку навсегда?",
  confirmDeleteNoteBody: "Заметка будет удалена без возможности восстановления.",
  unsavedChangesTitle: "Сохранить изменения?",
  unsavedChangesBody: "У этой заметки есть несохранённый текст.",
  unsavedSave: "Сохранить",
  unsavedDiscard: "Не сохранять",
  fmtH1: "Заголовок 1",
  fmtH2: "Заголовок 2",
  fmtBold: "Жирный",
  fmtItalic: "Курсив",
  fmtStrike: "Зачёркнутый",
  fmtUnderline: "Подчёркнутый",
  fmtBullet: "Маркированный список",
  fmtOrdered: "Нумерованный список",
  fmtQuote: "Цитата",
  fmtCode: "Блок кода",
  fmtHr: "Разделитель",
  fmtUndo: "Отменить",
  fmtRedo: "Повторить",
  loadingNotes: "Загрузка заметок...",
  loadMore: "Показать ещё",
  notesLoadError: "Не удалось загрузить заметки. Проверьте подключение и повторите попытку.",
  retry: "Повторить",

  untitled: "Без названия",
  pin: "Закрепить",
  unpin: "Открепить",
  pinNote: "Закрепить заметку",
  unpinNote: "Открепить заметку",
  edit: "Редактировать",
  archive: "В архив",
  unarchive: "Из архива",
  archiveNote: "Архивировать заметку",
  delete: "В корзину",
  deleteNote: "Удалить заметку",
  restore: "Восстановить",
  deleteForeverAction: "Удалить навсегда",
  reminderAction: "Напоминание",
  reminderBadge: "Напоминание",
  word: "слово",
  words: "слов",
  wordsCount: (n) => {
    const mod10 = n % 10, mod100 = n % 100;
    if (mod10 === 1 && mod100 !== 11) return `${n} слово`;
    if (mod10 >= 2 && mod10 <= 4 && (mod100 < 10 || mod100 >= 20)) return `${n} слова`;
    return `${n} слов`;
  },

  noteTitlePlaceholder: "Заголовок...",
  noteContentPlaceholder: "Начните писать...",
  save: "Сохранить",
  saving: "Сохранение...",
  saved: "Сохранено",
  noteSyncError: "Не удалось синхронизировать изменения заметки. Проверьте подключение и повторите попытку.",
  errorTitle: "Что-то пошло не так",
  errorMessage: "Произошла непредвиденная ошибка. Перезагрузите страницу — ваши заметки в безопасности.",
  errorReload: "Перезагрузить",
  close: "Закрыть",
  closeEditor: "Закрыть редактор",
  newNote: "Новая заметка",
  editingNote: "",
  todayAt: "Сегодня",

  reminder: "Напоминание",
  setReminder: "Установить напоминание",
  clearReminder: "Отменить напоминание",
  reminderScheduled: "Напоминание установлено",
  reminderCleared: "Напоминание отменено",
  reminderToday: "Сегодня",
  reminderTomorrow: "Завтра утром",
  reminderNextWeek: "Следующая неделя",
  reminderCustom: "Своя дата и время",
  reminderDelete: "Удалить",
  reminderSave: "Сохранить",

  sort: "Сортировка",
  sortBy: "Сортировка",
  sortDefault: "По умолчанию",
  sortByCreated: "Дата создания",
  sortByUpdated: "Дата изменения",
  sortDefaultSub: "Порядок добавления",
  sortCreatedSub: "Сначала новые",
  sortUpdatedSub: "Недавно отредактированные",

  welcomeBack: "С возвращением!",
  login: "Войти",
  loginBtn: "Войти",
  register: "Регистрация",
  registerBtn: "Зарегистрироваться",
  email: "Email",
  emailPlaceholder: "you@example.com",
  password: "Пароль",
  passwordPlaceholderLogin: "Введите пароль",
  name: "Имя",
  namePlaceholder: "Ваше имя",
  noAccount: "Нет аккаунта?",
  haveAccount: "Уже есть аккаунт?",
  guestMode: "Гостевой режим",
  loading: "Загрузка...",
  authHint: "Без аккаунта заметки хранятся только в этом браузере. После входа они синхронизируются между устройствами.",
  showPassword: "Показать пароль",
  hidePassword: "Скрыть пароль",
  closeModal: "Закрыть",
  authErrInvalidEmail: "Введите корректный email",
  authErrNameShort: "Имя должно быть не короче 2 символов",
  authErrPwShort: "Пароль должен быть не менее 6 символов",
  authErrEmailPassRequired: "Введите email и пароль",
  authErrBadCreds: "Неверный email или пароль",
  authErrEmailUsed: "Этот email уже зарегистрирован",
  authErrWeakPw: "Пароль должен быть не менее 6 символов",
  authErrNotAllowed: "В Firebase не включён вход по email и паролю. В консоли проекта glasswave-4f5da откройте Authentication → Sign-in method и включите Email/Password (не Email link).",
  authErrNotConfigured: "Приложение не подключено к Firebase. Проверьте конфигурацию проекта glasswave-4f5da.",
  authErrUnauthorizedDomain: "Этот домен не добавлен в Authorized domains в Firebase Authentication.",
  authErrNetwork: "Нет соединения с Firebase. Проверьте интернет и повторите попытку.",
  authErrInvalidApiKey: "Неверный Firebase API-ключ. Убедитесь, что приложение подключено к проекту glasswave-4f5da.",
  authErrTooMany: "Слишком много попыток. Повторите позже",
  authErrGeneric: "Не удалось выполнить вход. Повторите попытку",
  authErrLoggedOut: "Сессия уже завершена. Войдите снова и повторите попытку.",
  authErrPasswordRequired: "Введите пароль для подтверждения.",
  authErrDeleteBadPw: "Неверный пароль. Аккаунт не был удалён.",
  authErrReauth: "Войдите в аккаунт заново и повторите попытку.",
  authErrDeletePerm: "Не удалось удалить данные аккаунта. Проверьте права Firebase и повторите попытку.",
  authErrDeleteGeneric: "Не удалось удалить аккаунт. Повторите попытку позже.",
  registerOk: "Аккаунт создан! Входим…",
  forgotPassword: "Забыли пароль?",
  resetSent: "Ссылка для сброса пароля отправлена на ваш email.",
  authErrResetGeneric: "Не удалось отправить письмо для сброса пароля. Повторите попытку.",

  themeSunset: "Тёплый закат",
  themeIce: "Ледяная свежесть",
  themeMono: "Монохром",
  themeCyber: "Кибер-закат",
  themeAurora: "Северное сияние",
  themeRose: "Полночная роза",
  themeCosmos: "Глубокий космос",
  themeForest: "Тёмный лес",
  themeObsidian: "Обсидиан",
  themeGraphite: "Графит",
  themeMidnight: "Полночь",
  themeEspresso: "Эспрессо",

  timeJustNow: "Только что",
  timeMinAgo: (n) => `${n} мин. назад`,
  timeHoursAgo: (n) => `${n} ч. назад`,
  timeDaysAgo: (n) => `${n} д. назад`,
  timeYesterday: "Вчера",

  localeTag: "ru-RU",
  dateFormatLong: { day: "numeric", month: "long", year: "numeric" },
  dateFormatShort: { day: "numeric", month: "short", hour: "2-digit", minute: "2-digit" },
  dateFormatReminder: { day: "numeric", month: "long", hour: "2-digit", minute: "2-digit" },

  welcomeNote1Title: "GlassWave 🌊",
  welcomeNote1Body:
    "Современное приложение для заметок в стиле glassmorphism: полупрозрачные карточки, размытие фона и плавные анимации.",
  welcomeNote2Title: "Что умеет GlassWave",
  welcomeNote2Body:
    "Создание и редактирование заметок с форматированием, закрепление, архив и корзина, поиск, сортировка и напоминания.",
  welcomeNote3Title: "Синхронизация и офлайн",
  welcomeNote3Body:
    "Синхронизация между устройствами через Firebase, работа без интернета благодаря локальному кэшу и гостевой режим без регистрации.",
  welcomeNote4Title: "Языки и темы",
  welcomeNote4Body:
    "Три языка интерфейса (русский, английский, корейский) и 12 цветовых тем на любой вкус.",

  settingsSync: "Синхронизируйте заметки",
  settingsSyncDesc: "Войдите, чтобы сохранять заметки в облаке и использовать их на других устройствах.",
  settingsAuthBtn: "Войти или Регистрация",
  settingsFont: "Размер шрифта",
  settingsFontSm: "Маленький",
  settingsFontMd: "Средний",
  settingsFontLg: "Большой",
  editorPreview: "Превью",
  editorEditMode: "Правка",
  remindPick: "Выбрать дату...",
  remindMondayAt: "Пн 08:00",
  authFooter: "Ваши данные надежно защищены в облаке.\nЗаметки синхронизируются между всеми устройствами.",
  authErrNotFound: "Пользователь не найден",
  authErrWrongPw: "Неверный пароль",
  authErrEmailInUse: "Этот email уже используется",
  timeHoursAgoSuffix: "ч назад",
  timeDaysAgoSuffix: "д назад",
  languageNameRu: "Русский",
  languageNameEn: "English",
  languageNameKo: "한국어",
};

const en: Translation = {
  settings: "Settings",
  account: "Account",
  theme: "Color theme",
  language: "Interface language",
  danger: "Danger zone",
  deleteAccount: "Delete account",
  deleteDescription: "Your profile, preferences, and all notes will be permanently deleted.",
  deleteConfirmTitle: "Delete account?",
  deleteWarning: "This action is irreversible: the profile, preferences, and all notes for",
  deleteSuffix: " will be deleted.",
  confirmPassword: "Confirm your password",
  passwordPlaceholder: "Your password",
  cancel: "Cancel",
  deleteForever: "Delete permanently",
  deleting: "Deleting…",
  synced: "Synced",
  logout: "Log out",
  selectLanguage: "Choose interface language",

  dashboard: "Notes",
  allNotes: "All",
  pinned: "Pinned",
  pinnedSection: "Pinned",
  othersSection: "Others",
  archived: "Archived",
  trash: "Trash",
  tabNotes: "Notes",
  tabArchive: "Archive",
  tabTrash: "Trash",
  search: "Search",
  searchPlaceholder: "Search notes...",
  createNote: "Create note",
  createNewNote: "Create new note",
  noNotes: "No notes yet",
  noNotesSubtitle: "Create your first note to get started.",
  noNotesArchive: "Archive is empty",
  noNotesTrash: "Trash is empty",
  noSearchResults: "Nothing found",
  emptyTrash: "Empty trash",
  emptyTrashConfirmTitle: "Empty trash?",
  emptyTrashConfirmBody: "Every note in the trash will be permanently deleted. This cannot be undone.",
  confirmDeleteNoteTitle: "Delete this note forever?",
  confirmDeleteNoteBody: "The note will be permanently deleted and cannot be restored.",
  unsavedChangesTitle: "Save changes?",
  unsavedChangesBody: "This note has unsaved text.",
  unsavedSave: "Save",
  unsavedDiscard: "Don't save",
  fmtH1: "Heading 1",
  fmtH2: "Heading 2",
  fmtBold: "Bold",
  fmtItalic: "Italic",
  fmtStrike: "Strikethrough",
  fmtUnderline: "Underline",
  fmtBullet: "Bullet list",
  fmtOrdered: "Numbered list",
  fmtQuote: "Quote",
  fmtCode: "Code block",
  fmtHr: "Horizontal rule",
  fmtUndo: "Undo",
  fmtRedo: "Redo",
  loadingNotes: "Loading notes...",
  loadMore: "Load more",
  notesLoadError: "Could not load notes. Check your connection and try again.",
  retry: "Retry",

  untitled: "Untitled",
  pin: "Pin",
  unpin: "Unpin",
  pinNote: "Pin note",
  unpinNote: "Unpin note",
  edit: "Edit",
  archive: "Archive",
  unarchive: "Unarchive",
  archiveNote: "Archive note",
  delete: "Move to trash",
  deleteNote: "Delete note",
  restore: "Restore",
  deleteForeverAction: "Delete forever",
  reminderAction: "Reminder",
  reminderBadge: "Reminder",
  word: "word",
  words: "words",
  wordsCount: (n) => `${n} ${n === 1 ? "word" : "words"}`,

  noteTitlePlaceholder: "Title...",
  noteContentPlaceholder: "Start writing...",
  save: "Save",
  saving: "Saving...",
  saved: "Saved",
  noteSyncError: "Could not sync your note changes. Check your connection and try again.",
  errorTitle: "Something went wrong",
  errorMessage: "An unexpected error occurred. Reload the page — your notes are safe.",
  errorReload: "Reload",
  close: "Close",
  closeEditor: "Close editor",
  newNote: "New note",
  editingNote: "",
  todayAt: "Today",

  reminder: "Reminder",
  setReminder: "Set reminder",
  clearReminder: "Clear reminder",
  reminderScheduled: "Reminder scheduled",
  reminderCleared: "Reminder cleared",
  reminderToday: "Today",
  reminderTomorrow: "Tomorrow morning",
  reminderNextWeek: "Next week",
  reminderCustom: "Custom date and time",
  reminderDelete: "Delete",
  reminderSave: "Save",

  sort: "Sort",
  sortBy: "Sort by",
  sortDefault: "Default",
  sortByCreated: "Date created",
  sortByUpdated: "Date updated",
  sortDefaultSub: "Insertion order",
  sortCreatedSub: "Newest first",
  sortUpdatedSub: "Recently edited",

  welcomeBack: "Welcome back!",
  login: "Log in",
  loginBtn: "Log in",
  register: "Sign up",
  registerBtn: "Sign up",
  email: "Email",
  emailPlaceholder: "you@example.com",
  password: "Password",
  passwordPlaceholderLogin: "Enter password",
  name: "Name",
  namePlaceholder: "Your name",
  noAccount: "No account?",
  haveAccount: "Already have an account?",
  guestMode: "Guest mode",
  loading: "Loading...",
  authHint: "Without an account, notes stay in this browser. After you sign in, they sync across devices.",
  showPassword: "Show password",
  hidePassword: "Hide password",
  closeModal: "Close",
  authErrInvalidEmail: "Please enter a valid email",
  authErrNameShort: "Name must be at least 2 characters",
  authErrPwShort: "Password must be at least 6 characters",
  authErrEmailPassRequired: "Please enter your email and password",
  authErrBadCreds: "Invalid email or password",
  authErrEmailUsed: "This email is already registered",
  authErrWeakPw: "Password must be at least 6 characters",
  authErrNotAllowed: "Email/password sign-in is not enabled in Firebase. In the glasswave-4f5da console open Authentication → Sign-in method and enable Email/Password (not Email link).",
  authErrNotConfigured: "The app is not connected to Firebase. Check the glasswave-4f5da project configuration.",
  authErrUnauthorizedDomain: "This domain is not listed in Firebase Authentication authorized domains.",
  authErrNetwork: "Could not reach Firebase. Check your connection and try again.",
  authErrInvalidApiKey: "Invalid Firebase API key. Make sure the app is connected to the glasswave-4f5da project.",
  authErrTooMany: "Too many attempts. Please try again later",
  authErrGeneric: "Sign-in failed. Please try again",
  authErrLoggedOut: "Session already ended. Sign in again and retry.",
  authErrPasswordRequired: "Enter your password to confirm.",
  authErrDeleteBadPw: "Wrong password. Account was not deleted.",
  authErrReauth: "Sign in again and retry.",
  authErrDeletePerm: "Could not delete account data. Check Firebase permissions and retry.",
  authErrDeleteGeneric: "Could not delete account. Please try again later.",
  registerOk: "Account created! Signing in…",
  forgotPassword: "Forgot password?",
  resetSent: "A password reset link has been sent to your email.",
  authErrResetGeneric: "Could not send the password reset email. Please try again.",

  themeSunset: "Warm Sunset",
  themeIce: "Icy Fresh",
  themeMono: "Monochrome",
  themeCyber: "Cyber Sunset",
  themeAurora: "Northern Lights",
  themeRose: "Midnight Rose",
  themeCosmos: "Deep Space",
  themeForest: "Dark Forest",
  themeObsidian: "Obsidian",
  themeGraphite: "Graphite",
  themeMidnight: "Midnight",
  themeEspresso: "Espresso",

  timeJustNow: "Just now",
  timeMinAgo: (n) => `${n} min ago`,
  timeHoursAgo: (n) => `${n} h ago`,
  timeDaysAgo: (n) => `${n} d ago`,
  timeYesterday: "Yesterday",

  localeTag: "en-US",
  dateFormatLong: { day: "numeric", month: "long", year: "numeric" },
  dateFormatShort: { day: "numeric", month: "short", hour: "2-digit", minute: "2-digit" },
  dateFormatReminder: { day: "numeric", month: "long", hour: "2-digit", minute: "2-digit" },

  welcomeNote1Title: "GlassWave 🌊",
  welcomeNote1Body:
    "A modern note-taking app with a glassmorphism design: translucent cards, background blur and smooth animations.",
  welcomeNote2Title: "What GlassWave can do",
  welcomeNote2Body:
    "Create and edit notes with formatting, pin, archive and trash, search, sort and reminders.",
  welcomeNote3Title: "Sync & offline",
  welcomeNote3Body:
    "Firebase sync across devices, offline work with a local cache, and a guest mode that needs no registration.",
  welcomeNote4Title: "Languages & themes",
  welcomeNote4Body:
    "Three interface languages (Russian, English, Korean) and 12 color themes to suit your mood.",

  settingsSync: "Sync your notes",
  settingsSyncDesc: "Sign in to save notes in the cloud and use them on other devices.",
  settingsAuthBtn: "Log in or sign up",
  settingsFont: "Font size",
  settingsFontSm: "Small",
  settingsFontMd: "Medium",
  settingsFontLg: "Large",
  editorPreview: "Preview",
  editorEditMode: "Edit",
  remindPick: "Choose date...",
  remindMondayAt: "Mon 08:00",
  authFooter: "Your data is securely stored in the cloud.\nNotes sync across devices.",
  authErrNotFound: "User not found",
  authErrWrongPw: "Wrong password",
  authErrEmailInUse: "This email is already in use",
  timeHoursAgoSuffix: "h ago",
  timeDaysAgoSuffix: "d ago",
  languageNameRu: "Русский",
  languageNameEn: "English",
  languageNameKo: "한국어",
};

const ko: Translation = {
  settings: "설정",
  account: "계정",
  theme: "색상 테마",
  language: "인터페이스 언어",
  danger: "위험 영역",
  deleteAccount: "계정 삭제",
  deleteDescription: "프로필, 환경설정 및 모든 노트가 영구적으로 삭제됩니다.",
  deleteConfirmTitle: "계정을 삭제하시겠습니까?",
  deleteWarning: "이 작업은 되돌릴 수 없습니다. 다음 계정의 프로필, 환경설정 및 모든 노트가 삭제됩니다:",
  deleteSuffix: " 계정이 삭제됩니다.",
  confirmPassword: "비밀번호 확인",
  passwordPlaceholder: "비밀번호",
  cancel: "취소",
  deleteForever: "영구 삭제",
  deleting: "삭제 중…",
  synced: "동기화됨",
  logout: "로그아웃",
  selectLanguage: "인터페이스 언어 선택",

  dashboard: "노트",
  allNotes: "전체",
  pinned: "고정됨",
  pinnedSection: "고정됨",
  othersSection: "기타",
  archived: "보관됨",
  trash: "휴지통",
  tabNotes: "노트",
  tabArchive: "보관",
  tabTrash: "휴지통",
  search: "검색",
  searchPlaceholder: "노트 검색...",
  createNote: "노트 만들기",
  createNewNote: "새 노트 만들기",
  noNotes: "노트 없음",
  noNotesSubtitle: "첫 노트를 만들어 시작하세요.",
  noNotesArchive: "보관함이 비어 있습니다",
  noNotesTrash: "휴지통이 비어 있습니다",
  noSearchResults: "검색 결과 없음",
  emptyTrash: "휴지통 비우기",
  emptyTrashConfirmTitle: "휴지통을 비울까요?",
  emptyTrashConfirmBody: "휴지통의 모든 노트가 영구적으로 삭제됩니다. 이 작업은 되돌릴 수 없습니다.",
  confirmDeleteNoteTitle: "이 노트를 영구 삭제할까요?",
  confirmDeleteNoteBody: "노트는 영구적으로 삭제되며 복원할 수 없습니다.",
  unsavedChangesTitle: "변경 사항을 저장할까요?",
  unsavedChangesBody: "이 노트에 저장되지 않은 내용이 있습니다.",
  unsavedSave: "저장",
  unsavedDiscard: "저장 안 함",
  fmtH1: "제목 1",
  fmtH2: "제목 2",
  fmtBold: "굵게",
  fmtItalic: "기울임",
  fmtStrike: "취소선",
  fmtUnderline: "밑줄",
  fmtBullet: "글머리 기호 목록",
  fmtOrdered: "번호 매기기 목록",
  fmtQuote: "인용",
  fmtCode: "코드 블록",
  fmtHr: "구분선",
  fmtUndo: "실행 취소",
  fmtRedo: "다시 실행",
  loadingNotes: "노트 로딩 중...",
  loadMore: "더 보기",
  notesLoadError: "노트를 불러올 수 없습니다. 연결을 확인한 후 다시 시도하세요.",
  retry: "다시 시도",

  untitled: "제목 없음",
  pin: "고정",
  unpin: "고정 해제",
  pinNote: "노트 고정",
  unpinNote: "노트 고정 해제",
  edit: "편집",
  archive: "보관",
  unarchive: "보관 해제",
  archiveNote: "노트 보관",
  delete: "휴지통으로 이동",
  deleteNote: "노트 삭제",
  restore: "복원",
  deleteForeverAction: "영구 삭제",
  reminderAction: "알림",
  reminderBadge: "알림",
  word: "단어",
  words: "단어",
  wordsCount: (n) => `${n}단어`,

  noteTitlePlaceholder: "제목...",
  noteContentPlaceholder: "무언가 작성하세요...",
  save: "저장",
  saving: "저장 중...",
  saved: "저장됨",
  noteSyncError: "노트 변경 사항을 동기화할 수 없습니다. 연결을 확인한 후 다시 시도하세요.",
  errorTitle: "문제가 발생했습니다",
  errorMessage: "예기치 않은 오류가 발생했습니다. 페이지를 새로고침하세요. 노트는 안전하게 저장되어 있습니다.",
  errorReload: "새로고침",
  close: "닫기",
  closeEditor: "편집기 닫기",
  newNote: "새 노트",
  editingNote: "",
  todayAt: "오늘",

  reminder: "알림",
  setReminder: "알림 설정",
  clearReminder: "알림 해제",
  reminderScheduled: "알림이 설정되었습니다",
  reminderCleared: "알림이 해제되었습니다",
  reminderToday: "오늘",
  reminderTomorrow: "내일 아침",
  reminderNextWeek: "다음 주",
  reminderCustom: "직접 설정",
  reminderDelete: "삭제",
  reminderSave: "저장",

  sort: "정렬",
  sortBy: "정렬 기준",
  sortDefault: "기본 순서",
  sortByCreated: "생성일",
  sortByUpdated: "수정일",
  sortDefaultSub: "추가된 순서",
  sortCreatedSub: "최신순",
  sortUpdatedSub: "최근 수정순",

  welcomeBack: "다시 오신 것을 환영합니다!",
  login: "로그인",
  loginBtn: "로그인",
  register: "회원가입",
  registerBtn: "회원가입",
  email: "이메일",
  emailPlaceholder: "you@example.com",
  password: "비밀번호",
  passwordPlaceholderLogin: "비밀번호 입력",
  name: "이름",
  namePlaceholder: "이름",
  noAccount: "계정이 없으신가요?",
  haveAccount: "이미 계정이 있으신가요?",
  guestMode: "게스트 모드",
  loading: "로딩 중...",
  authHint: "계정 없이 사용하면 노트는 이 브라우저에만 저장됩니다. 로그인하면 기기 간에 동기화됩니다.",
  showPassword: "비밀번호 표시",
  hidePassword: "비밀번호 숨기기",
  closeModal: "닫기",
  authErrInvalidEmail: "올바른 이메일을 입력하세요",
  authErrNameShort: "이름은 2자 이상이어야 합니다",
  authErrPwShort: "비밀번호는 6자 이상이어야 합니다",
  authErrEmailPassRequired: "이메일과 비밀번호를 입력하세요",
  authErrBadCreds: "이메일 또는 비밀번호가 잘못되었습니다",
  authErrEmailUsed: "이미 가입된 이메일입니다",
  authErrWeakPw: "비밀번호는 6자 이상이어야 합니다",
  authErrNotAllowed: "Firebase에서 이메일/비밀번호 로그인이 활성화되지 않았습니다. glasswave-4f5da 콘솔의 Authentication → Sign-in method에서 Email/Password를 켜세요(Email link가 아님).",
  authErrNotConfigured: "앱이 Firebase에 연결되어 있지 않습니다. glasswave-4f5da 프로젝트 구성을 확인하세요.",
  authErrUnauthorizedDomain: "이 도메인이 Firebase Authentication의 승인된 도메인에 없습니다.",
  authErrNetwork: "Firebase에 연결할 수 없습니다. 네트워크를 확인한 후 다시 시도하세요.",
  authErrInvalidApiKey: "Firebase API 키가 올바르지 않습니다. 앱이 glasswave-4f5da 프로젝트에 연결되어 있는지 확인하세요.",
  authErrTooMany: "시도 횟수가 너무 많습니다. 나중에 다시 시도하세요",
  authErrGeneric: "로그인에 실패했습니다. 다시 시도하세요",
  authErrLoggedOut: "세션이 종료되었습니다. 다시 로그인한 후 시도하세요.",
  authErrPasswordRequired: "확인을 위해 비밀번호를 입력하세요.",
  authErrDeleteBadPw: "비밀번호가 틀렸습니다. 계정이 삭제되지 않았습니다.",
  authErrReauth: "다시 로그인한 후 시도하세요.",
  authErrDeletePerm: "계정 데이터를 삭제할 수 없습니다. Firebase 권한을 확인하고 다시 시도하세요.",
  authErrDeleteGeneric: "계정을 삭제할 수 없습니다. 나중에 다시 시도하세요.",
  registerOk: "계정이 생성되었습니다! 로그인 중…",
  forgotPassword: "비밀번호를 잊으셨나요?",
  resetSent: "비밀번호 재설정 링크가 이메일로 전송되었습니다.",
  authErrResetGeneric: "비밀번호 재설정 이메일을 보낼 수 없습니다. 다시 시도하세요.",

  themeSunset: "따뜻한 석양",
  themeIce: "시원한 얼음",
  themeMono: "모노크롬",
  themeCyber: "사이버 석양",
  themeAurora: "오로라",
  themeRose: "미드나잇 로즈",
  themeCosmos: "딥 스페이스",
  themeForest: "어두운 숲",
  themeObsidian: "옵시디언",
  themeGraphite: "그래파이트",
  themeMidnight: "미드나잇",
  themeEspresso: "에스프레소",

  timeJustNow: "방금",
  timeMinAgo: (n) => `${n}분 전`,
  timeHoursAgo: (n) => `${n}시간 전`,
  timeDaysAgo: (n) => `${n}일 전`,
  timeYesterday: "어제",

  localeTag: "ko-KR",
  dateFormatLong: { year: "numeric", month: "long", day: "numeric" },
  dateFormatShort: { month: "short", day: "numeric", hour: "2-digit", minute: "2-digit" },
  dateFormatReminder: { month: "short", day: "numeric", hour: "2-digit", minute: "2-digit" },

  welcomeNote1Title: "GlassWave 🌊",
  welcomeNote1Body:
    "글래스모피즘 디자인의 현대적인 노트 앱입니다. 반투명 카드, 배경 블러, 부드러운 애니메이션을 제공합니다.",
  welcomeNote2Title: "GlassWave 기능",
  welcomeNote2Body:
    "서식 있는 노트 작성과 편집, 고정, 보관, 휴지통, 검색, 정렬, 알림을 지원합니다.",
  welcomeNote3Title: "동기화 및 오프라인",
  welcomeNote3Body:
    "Firebase로 기기 간 동기화, 로컬 캐시로 오프라인 작업, 가입 없이 쓰는 게스트 모드를 지원합니다.",
  welcomeNote4Title: "언어 및 테마",
  welcomeNote4Body:
    "인터페이스 언어 3종(러시아어, 영어, 한국어)과 취향에 맞는 12가지 색상 테마를 제공합니다.",

  settingsSync: "노트 동기화",
  settingsSyncDesc: "로그인하여 클라우드에 노트를 저장하고 다른 기기에서 사용하세요.",
  settingsAuthBtn: "로그인 또는 회원가입",
  settingsFont: "글꼴 크기",
  settingsFontSm: "작게",
  settingsFontMd: "중간",
  settingsFontLg: "크게",
  editorPreview: "미리보기",
  editorEditMode: "편집",
  remindPick: "날짜 선택...",
  remindMondayAt: "월 08:00",
  authFooter: "데이터는 Firebase 클라우드에서 안전하게 보호됩니다.\n모든 기기에서 노트가 동기화됩니다.",
  authErrNotFound: "사용자를 찾을 수 없습니다",
  authErrWrongPw: "잘못된 비밀번호입니다",
  authErrEmailInUse: "이미 사용 중인 이메일입니다",
  timeHoursAgoSuffix: "시간 전",
  timeDaysAgoSuffix: "일 전",
  languageNameRu: "Русский",
  languageNameEn: "English",
  languageNameKo: "한국어",
};

export const TRANSLATIONS: Record<Language, Translation> = { ru, en, ko };

export function themeNameByLang(themeId: string, language: Language): string {
  const key = `theme${themeId.charAt(0).toUpperCase()}${themeId.slice(1)}` as keyof Translation;
  const t = TRANSLATIONS[language];
  return (t[key] as string) || themeId;
}

export const LANGUAGE_OPTIONS = [
  { code: "ru" as Language, nativeName: "Русский" },
  { code: "en" as Language, nativeName: "English" },
  { code: "ko" as Language, nativeName: "한국어" },
] as const;
