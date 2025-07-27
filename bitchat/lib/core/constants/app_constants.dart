/// Application-wide constants and configuration values
class AppConstants {
  // App Information
  static const String appName = 'BitChat';
  static const String appVersion = '1.0.0';
  static const String appDescription =
      'Secure, decentralized, peer-to-peer messaging over Bluetooth mesh networks';

  // Protocol Constants
  static const int maxHopCount = 7;
  static const int maxMessageSize = 1024; // bytes
  static const Duration messageTimeout = Duration(seconds: 30);
  static const Duration discoveryTimeout = Duration(seconds: 10);
  static const Duration connectionTimeout = Duration(seconds: 15);

  // UI Constants
  static const double defaultPadding = 16.0;
  static const double smallPadding = 8.0;
  static const double largePadding = 24.0;
  static const double borderRadius = 8.0;
  static const double iconSize = 24.0;

  // Storage Keys
  static const String userPreferencesBox = 'user_preferences';
  static const String messagesBox = 'messages';
  static const String channelsBox = 'channels';
  static const String peersBox = 'peers';

  // Settings Keys
  static const String themeKey = 'theme_mode';
  static const String usernameKey = 'username';
  static const String autoDiscoveryKey = 'auto_discovery';
  static const String notificationsKey = 'notifications_enabled';

  // Error Messages
  static const String genericError = 'An unexpected error occurred';
  static const String networkError = 'Network connection failed';
  static const String bluetoothError = 'Bluetooth operation failed';
  static const String permissionError = 'Required permissions not granted';
  static const String encryptionError = 'Encryption/decryption failed';

  // Private constructor to prevent instantiation
  AppConstants._();
}
