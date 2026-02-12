import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../features/auth/screens/auth_screen.dart';
import '../../features/auth/screens/splash_screen.dart';
import '../../features/game/screens/home_screen.dart';
import '../../features/game/screens/group_expenses_list_screen.dart';
import '../../features/game/screens/new_game_screen.dart';
import '../../features/game/screens/event_detail_screen.dart';
import '../../features/game/screens/settlement_screen.dart';
import '../../features/history/screens/history_screen.dart';
import '../../features/history/screens/game_details_screen.dart';
import '../../features/profile/screens/profile_screen.dart';
import '../../features/groups/screens/groups_screen.dart';
import '../../features/players/screens/player_contacts_screen.dart';
import '../constants/app_constants.dart';

/// App router configuration
class AppRouter {
  static final GoRouter router = GoRouter(
    initialLocation: AppConstants.splashRoute,
    routes: [
      // Splash
      GoRoute(
        path: AppConstants.splashRoute,
        builder: (context, state) => const SplashScreen(),
      ),

      // Auth
      GoRoute(
        path: AppConstants.authRoute,
        builder: (context, state) => const AuthScreen(),
      ),

      // Home (with bottom navigation)
      GoRoute(
        path: AppConstants.homeRoute,
        builder: (context, state) => const HomeScreen(),
      ),

      // Group Expenses List
      GoRoute(
        path: AppConstants.groupExpensesRoute,
        builder: (context, state) => const GroupExpensesListScreen(),
      ),

      // Create Group Expense
      GoRoute(
        path: AppConstants.createGroupExpenseRoute,
        builder: (context, state) => const NewGameScreen(),
      ),

      // Group Expense Detail (with specific ID)
      GoRoute(
        path: '${AppConstants.groupExpenseDetailRoute}/:groupId',
        builder: (context, state) {
          final groupId = state.pathParameters['groupId']!;
          return EventDetailScreen(eventId: groupId);
        },
      ),

      // Legacy routes for backward compatibility
      GoRoute(
        path: AppConstants.newEventRoute,
        builder: (context, state) => const NewGameScreen(),
      ),
      GoRoute(
        path: '/event/:eventId',
        builder: (context, state) {
          final eventId = state.pathParameters['eventId'] ?? 'current';
          return EventDetailScreen(eventId: eventId);
        },
      ),
      GoRoute(
        path: '${AppConstants.activeEventRoute}/:eventId',
        builder: (context, state) {
          final eventId = state.pathParameters['eventId']!;
          return EventDetailScreen(eventId: eventId);
        },
      ),

      // Settlement / Cash-out
      GoRoute(
        path: '${AppConstants.settlementRoute}/:eventId',
        builder: (context, state) {
          final eventId = state.pathParameters['eventId']!;
          return SettlementScreen(gameId: eventId);
        },
      ),
      GoRoute(
        path: '/cash-out/:eventId',
        builder: (context, state) {
          final eventId = state.pathParameters['eventId']!;
          return SettlementScreen(gameId: eventId);
        },
      ),

      // History
      GoRoute(
        path: AppConstants.historyRoute,
        builder: (context, state) => const HistoryScreen(),
      ),

      // Event Details
      GoRoute(
        path: '${AppConstants.eventDetailsRoute}/:eventId',
        builder: (context, state) {
          final eventId = state.pathParameters['eventId']!;
          return GameDetailsScreen(gameId: eventId); // Will be renamed to EventDetailsScreen
        },
      ),

      // Profile
      GoRoute(
        path: AppConstants.profileRoute,
        builder: (context, state) => const ProfileScreen(),
      ),

      // Groups
      GoRoute(
        path: AppConstants.groupsRoute,
        builder: (context, state) => const GroupsScreen(),
      ),

      // Participant Contacts
      GoRoute(
        path: AppConstants.participantContactsRoute,
        builder: (context, state) => const PlayerContactsScreen(), // Will be renamed to ParticipantContactsScreen
      ),
    ],
    errorBuilder: (context, state) => Scaffold(
      body: Center(
        child: Text('Page not found: ${state.uri}'),
      ),
    ),
  );
}
