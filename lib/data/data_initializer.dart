import 'package:hive_flutter/hive_flutter.dart';
import '../models/note.dart';
import '../models/auth_user.dart';

/// Инициализация Hive и seed данных
class DataInitializer {
  static Future<void> initialize() async {
    await Hive.initFlutter();
    
    // Register adapters
    if (!Hive.isAdapterRegistered(0)) {
      Hive.registerAdapter(NoteAdapter());
    }
    if (!Hive.isAdapterRegistered(1)) {
      Hive.registerAdapter(AuthUserAdapter());
    }
    
    // Open boxes
    await Hive.openBox('noova_users');
    await Hive.openBox('noova_me');
    await Hive.openBox('noova_prefs_default');
    
    // Load current user
    final meBox = Hive.box('noova_me');
    final email = meBox.get('email');
    
    if (email != null) {
      await Hive.openBox('noova_notes_$email');
      await Hive.openBox('noova_prefs_$email');
    } else {
      // Create seed data for demo
      await _createSeedData();
    }
  }
  
  static Future<void> _createSeedData() async {
    final boxName = 'noova_notes_default';
    final box = await Hive.openBox<Map>(boxName);
    
    if (box.isEmpty) {
      final now = DateTime.now();
      final seedNotes = [
        Note(
          id: now.millisecondsSinceEpoch,
          title: 'Product Roadmap Q3',
          body: 'Key features to implement:\n- Glassmorphism UI\n- 12 premium themes\n- Local storage with Hive\n- Riverpod state management\n\nTimeline: July - September',
          updatedAt: now.subtract(const Duration(days: 2)),
          accentIdx: 0,
          pinned: true,
        ),
        Note(
          id: now.millisecondsSinceEpoch - 1000,
          title: 'Design Sprint Notes',
          body: 'Day 1: Understand\nDay 2: Diverge\nDay 3: Decide\nDay 4: Prototype\nDay 5: Test\n\nKey insights from user interviews...',
          updatedAt: now.subtract(const Duration(days: 5)),
          accentIdx: 1,
          pinned: true,
        ),
        Note(
          id: now.millisecondsSinceEpoch - 2000,
          title: 'Reading List',
          body: '📚 Books to read:\n\n1. Clean Architecture - R.C.Martin\n2. Design Patterns - GoF\n3. The Pragmatic Programmer\n4. Domain-Driven Design',
          updatedAt: now.subtract(const Duration(days: 1)),
          accentIdx: 2,
        ),
        Note(
          id: now.millisecondsSinceEpoch - 3000,
          title: 'API Integration',
          body: 'REST API endpoints to implement:\n\nGET /api/notes\nPOST /api/notes\nPUT /api/notes/:id\nDELETE /api/notes/:id\n\nAuthentication: JWT tokens',
          updatedAt: now.subtract(const Duration(hours: 12)),
          accentIdx: 0,
        ),
        Note(
          id: now.millisecondsSinceEpoch - 4000,
          title: 'Weekly Reflection',
          body: 'This week I learned:\n\n• Flutter BackdropFilter for glassmorphism\n• Riverpod for state management\n• Hive for local storage\n\nNext week goals:\n- Improve animations\n- Add more themes',
          updatedAt: now.subtract(const Duration(days: 7)),
          accentIdx: 3,
        ),
        Note(
          id: now.millisecondsSinceEpoch - 5000,
          title: 'Miso Ramen Recipe',
          body: 'Ingredients:\n- Ramen noodles\n- Miso paste\n- Chicken broth\n- Soft boiled egg\n- Nori\n- Green onions\n- Chashu pork\n\nCook time: 45 min',
          updatedAt: now.subtract(const Duration(days: 10)),
          accentIdx: 1,
          archived: true,
        ),
        Note(
          id: now.millisecondsSinceEpoch - 6000,
          title: 'CSS Deep Dive',
          body: 'Advanced CSS concepts:\n\n1. Grid layout\n2. Flexbox\n3. Custom properties\n4. Animations\n5. Transforms\n\nResources: MDN, CSS-Tricks',
          updatedAt: now.subtract(const Duration(days: 3)),
          accentIdx: 2,
        ),
        Note(
          id: now.millisecondsSinceEpoch - 7000,
          title: 'Kyoto Itinerary',
          body: 'Day 1: Fushimi Inari Shrine\nDay 2: Arashiyama Bamboo Grove\nDay 3: Kinkaku-ji Temple\nDay 4: Gion District\n\nDon\'t forget:\n- JR Pass\n- IC Card\n- Portable WiFi',
          updatedAt: now.subtract(const Duration(days: 14)),
          accentIdx: 3,
        ),
      ];
      
      for (final note in seedNotes) {
        await box.put(note.id, note.toJson());
      }
    }
  }
}
