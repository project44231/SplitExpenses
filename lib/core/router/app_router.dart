import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../features/auth/screens/auth_screen.dart';
import '../../features/auth/screens/splash_screen.dart';
import '../../features/game/screens/home_screen.dart';
import '../../features/game/screens/new_game_screen.dart';
import '../../features/game/screens/active_game_screen.dart';
import '../../features/game/screens/settlement_screen.dart';
import '../../features/history/screens/history_screen.dart';
import '../../features/history/screens/game_details_screen.dart';
import '../../features/profile/screens/profile_screen.dart';
import '../../features/groups/screens/groups_screen.dart';
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

      // New Game
      GoRoute(
        path: AppConstants.newGameRoute,
        builder: (context, state) => const NewGameScreen(),
      ),

      // Current/Active Game (no ID - will auto-create or load current)
      GoRoute(
        path: '/game',
        builder: (context, state) => const ActiveGameScreen(gameId: 'current'),
      ),

      // Active Game (with specific ID)
      GoRoute(
        path: '${AppConstants.activeGameRoute}/:gameId',
        builder: (context, state) {
          final gameId = state.pathParameters['gameId']!;
          return ActiveGameScreen(gameId: gameId);
        },
      ),

      // Settlement
      GoRoute(
        path: '${AppConstants.settlementRoute}/:gameId',
        builder: (context, state) {
          final gameId = state.pathParameters['gameId']!;
          return SettlementScreen(gameId: gameId);
        },
      ),

      // History
      GoRoute(
        path: AppConstants.historyRoute,
        builder: (context, state) => const HistoryScreen(),
      ),

      // Game Details
      GoRoute(
        path: '${AppConstants.gameDetailsRoute}/:gameId',
        builder: (context, state) {
          final gameId = state.pathParameters['gameId']!;
          return GameDetailsScreen(gameId: gameId);
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
    ],
    errorBuilder: (context, state) => Scaffold(
      body: Center(
        child: Text('Page not found: ${state.uri}'),
      ),
    ),
  );
}
