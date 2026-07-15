import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'dart:ui' show ImageFilter;
import '../models/user.dart';
import '../models/note.dart';
import '../models/theme_data.dart';
import '../utils/storage.dart';

/// Провайдер состояния приложения
class AppProvider extends ChangeNotifier {
  User? _currentUser;
  List<User> _users = [];
  List<Note> _notes = [];
  String _themeId = 'sunset';
  double _fontSize = 1.0;
  int _sortIndex = 0; // 0: default, 1: createdAt, 2: updatedAt
  int _tabIndex = 0; // 0: all, 1: archived, 2: trashed
  String _searchQuery = '';
  bool _isLoading = true;

  // Геттеры
  User? get currentUser => _currentUser;
  List<Note> get notes => _notes;
  AppTheme get currentTheme => Themes.getById(_themeId);
  String get themeId => _themeId;
  double get fontSize => _fontSize;
  int get sortIndex => _sortIndex;
  int get tabIndex => _tabIndex;
  String get searchQuery => _searchQuery;
  bool get isLoading => _isLoading;

  /// Инициализация приложения
  Future<void> init() async {
    try {
      // Загружаем пользователей
      _users = await Storage.getUsers();
      
      // Загружаем текущего пользователя
      _currentUser = await Storage.getCurrentUser();
      
      // Загружаем тему и шрифт
      _themeId = await Storage.getTheme();
      _fontSize = await Storage.getFontSize();
      
      // Загружаем заметки
      if (_currentUser != null) {
        _notes = await Storage.getNotes(_currentUser!.email);
        
        // Если заметок нет, создаём стартовый набор
        if (_notes.isEmpty) {
          _notes = _seedNotes();
          await Storage.saveNotes(_currentUser!.email, _notes);
        }
      }
      
      _isLoading = false;
      notifyListeners();
    } catch (e) {
      print('Ошибка инициализации: $e');
      _isLoading = false;
      notifyListeners();
    }
  }

  /// Стартовый набор заметок
  List<Note> _seedNotes() {
    final now = DateTime.now();
    return [
      Note(
        id: '1',
        title: 'Добро пожаловать! 👋',
        body: 'Это ваше первое приложение с эффектом матового стекла.\n\nПопробуйте:\n- Создать новую заметку\n- Изменить тему в настройках\n- Добавить напоминание',
        accentIdx: 0,
        pinned: true,
        updatedAt: now.subtract(const Duration(minutes: 5)),
      ),
      Note(
        id: '2',
        title: 'Список покупок 🛒',
        body: '- Молоко\n- Хлеб\n- Яйца\n- Фрукты\n- Овощи',
        accentIdx: 1,
        updatedAt: now.subtract(const Duration(hours: 2)),
      ),
      Note(
        id: '3',
        title: 'Идеи для проекта 💡',
        body: '**Основная идея:**\nСоздать красивое приложение с glassmorphism эффектом.\n\n_Ключевые особенности:_\n1. Премиальный дизайн\n2. Плавные анимации\n3. 12 цветовых тем',
        accentIdx: 2,
        pinned: true,
        updatedAt: now.subtract(const Duration(days: 1)),
      ),
      Note(
        id: '4',
        title: 'Встреча с командой 📅',
        body: 'Дата: завтра в 14:00\n\nПовестка:\n- Обсуждение дизайна\n- Планирование спринта\n- Review кода',
        accentIdx: 3,
        reminder: now.add(const Duration(days: 1, hours: 2)),
        updatedAt: now.subtract(const Duration(days: 2)),
      ),
      Note(
        id: '5',
        title: 'Цитата дня ✨',
        body: '"Простота — это высшая форма утончённости."\n\n— Леонардо да Винчи',
        accentIdx: 0,
        updatedAt: now.subtract(const Duration(days: 3)),
      ),
      Note(
        id: '6',
        title: 'Книги для чтения 📚',
        body: '1. Чистый код - Роберт Мартин\n2. Паттерны проектирования\n3. Совершенный код',
        accentIdx: 1,
        updatedAt: now.subtract(const Duration(days: 5)),
      ),
      Note(
        id: '7',
        title: 'Тренировки 💪',
        body: '**План на неделю:**\n\nПн: Грудь + Трицепс\nСр: Спина + Бицепс\nПт: Ноги + Плечи',
        accentIdx: 2,
        updatedAt: now.subtract(const Duration(days: 7)),
      ),
      Note(
        id: '8',
        title: 'Архивная заметка 📦',
        body: 'Эта заметка была архивирована для примера.',
        accentIdx: 3,
        archived: true,
        updatedAt: now.subtract(const Duration(days: 10)),
      ),
    ];
  }

  /// Регистрация пользователя
  Future<bool> register(String email, String name, String password) async {
    // Проверка существования
    if (_users.any((u) => u.email == email)) {
      return false;
    }

    final user = User(
      email: email,
      name: name,
      passwordHash: Storage.hashPassword(password),
    );

    _users.add(user);
    await Storage.saveUsers(_users);
    
    // Автоматический вход
    await login(email, password);
    return true;
  }

  /// Вход
  Future<bool> login(String email, String password) async {
    final user = _users.firstWhere(
      (u) => u.email == email,
      orElse: () => throw Exception('Пользователь не найден'),
    );

    if (!Storage.verifyPassword(password, user.passwordHash)) {
      return false;
    }

    _currentUser = user;
    await Storage.setCurrentUser(user);
    _notes = await Storage.getNotes(email);
    
    if (_notes.isEmpty) {
      _notes = _seedNotes();
      await Storage.saveNotes(email, _notes);
    }
    
    notifyListeners();
    return true;
  }

  /// Выход
  Future<void> logout() async {
    _currentUser = null;
    _notes = [];
    await Storage.setCurrentUser(null);
    notifyListeners();
  }

  /// Сохранить заметки
  Future<void> saveNotes() async {
    if (_currentUser != null) {
      await Storage.saveNotes(_currentUser!.email, _notes);
    }
  }

  /// Добавить/обновить заметку
  void upsertNote(Note note) {
    final index = _notes.indexWhere((n) => n.id == note.id);
    if (index >= 0) {
      _notes[index] = note;
    } else {
      _notes.insert(0, note);
    }
    saveNotes();
    notifyListeners();
  }

  /// Удалить заметку (переместить в корзину)
  void trashNote(String id) {
    final index = _notes.indexWhere((n) => n.id == id);
    if (index >= 0) {
      _notes[index] = _notes[index].copyWith(trashed: true, pinned: false);
      saveNotes();
      notifyListeners();
    }
  }

  /// Восстановить из корзины
  void restoreNote(String id) {
    final index = _notes.indexWhere((n) => n.id == id);
    if (index >= 0) {
      _notes[index] = _notes[index].copyWith(trashed: false);
      saveNotes();
      notifyListeners();
    }
  }

  /// Удалить навсегда
  void deleteNoteForever(String id) {
    _notes.removeWhere((n) => n.id == id);
    saveNotes();
    notifyListeners();
  }

  /// Архивировать/разархивировать
  void toggleArchive(String id) {
    final index = _notes.indexWhere((n) => n.id == id);
    if (index >= 0) {
      _notes[index] = _notes[index].copyWith(
        archived: !_notes[index].archived,
        pinned: false,
      );
      saveNotes();
      notifyListeners();
    }
  }

  /// Закрепить/открепить
  void togglePin(String id) {
    final index = _notes.indexWhere((n) => n.id == id);
    if (index >= 0) {
      _notes[index] = _notes[index].copyWith(pinned: !_notes[index].pinned);
      saveNotes();
      notifyListeners();
    }
  }

  /// Установить напоминание
  void setReminder(String id, DateTime? reminder) {
    final index = _notes.indexWhere((n) => n.id == id);
    if (index >= 0) {
      _notes[index] = _notes[index].copyWith(reminder: reminder);
      saveNotes();
      notifyListeners();
    }
  }

  /// Сменить тему
  Future<void> setTheme(String themeId) async {
    _themeId = themeId;
    await Storage.saveTheme(themeId);
    notifyListeners();
  }

  /// Сменить размер шрифта
  Future<void> setFontSize(double size) async {
    _fontSize = size;
    await Storage.saveFontSize(size);
    notifyListeners();
  }

  /// Установить сортировку
  void setSortIndex(int index) {
    _sortIndex = index;
    notifyListeners();
  }

  /// Установить активную вкладку
  void setTabIndex(int index) {
    _tabIndex = index;
    notifyListeners();
  }

  /// Установить поисковый запрос
  void setSearchQuery(String query) {
    _searchQuery = query;
    notifyListeners();
  }

  /// Получить отфильтрованные и отсортированные заметки
  List<Note> get filteredNotes {
    var result = _notes;

    // Фильтр по вкладке
    switch (_tabIndex) {
      case 1: // Архив
        result = result.where((n) => n.archived && !n.trashed).toList();
        break;
      case 2: // Корзина
        result = result.where((n) => n.trashed).toList();
        break;
      default: // Все
        result = result.where((n) => !n.trashed && !n.archived).toList();
    }

    // Поиск
    if (_searchQuery.isNotEmpty) {
      result = result
          .where((n) =>
              n.title.toLowerCase().contains(_searchQuery.toLowerCase()) ||
              n.body.toLowerCase().contains(_searchQuery.toLowerCase()))
          .toList();
    }

    // Сортировка
    switch (_sortIndex) {
      case 1: // Дата создания
        result.sort((a, b) => b.createdAt.compareTo(a.createdAt));
        break;
      case 2: // Дата изменения
        result.sort((a, b) => b.updatedAt.compareTo(a.updatedAt));
        break;
      default: // По умолчанию (закреплённые первыми)
        result.sort((a, b) {
          if (a.pinned && !b.pinned) return -1;
          if (!a.pinned && b.pinned) return 1;
          return b.updatedAt.compareTo(a.updatedAt);
        });
    }

    return result;
  }

  /// Получить закрепленные заметки
  List<Note> get pinnedNotes =>
      filteredNotes.where((n) => n.pinned).toList();

  /// Получить обычные заметки
  List<Note> get regularNotes =>
      filteredNotes.where((n) => !n.pinned).toList();
}
