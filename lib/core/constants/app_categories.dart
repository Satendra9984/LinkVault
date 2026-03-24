class AppCategories {
  static const List<String> list = [
    'Favorites',
    'Restaurants',
    'Books',
    'Films',
    'Travel',
    'Music',
    'Art',
    'Activities',
    'Beauty',
    'Fashion',
    'Home',
    'Games',
    'Apps',
    'Learning',
    'Ideas',
    'Gifts'
  ];

  static String getIconForCategory(String category) {
    switch (category) {
      case 'Favorites':
        return '⭐';
      case 'Restaurants':
        return '🍽️';
      case 'Books':
        return '📚';
      case 'Films':
        return '🎬';
      case 'Travel':
        return '✈️';
      case 'Music':
        return '🎵';
      case 'Art':
        return '🎨';
      case 'Activities':
        return '🏃';
      case 'Beauty':
        return '💄';
      case 'Fashion':
        return '👗';
      case 'Home':
        return '🏠';
      case 'Games':
        return '🎮';
      case 'Apps':
        return '📱';
      case 'Learning':
        return '🎓';
      case 'Ideas':
        return '💡';
      case 'Gifts':
        return '🎁';
      default:
        return '📁';
    }
  }
}
