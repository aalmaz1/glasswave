import { createContext, useContext, useState, useEffect, ReactNode } from "react";

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
  authErrTooMany: string;
  authErrGeneric: string;
  authErrLoggedOut: string;
  authErrPasswordRequired: string;
  authErrDeleteBadPw: string;
  authErrReauth: string;
  authErrDeletePerm: string;
  authErrDeleteGeneric: string;
  registerOk: string;

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
  authErrNotAllowed: "В Firebase не включён вход по email и паролю",
  authErrTooMany: "Слишком много попыток. Повторите позже",
  authErrGeneric: "Не удалось выполнить вход. Повторите попытку",
  authErrLoggedOut: "Сессия уже завершена. Войдите снова и повторите попытку.",
  authErrPasswordRequired: "Введите пароль для подтверждения.",
  authErrDeleteBadPw: "Неверный пароль. Аккаунт не был удалён.",
  authErrReauth: "Войдите в аккаунт заново и повторите попытку.",
  authErrDeletePerm: "Не удалось удалить данные аккаунта. Проверьте права Firebase и повторите попытку.",
  authErrDeleteGeneric: "Не удалось удалить аккаунт. Повторите попытку позже.",
  registerOk: "Аккаунт создан! Входим…",

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
  authErrNotAllowed: "Email/password sign-in is not enabled in Firebase",
  authErrTooMany: "Too many attempts. Please try again later",
  authErrGeneric: "Sign-in failed. Please try again",
  authErrLoggedOut: "Session already ended. Sign in again and retry.",
  authErrPasswordRequired: "Enter your password to confirm.",
  authErrDeleteBadPw: "Wrong password. Account was not deleted.",
  authErrReauth: "Sign in again and retry.",
  authErrDeletePerm: "Could not delete account data. Check Firebase permissions and retry.",
  authErrDeleteGeneric: "Could not delete account. Please try again later.",
  registerOk: "Account created! Signing in…",

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
  authErrNotAllowed: "Firebase에서 이메일/비밀번호 로그인이 활성화되지 않았습니다",
  authErrTooMany: "시도 횟수가 너무 많습니다. 나중에 다시 시도하세요",
  authErrGeneric: "로그인에 실패했습니다. 다시 시도하세요",
  authErrLoggedOut: "세션이 종료되었습니다. 다시 로그인한 후 시도하세요.",
  authErrPasswordRequired: "확인을 위해 비밀번호를 입력하세요.",
  authErrDeleteBadPw: "비밀번호가 틀렸습니다. 계정이 삭제되지 않았습니다.",
  authErrReauth: "다시 로그인한 후 시도하세요.",
  authErrDeletePerm: "계정 데이터를 삭제할 수 없습니다. Firebase 권한을 확인하고 다시 시도하세요.",
  authErrDeleteGeneric: "계정을 삭제할 수 없습니다. 나중에 다시 시도하세요.",
  registerOk: "계정이 생성되었습니다! 로그인 중…",

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
};

export const TRANSLATIONS: Record<Language, Translation> = { ru, en, ko };

export function themeNameByLang(themeId: string, language: Language): string {
  const key = `theme${themeId.charAt(0).toUpperCase()}${themeId.slice(1)}` as keyof Translation;
  const t = TRANSLATIONS[language];
  return (t[key] as string) || themeId;
}

interface LanguageContextType {
  language: Language;
  setLanguage: (lang: Language) => void;
  t: Translation;
}

const LanguageContext = createContext<LanguageContextType | undefined>(undefined);

export function LanguageProvider({ children }: { children: ReactNode }) {
  const [language, setLanguageState] = useState<Language>(() => {
    if (typeof window === "undefined") return "ru";
    const saved = window.localStorage.getItem("preferred-lang");
    if (saved === "en" || saved === "ko" || saved === "ru") return saved;
    const nav = (navigator.language || "ru").toLowerCase();
    if (nav.startsWith("ko")) return "ko";
    if (nav.startsWith("en")) return "en";
    return "ru";
  });

  useEffect(() => {
    window.localStorage.setItem("preferred-lang", language);
    document.documentElement.lang = language;
  }, [language]);

  const setLanguage = (lang: Language) => {
    setLanguageState(lang);
  };

  const t = TRANSLATIONS[language];

  return (
    <LanguageContext.Provider value={{ language, setLanguage, t }}>
      {children}
    </LanguageContext.Provider>
  );
}

export function useTranslation() {
  const context = useContext(LanguageContext);
  if (context === undefined) {
    throw new Error("useTranslation must be used within a LanguageProvider");
  }
  return context;
}

export const LANGUAGE_OPTIONS = [
  { code: "ru" as Language, nativeName: "Русский" },
  { code: "en" as Language, nativeName: "English" },
  { code: "ko" as Language, nativeName: "한국어" },
] as const;
