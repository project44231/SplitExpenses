/// App-wide constants
class AppConstants {
  // App Info
  static const String appName = 'Poker Tracker';
  static const String appVersion = '1.0.0';
  
  // Validation
  static const double minBuyInAmount = 0.01;
  static const double maxBuyInAmount = 1000000.0;
  static const int maxPlayerNameLength = 50;
  static const int maxGroupNameLength = 50;
  static const int maxNotesLength = 500;
  
  // Settlement
  static const double settlementTolerancePercent = 5.0;
  
  // Pagination
  static const int gamesPerPage = 20;
  static const int playersPerPage = 50;
  
  // Cache
  static const Duration cacheRefreshDuration = Duration(minutes: 5);
  
  // Local Storage Keys
  static const String isGuestModeKey = 'is_guest_mode';
  static const String defaultCurrencyKey = 'default_currency';
  static const String themeKey = 'theme_mode';
  static const String onboardingCompletedKey = 'onboarding_completed';
  
  // Collection Names (Firestore)
  static const String usersCollection = 'users';
  static const String gameGroupsCollection = 'game_groups';
  static const String gamesCollection = 'games';
  static const String playersCollection = 'players';
  static const String buyInsCollection = 'buy_ins';
  static const String cashOutsCollection = 'cash_outs';
  static const String settlementsCollection = 'settlements';
  
  // Routes
  static const String splashRoute = '/';
  static const String onboardingRoute = '/onboarding';
  static const String homeRoute = '/home';
  static const String authRoute = '/auth';
  static const String newGameRoute = '/new-game';
  static const String activeGameRoute = '/active-game';
  static const String settlementRoute = '/settlement';
  static const String historyRoute = '/history';
  static const String gameDetailsRoute = '/game-details';
  static const String playerStatsRoute = '/player-stats';
  static const String leaderboardRoute = '/leaderboard';
  static const String profileRoute = '/profile';
  static const String settingsRoute = '/settings';
  static const String groupsRoute = '/groups';
  static const String playersRoute = '/players';
  static const String playerContactsRoute = '/player-contacts';
}
