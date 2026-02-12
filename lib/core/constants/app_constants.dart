/// App-wide constants
class AppConstants {
  // App Info
  static const String appName = 'SplitExpenses';
  static const String appVersion = '1.0.0';
  
  // Validation
  static const double minExpenseAmount = 0.01;
  static const double maxExpenseAmount = 1000000.0;
  static const int maxParticipantNameLength = 50;
  static const int maxGroupNameLength = 50;
  static const int maxNotesLength = 500;
  static const int maxDescriptionLength = 200;
  
  // Settlement
  static const double settlementTolerancePercent = 5.0;
  
  // Pagination
  static const int eventsPerPage = 20;
  static const int participantsPerPage = 50;
  
  // Cache
  static const Duration cacheRefreshDuration = Duration(minutes: 5);
  
  // Local Storage Keys
  static const String isGuestModeKey = 'is_guest_mode';
  static const String defaultCurrencyKey = 'default_currency';
  static const String themeKey = 'theme_mode';
  static const String onboardingCompletedKey = 'onboarding_completed';
  
  // Collection Names (Firestore)
  static const String usersCollection = 'users';
  static const String eventGroupsCollection = 'event_groups';
  static const String eventsCollection = 'events';
  static const String participantsCollection = 'participants';
  static const String expensesCollection = 'expenses';
  static const String settlementsCollection = 'settlements';
  
  // Routes
  static const String splashRoute = '/';
  static const String onboardingRoute = '/onboarding';
  static const String homeRoute = '/home';
  static const String authRoute = '/auth';
  static const String groupExpensesRoute = '/group-expenses';
  static const String createGroupExpenseRoute = '/create-group-expense';
  static const String groupExpenseDetailRoute = '/group-expense';
  static const String newEventRoute = '/new-event'; // Legacy
  static const String activeEventRoute = '/active-event'; // Legacy
  static const String activeGameRoute = activeEventRoute; // Alias for backward compatibility
  static const String settlementRoute = '/settlement';
  static const String historyRoute = '/history';
  static const String eventDetailsRoute = '/event-details';
  static const String participantStatsRoute = '/participant-stats';
  static const String leaderboardRoute = '/leaderboard';
  static const String profileRoute = '/profile';
  static const String settingsRoute = '/settings';
  static const String groupsRoute = '/groups';
  static const String participantsRoute = '/participants';
  static const String participantContactsRoute = '/participant-contacts';
  static const String playerContactsRoute = participantContactsRoute; // Alias for backward compatibility
}
