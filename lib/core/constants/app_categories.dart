/// Preset collection categories (label → default emoji via [getIconForCategory]).
///
/// Users may also pick **Custom** and set any name + emoji string stored as
/// `category` / `icon_name` (catalog text only — no remote icon URLs).
class AppCategories {
  AppCategories._();

  /// Shown as the last row in the category picker; not stored as `category`.
  static const String customOptionLabel = 'Custom…';

  static const List<String> list = [
    'Favorites',
    'Work',
    'Personal',
    'Reading',
    'Watch later',
    'Recipes',
    'Restaurants',
    'Travel',
    'Fitness',
    'Health',
    'Finance',
    'Shopping',
    'Books',
    'Films',
    'Music',
    'Podcasts',
    'Games',
    'Apps',
    'Learning',
    'Courses',
    'Art',
    'Photography',
    'Design',
    'Writing',
    'Ideas',
    'Projects',
    'Home',
    'Family',
    'Pets',
    'Sports',
    'Outdoors',
    'Fashion',
    'Beauty',
    'Gifts',
    'Events',
    'News',
    'Tech',
    'Science',
    'Activities',
  ];

  static bool isPreset(String category) => list.contains(category);

  static String getIconForCategory(String category) {
    switch (category) {
      case 'Favorites':
        return '⭐';
      case 'Work':
        return '💼';
      case 'Personal':
        return '👤';
      case 'Reading':
        return '📖';
      case 'Watch later':
        return '👀';
      case 'Recipes':
        return '📝';
      case 'Restaurants':
        return '🍽️';
      case 'Travel':
        return '✈️';
      case 'Fitness':
        return '💪';
      case 'Health':
        return '🏥';
      case 'Finance':
        return '💰';
      case 'Shopping':
        return '🛒';
      case 'Books':
        return '📚';
      case 'Films':
        return '🎬';
      case 'Music':
        return '🎵';
      case 'Podcasts':
        return '🎙️';
      case 'Games':
        return '🎮';
      case 'Apps':
        return '📱';
      case 'Learning':
        return '🎓';
      case 'Courses':
        return '📒';
      case 'Art':
        return '🎨';
      case 'Photography':
        return '📷';
      case 'Design':
        return '✏️';
      case 'Writing':
        return '✍️';
      case 'Ideas':
        return '💡';
      case 'Projects':
        return '📋';
      case 'Home':
        return '🏠';
      case 'Family':
        return '👪';
      case 'Pets':
        return '🐾';
      case 'Sports':
        return '⚽';
      case 'Outdoors':
        return '🌲';
      case 'Fashion':
        return '👗';
      case 'Beauty':
        return '💄';
      case 'Gifts':
        return '🎁';
      case 'Events':
        return '📅';
      case 'News':
        return '📰';
      case 'Tech':
        return '💻';
      case 'Science':
        return '🔬';
      case 'Activities':
        return '🏃';
      default:
        return '📁';
    }
  }

  /// All preset emojis plus common extras for the icon grid picker.
  static List<String> get allPickerEmojis {
    final set = <String>{
      for (final c in list) getIconForCategory(c),
      '📁',
      '🗂️',
      '🧩',
      '🔖',
      '🔗',
      '💬',
      '🎯',
      '🔥',
      '✨',
      '🌟',
      '🍕',
      '☕',
      '🎁',
      '🧠',
      '🌙',
      '☀️',
      '🌍',
      '🎧',
      '🖼️',
      '📌',
      '🏷️',
    };
    return set.toList();
  }
}
