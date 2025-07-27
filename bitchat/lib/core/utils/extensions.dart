import 'package:flutter/material.dart';

/// Extension methods for String
extension StringExtensions on String {
  /// Check if string is null or empty
  bool get isNullOrEmpty => isEmpty;

  /// Check if string is not null and not empty
  bool get isNotNullOrEmpty => isNotEmpty;

  /// Capitalize first letter
  String get capitalize {
    if (isEmpty) return this;
    return '${this[0].toUpperCase()}${substring(1)}';
  }

  /// Convert to title case
  String get titleCase {
    return split(' ').map((word) => word.capitalize).join(' ');
  }

  /// Truncate string to specified length
  String truncate(int length, {String suffix = '...'}) {
    if (this.length <= length) return this;
    return '${substring(0, length)}$suffix';
  }

  /// Check if string is a valid email
  bool get isValidEmail {
    return RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$').hasMatch(this);
  }

  /// Remove all whitespace
  String get removeWhitespace => replaceAll(RegExp(r'\s+'), '');

  /// Convert to snake_case
  String get toSnakeCase {
    return replaceAllMapped(
      RegExp(r'[A-Z]'),
      (match) => '_${match.group(0)!.toLowerCase()}',
    ).replaceFirst(RegExp(r'^_'), '');
  }

  /// Convert to camelCase
  String get toCamelCase {
    final words = split('_');
    if (words.isEmpty) return this;
    return words.first + words.skip(1).map((word) => word.capitalize).join();
  }
}

/// Extension methods for DateTime
extension DateTimeExtensions on DateTime {
  /// Check if date is today
  bool get isToday {
    final now = DateTime.now();
    return year == now.year && month == now.month && day == now.day;
  }

  /// Check if date is yesterday
  bool get isYesterday {
    final yesterday = DateTime.now().subtract(const Duration(days: 1));
    return year == yesterday.year &&
        month == yesterday.month &&
        day == yesterday.day;
  }

  /// Check if date is tomorrow
  bool get isTomorrow {
    final tomorrow = DateTime.now().add(const Duration(days: 1));
    return year == tomorrow.year &&
        month == tomorrow.month &&
        day == tomorrow.day;
  }

  /// Get time ago string
  String get timeAgo {
    final now = DateTime.now();
    final difference = now.difference(this);

    if (difference.inDays > 365) {
      final years = (difference.inDays / 365).floor();
      return '${years}y ago';
    } else if (difference.inDays > 30) {
      final months = (difference.inDays / 30).floor();
      return '${months}mo ago';
    } else if (difference.inDays > 0) {
      return '${difference.inDays}d ago';
    } else if (difference.inHours > 0) {
      return '${difference.inHours}h ago';
    } else if (difference.inMinutes > 0) {
      return '${difference.inMinutes}m ago';
    } else {
      return 'Just now';
    }
  }

  /// Format as relative time
  String get relativeTime {
    if (isToday) return 'Today';
    if (isYesterday) return 'Yesterday';
    if (isTomorrow) return 'Tomorrow';
    return timeAgo;
  }

  /// Start of day
  DateTime get startOfDay {
    return DateTime(year, month, day);
  }

  /// End of day
  DateTime get endOfDay {
    return DateTime(year, month, day, 23, 59, 59, 999);
  }
}

/// Extension methods for Duration
extension DurationExtensions on Duration {
  /// Format duration as human readable string
  String get humanReadable {
    if (inDays > 0) {
      return '${inDays}d ${inHours.remainder(24)}h';
    } else if (inHours > 0) {
      return '${inHours}h ${inMinutes.remainder(60)}m';
    } else if (inMinutes > 0) {
      return '${inMinutes}m ${inSeconds.remainder(60)}s';
    } else {
      return '${inSeconds}s';
    }
  }

  /// Format as MM:SS
  String get mmss {
    final minutes = inMinutes.remainder(60).toString().padLeft(2, '0');
    final seconds = inSeconds.remainder(60).toString().padLeft(2, '0');
    return '$minutes:$seconds';
  }

  /// Format as HH:MM:SS
  String get hhmmss {
    final hours = inHours.toString().padLeft(2, '0');
    final minutes = inMinutes.remainder(60).toString().padLeft(2, '0');
    final seconds = inSeconds.remainder(60).toString().padLeft(2, '0');
    return '$hours:$minutes:$seconds';
  }
}

/// Extension methods for List
extension ListExtensions<T> on List<T> {
  /// Get element at index or null if out of bounds
  T? elementAtOrNull(int index) {
    if (index < 0 || index >= length) return null;
    return this[index];
  }

  /// Get first element or null if empty
  T? get firstOrNull => isEmpty ? null : first;

  /// Get last element or null if empty
  T? get lastOrNull => isEmpty ? null : last;

  /// Split list into chunks of specified size
  List<List<T>> chunk(int size) {
    if (size <= 0) throw ArgumentError('Chunk size must be positive');

    final chunks = <List<T>>[];
    for (int i = 0; i < length; i += size) {
      chunks.add(sublist(i, (i + size > length) ? length : i + size));
    }
    return chunks;
  }

  /// Remove duplicates while preserving order
  List<T> get unique {
    final seen = <T>{};
    return where((element) => seen.add(element)).toList();
  }

  /// Group elements by a key function
  Map<K, List<T>> groupBy<K>(K Function(T) keyFunction) {
    final map = <K, List<T>>{};
    for (final element in this) {
      final key = keyFunction(element);
      map.putIfAbsent(key, () => <T>[]).add(element);
    }
    return map;
  }
}

/// Extension methods for Map
extension MapExtensions<K, V> on Map<K, V> {
  /// Get value or return default if key doesn't exist
  V getOrDefault(K key, V defaultValue) {
    return this[key] ?? defaultValue;
  }

  /// Get value or compute and store if key doesn't exist
  V getOrPut(K key, V Function() defaultValue) {
    if (containsKey(key)) {
      return this[key] as V;
    }
    final value = defaultValue();
    this[key] = value;
    return value;
  }

  /// Filter map by predicate
  Map<K, V> where(bool Function(K key, V value) predicate) {
    final result = <K, V>{};
    for (final entry in entries) {
      if (predicate(entry.key, entry.value)) {
        result[entry.key] = entry.value;
      }
    }
    return result;
  }

  /// Transform map values
  Map<K, U> mapValues<U>(U Function(V value) transform) {
    final result = <K, U>{};
    for (final entry in entries) {
      result[entry.key] = transform(entry.value);
    }
    return result;
  }
}

/// Extension methods for BuildContext
extension BuildContextExtensions on BuildContext {
  /// Get screen size
  Size get screenSize => MediaQuery.of(this).size;

  /// Get screen width
  double get screenWidth => screenSize.width;

  /// Get screen height
  double get screenHeight => screenSize.height;

  /// Check if device is in landscape mode
  bool get isLandscape => screenWidth > screenHeight;

  /// Check if device is in portrait mode
  bool get isPortrait => screenHeight > screenWidth;

  /// Get theme data
  ThemeData get theme => Theme.of(this);

  /// Get text theme
  TextTheme get textTheme => theme.textTheme;

  /// Get color scheme
  ColorScheme get colorScheme => theme.colorScheme;

  /// Check if dark mode is enabled
  bool get isDarkMode => theme.brightness == Brightness.dark;

  /// Show snackbar
  void showSnackBar(String message, {Duration? duration}) {
    ScaffoldMessenger.of(this).showSnackBar(
      SnackBar(
        content: Text(message),
        duration: duration ?? const Duration(seconds: 3),
      ),
    );
  }

  /// Show error snackbar
  void showErrorSnackBar(String message, {Duration? duration}) {
    ScaffoldMessenger.of(this).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: colorScheme.error,
        duration: duration ?? const Duration(seconds: 4),
      ),
    );
  }

  /// Show success snackbar
  void showSuccessSnackBar(String message, {Duration? duration}) {
    ScaffoldMessenger.of(this).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: Colors.green,
        duration: duration ?? const Duration(seconds: 3),
      ),
    );
  }
}

/// Extension methods for Color
extension ColorExtensions on Color {
  /// Get hex string representation
  String get hexString {
    return '#${(0xFF000000 | (r * 255).round() << 16 | (g * 255).round() << 8 | (b * 255).round()).toRadixString(16).substring(2)}';
  }

  /// Create color with opacity
  Color withOpacity(double opacity) {
    return Color.fromRGBO(
      (r * 255).round(),
      (g * 255).round(),
      (b * 255).round(),
      opacity,
    );
  }

  /// Lighten color by percentage
  Color lighten(double percentage) {
    final hsl = HSLColor.fromColor(this);
    final lightness = (hsl.lightness + percentage).clamp(0.0, 1.0);
    return hsl.withLightness(lightness).toColor();
  }

  /// Darken color by percentage
  Color darken(double percentage) {
    final hsl = HSLColor.fromColor(this);
    final lightness = (hsl.lightness - percentage).clamp(0.0, 1.0);
    return hsl.withLightness(lightness).toColor();
  }
}
