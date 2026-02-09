import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:uuid/uuid.dart';
import '../../../models/game.dart';
import '../../../models/game_group.dart';
import '../../../models/buy_in.dart';
import '../../../models/cash_out.dart';
import '../../../services/local_storage_service.dart';
import '../../../services/firestore_service.dart';
import '../../../features/auth/providers/auth_provider.dart';
import '../../../core/constants/currency.dart';

/// Provider for Firestore service
final firestoreServiceProvider = Provider<FirestoreService>((ref) {
  return FirestoreService();
});

/// Provider for managing games
final gameProvider = StateNotifierProvider<GameNotifier, AsyncValue<List<Game>>>((ref) {
  final localStorage = ref.watch(localStorageServiceProvider);
  final firestoreService = ref.watch(firestoreServiceProvider);
  final authService = ref.watch(authServiceProvider);
  return GameNotifier(localStorage, firestoreService, authService);
});

/// Provider for the current active game
final activeGameProvider = StateProvider<Game?>((ref) => null);

/// Notifier for game state management
class GameNotifier extends StateNotifier<AsyncValue<List<Game>>> {
  final LocalStorageService _localStorage;
  final FirestoreService _firestoreService;
  final dynamic _authService;
  final _uuid = const Uuid();

  GameNotifier(this._localStorage, this._firestoreService, this._authService) 
      : super(const AsyncValue.loading()) {
    loadGames();
  }

  /// Get current user ID (returns 'guest' for guest mode, Firebase UID for logged in)
  String get _userId => _authService.currentUserId ?? 'guest';

  /// Load all games from storage (Always uses Firestore, with local cache)
  Future<void> loadGames() async {
    state = const AsyncValue.loading();
    try {
      // Load from Firestore (works for both guest and authenticated users)
      final games = await _firestoreService.getGames(_userId);
      
      // Cache locally for offline access
      for (final game in games) {
        await _localStorage.saveGame(game);
      }
      
      state = AsyncValue.data(games);
    } catch (e, stack) {
      // Fallback to local storage on error (offline mode)
      try {
        final games = await _localStorage.getAllGames();
        state = AsyncValue.data(games);
      } catch (localError, _) {
        state = AsyncValue.error(e, stack);
      }
    }
  }

  /// Create a new game
  Future<Game?> createGame({
    required List<String> playerIds,
    String? groupId,
    String currency = 'USD',
    String? notes,
  }) async {
    try {
      // Ensure we have a group (create default if needed)
      final actualGroupId = groupId ?? await _ensureDefaultGroup();

      final game = Game(
        id: _uuid.v4(),
        groupId: actualGroupId,
        status: GameStatus.active,
        currency: currency,
        playerIds: playerIds,
        startTime: DateTime.now(),
        notes: notes,
        createdAt: DateTime.now(),
      );

      // Save to local storage
      await _localStorage.saveGame(game);
      
      // Save to Firestore (always, for both guest and authenticated users)
      await _firestoreService.saveGame(game, _userId);
      
      await loadGames();

      return game;
    } catch (e) {
      // Handle error
      rethrow;
    }
  }

  /// Ensure default "Quick Games" group exists
  Future<String> _ensureDefaultGroup() async {
    final groups = await _localStorage.getAllGameGroups();
    
    // Check if default group exists
    final defaultGroup = groups.where((g) => g.name == 'Quick Games').firstOrNull;
    if (defaultGroup != null) {
      return defaultGroup.id;
    }

    // Create default group
    final newGroup = GameGroup(
      id: _uuid.v4(),
      name: 'Quick Games',
      ownerId: _userId,
      createdAt: DateTime.now(),
    );

    await _localStorage.saveGameGroup(newGroup);
    
    // Save to Firestore (always)
    await _firestoreService.saveGameGroup(newGroup, _userId);
    
    return newGroup.id;
  }

  /// End a game
  Future<void> endGame(String gameId) async {
    try {
      final game = await _localStorage.getGame(gameId);
      if (game == null) return;

      final updatedGame = game.copyWith(
        status: GameStatus.ended,
        endTime: DateTime.now(),
        updatedAt: DateTime.now(),
      );

      await _localStorage.saveGame(updatedGame);
      
      // Save to Firestore (always)
      await _firestoreService.saveGame(updatedGame, _userId);
      
      await loadGames();
    } catch (e) {
      // Handle error
    }
  }

  /// Delete a game
  Future<void> deleteGame(String gameId) async {
    try {
      await _localStorage.deleteGame(gameId);
      
      // Delete from Firestore (always)
      await _firestoreService.deleteGame(gameId);
      
      await loadGames();
    } catch (e) {
      // Handle error
    }
  }

  /// Get game by ID
  Future<Game?> getGame(String gameId) async {
    try {
      // Try Firestore first (for both guest and authenticated users)
      final game = await _firestoreService.getGame(gameId);
      if (game != null) {
        await _localStorage.saveGame(game);
        return game;
      }
      return await _localStorage.getGame(gameId);
    } catch (e) {
      // Fallback to local storage
      return await _localStorage.getGame(gameId);
    }
  }

  /// Get buy-ins for a game
  Future<List<BuyIn>> getBuyIns(String gameId) async {
    try {
      // Try Firestore first (for both guest and authenticated users)
      final buyIns = await _firestoreService.getBuyIns(gameId);
      for (final buyIn in buyIns) {
        await _localStorage.saveBuyIn(buyIn);
      }
      return buyIns;
    } catch (e) {
      // Fallback to local storage
      return await _localStorage.getBuyInsByGame(gameId);
    }
  }

  /// Get cash-outs for a game
  Future<List<CashOut>> getCashOuts(String gameId) async {
    try {
      // Try Firestore first (for both guest and authenticated users)
      final cashOuts = await _firestoreService.getCashOuts(gameId);
      for (final cashOut in cashOuts) {
        await _localStorage.saveCashOut(cashOut);
      }
      return cashOuts;
    } catch (e) {
      // Fallback to local storage
      return await _localStorage.getCashOutsByGame(gameId);
    }
  }

  /// Add a buy-in
  Future<void> addBuyIn({
    required String gameId,
    required String playerId,
    required double amount,
    BuyInType type = BuyInType.initial,
    String? notes,
  }) async {
    try {
      final buyIn = BuyIn(
        id: _uuid.v4(),
        gameId: gameId,
        playerId: playerId,
        amount: amount,
        type: type,
        timestamp: DateTime.now(),
        notes: notes,
      );

      print('DEBUG GameProvider: Saving buy-in locally: ${buyIn.id} - \$${buyIn.amount}');
      await _localStorage.saveBuyIn(buyIn);
      print('DEBUG GameProvider: Saved locally ✓');
      
      // Save to Firestore (always)
      print('DEBUG GameProvider: Saving buy-in to Firestore with userId: $_userId');
      await _firestoreService.saveBuyIn(buyIn, _userId);
      print('DEBUG GameProvider: Saved to Firestore ✓');
    } catch (e, stack) {
      // Handle error
      print('DEBUG GameProvider ERROR adding buy-in: $e');
      print('DEBUG Stack: $stack');
      rethrow;
    }
  }

  /// Update a buy-in
  Future<void> updateBuyIn(BuyIn buyIn) async {
    try {
      // Save locally
      await _localStorage.saveBuyIn(buyIn);
      
      // Save to Firestore (always)
      await _firestoreService.saveBuyIn(buyIn, _userId);
    } catch (e) {
      rethrow;
    }
  }

  /// Delete a buy-in
  Future<void> deleteBuyIn(String buyInId) async {
    try {
      await _localStorage.deleteBuyIn(buyInId);
      
      // Delete from Firestore (always)
      await _firestoreService.deleteBuyIn(buyInId);
    } catch (e) {
      rethrow;
    }
  }

  /// Add a cash-out
  Future<void> addCashOut({
    required String gameId,
    required String playerId,
    required double amount,
    String? notes,
  }) async {
    try {
      final cashOut = CashOut(
        id: _uuid.v4(),
        gameId: gameId,
        playerId: playerId,
        amount: amount,
        timestamp: DateTime.now(),
        notes: notes,
      );

      await _localStorage.saveCashOut(cashOut);
      
      // Save to Firestore (always)
      await _firestoreService.saveCashOut(cashOut, _userId);
    } catch (e) {
      // Handle error
    }
  }

  /// Clear all cash-outs for a game (used when editing)
  Future<void> clearCashOuts(String gameId) async {
    try {
      await _localStorage.deleteCashOutsByGame(gameId);
      
      // Delete from Firestore (always)
      await _firestoreService.deleteCashOutsByGame(gameId);
    } catch (e) {
      // Handle error
    }
  }

  /// Get active games
  List<Game> getActiveGames() {
    return state.when(
      data: (games) => games.where((g) => g.status == GameStatus.active).toList(),
      loading: () => [],
      error: (_, __) => [],
    );
  }

  /// Get ended games
  List<Game> getEndedGames() {
    return state.when(
      data: (games) => games.where((g) => g.status == GameStatus.ended).toList(),
      loading: () => [],
      error: (_, __) => [],
    );
  }

  /// Get or create current active game
  Future<Game> getOrCreateCurrentGame() async {
    // Force reload to ensure we have the latest state
    await loadGames();
    
    // Check if there's an active game
    final activeGames = getActiveGames();
    if (activeGames.isNotEmpty) {
      return activeGames.first;
    }

    // No active game, create a new one with no players
    try {
      final game = await createGame(
        playerIds: [], // Start with no players
        notes: 'Quick game',
      );

      if (game == null) {
        throw Exception('Failed to create new game - createGame returned null');
      }

      return game;
    } catch (e) {
      // Handle error
      rethrow;
    }
  }

  /// Update an existing game
  Future<void> updateGame(Game game) async {
    try {
      // Save to local storage
      await _localStorage.saveGame(game);
      
      // Save to Firestore (always, for both guest and authenticated users)
      await _firestoreService.saveGame(game, _userId);
      
      await loadGames();
    } catch (e) {
      // Handle error
      rethrow;
    }
  }
}

/// Provider for game groups
final gameGroupProvider = FutureProvider<List<GameGroup>>((ref) async {
  final localStorage = ref.watch(localStorageServiceProvider);
  return await localStorage.getAllGameGroups();
});

/// Provider for default currency
final defaultCurrencyProvider = StateProvider<Currency>((ref) => AppCurrencies.usd);
