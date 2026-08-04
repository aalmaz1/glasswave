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
  archived: string;
  trash: string;
  searchPlaceholder: string;
  createNote: string;
  noNotes: string;
  noNotesSubtitle: string;
  
  // Note card
  untitled: string;
  pin: string;
  unpin: string;
  edit: string;
  archive: string;
  unarchive: string;
  delete: string;
  restore: string;
  deleteForeverAction: string;
  
  // Note editor
  noteTitlePlaceholder: string;
  noteContentPlaceholder: string;
  save: string;
  saving: string;
  saved: string;
  close: string;
  
  // Reminder
  setReminder: string;
  clearReminder: string;
  reminderScheduled: string;
  reminderCleared: string;
  
  // Sort
  sortBy: string;
  sortDefault: string;
  sortByCreated: string;
  sortByUpdated: string;
  
  // Auth
  welcomeBack: string;
  login: string;
  register: string;
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
  
  // RSS
  loadingRSS: string;
  rssLoaded: string;
  rssError: string;
}

const TRANSLATIONS: Record<Language, Translation> = {
  ru: {
    // Settings
    settings: "Настройки",
    account: "Аккаунт",
    theme: "Цветовая тема",
    language: "Язык интерфейса",
    danger: "Опасная зона",
    deleteAccount: "Удалить аккаунт",
    deleteDescription: "Будут безвозвратно удалены профиль, настройки и все заметки.",
    deleteConfirmTitle: "Удалить аккаунт?",
    deleteWarning: "Это действие необратимо: профиль, настройки и все заметки для",
    confirmPassword: "Подтвердите пароль",
    passwordPlaceholder: "Ваш пароль",
    cancel: "Отмена",
    deleteForever: "Удалить навсегда",
    deleting: "Удаляем…",
    synced: "Синхронизировано",
    logout: "Выйти",
    selectLanguage: "Выберите язык интерфейса",
    
    // Dashboard
    dashboard: "Заметки",
    allNotes: "Все",
    pinned: "Закреплённые",
    archived: "Архив",
    trash: "Корзина",
    searchPlaceholder: "Поиск заметок...",
    createNote: "Создать заметку",
    noNotes: "Нет заметок",
    noNotesSubtitle: "Создайте первую заметку или загрузите из RSS",
    
    // Note card
    untitled: "Без названия",
    pin: "Закрепить",
    unpin: "Открепить",
    edit: "Редактировать",
    archive: "В архив",
    unarchive: "Из архива",
    delete: "В корзину",
    restore: "Восстановить",
    deleteForeverAction: "Удалить навсегда",
    
    // Editor
    noteTitlePlaceholder: "Заголовок",
    noteContentPlaceholder: "Напишите что-нибудь...",
    save: "Сохранить",
    saving: "Сохранение...",
    saved: "Сохранено",
    close: "Закрыть",
    
    // Reminder
    setReminder: "Напомнить",
    clearReminder: "Отменить напоминание",
    reminderScheduled: "Напоминание установлено",
    reminderCleared: "Напоминание отменено",
    
    // Sort
    sortBy: "Сортировка",
    sortDefault: "По порядку",
    sortByCreated: "По дате создания",
    sortByUpdated: "По дате обновления",
    
    // Auth
    welcomeBack: "С возвращением!",
    login: "Войти",
    register: "Регистрация",
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
    
    // RSS
    loadingRSS: "Загрузка RSS...",
    rssLoaded: "Загружено из RSS",
    rssError: "Ошибка загрузки RSS",
  },
  
  en: {
    // Settings
    settings: "Settings",
    account: "Account",
    theme: "Color theme",
    language: "Interface language",
    danger: "Danger zone",
    deleteAccount: "Delete account",
    deleteDescription: "Your profile, preferences, and all notes will be permanently deleted.",
    deleteConfirmTitle: "Delete account?",
    deleteWarning: "This action is irreversible: the profile, preferences, and all notes for",
    confirmPassword: "Confirm your password",
    passwordPlaceholder: "Your password",
    cancel: "Cancel",
    deleteForever: "Delete permanently",
    deleting: "Deleting…",
    synced: "Synced",
    logout: "Log out",
    selectLanguage: "Choose interface language",
    
    // Dashboard
    dashboard: "Notes",
    allNotes: "All",
    pinned: "Pinned",
    archived: "Archived",
    trash: "Trash",
    searchPlaceholder: "Search notes...",
    createNote: "Create note",
    noNotes: "No notes",
    noNotesSubtitle: "Create your first note or load from RSS",
    
    // Note card
    untitled: "Untitled",
    pin: "Pin",
    unpin: "Unpin",
    edit: "Edit",
    archive: "Archive",
    unarchive: "Unarchive",
    delete: "Move to trash",
    restore: "Restore",
    deleteForeverAction: "Delete forever",
    
    // Editor
    noteTitlePlaceholder: "Title",
    noteContentPlaceholder: "Write something...",
    save: "Save",
    saving: "Saving...",
    saved: "Saved",
    close: "Close",
    
    // Reminder
    setReminder: "Set reminder",
    clearReminder: "Clear reminder",
    reminderScheduled: "Reminder scheduled",
    reminderCleared: "Reminder cleared",
    
    // Sort
    sortBy: "Sort by",
    sortDefault: "Default order",
    sortByCreated: "Date created",
    sortByUpdated: "Date updated",
    
    // Auth
    welcomeBack: "Welcome back!",
    login: "Log in",
    register: "Sign up",
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
    
    // RSS
    loadingRSS: "Loading RSS...",
    rssLoaded: "Loaded from RSS",
    rssError: "RSS load error",
  },
  
  ko: {
    // Settings
    settings: "설정",
    account: "계정",
    theme: "색상 테마",
    language: "인터페이스 언어",
    danger: "위험 영역",
    deleteAccount: "계정 삭제",
    deleteDescription: "프로필, 환경설정 및 모든 노트가 영구적으로 삭제됩니다.",
    deleteConfirmTitle: "계정을 삭제하시겠습니까?",
    deleteWarning: "이 작업은 되돌릴 수 없습니다. 다음 계정의 프로필, 환경설정 및 모든 노트가 삭제됩니다:",
    confirmPassword: "비밀번호 확인",
    passwordPlaceholder: "비밀번호",
    cancel: "취소",
    deleteForever: "영구 삭제",
    deleting: "삭제 중…",
    synced: "동기화됨",
    logout: "로그아웃",
    selectLanguage: "인터페이스 언어 선택",
    
    // Dashboard
    dashboard: "노트",
    allNotes: "전체",
    pinned: "고정됨",
    archived: "보관됨",
    trash: "휴지통",
    searchPlaceholder: "노트 검색...",
    createNote: "노트 만들기",
    noNotes: "노트 없음",
    noNotesSubtitle: "첫 번째 노트를 만들거나 RSS 에서 불러오세요",
    
    // Note card
    untitled: "제목 없음",
    pin: "고정",
    unpin: "고정 해제",
    edit: "편집",
    archive: "보관",
    unarchive: "보관 해제",
    delete: "휴지통으로 이동",
    restore: "복원",
    deleteForeverAction: "영구 삭제",
    
    // Editor
    noteTitlePlaceholder: "제목",
    noteContentPlaceholder: "무언가 작성하세요...",
    save: "저장",
    saving: "저장 중...",
    saved: "저장됨",
    close: "닫기",
    
    // Reminder
    setReminder: "알림 설정",
    clearReminder: "알림 해제",
    reminderScheduled: "알림이 설정되었습니다",
    reminderCleared: "알림이 해제되었습니다",
    
    // Sort
    sortBy: "정렬 기준",
    sortDefault: "기본 순서",
    sortByCreated: "생성일 기준",
    sortByUpdated: "수정일 기준",
    
    // Auth
    welcomeBack: "다시 오신 것을 환영합니다!",
    login: "로그인",
    register: "회원가입",
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
    
    // RSS
    loadingRSS: "RSS 로딩 중...",
    rssLoaded: "RSS 에서 불러옴",
    rssError: "RSS 로딩 오류",
  },
};

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
    return saved === "en" || saved === "ko" || saved === "ru" ? saved : "ru";
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
  { code: "ru", nativeName: "Русский" },
  { code: "en", nativeName: "English" },
  { code: "ko", nativeName: "한국어" },
] as const;
