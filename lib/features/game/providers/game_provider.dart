import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:uuid/uuid.dart';
import '../../../models/game.dart';
import '../../../models/game_group.dart';
import '../../../models/buy_in.dart';
import '../../../models/cash_out.dart';
import '../../../services/local_storage_service.dart';
import '../../../features/auth/providers/auth_provider.dart';
import '../../../core/constants/currency.dart';

/// Provider for managing games
final gameProvider = StateNotifierProvider<GameNotifier, AsyncValue<List<Game>>>((ref) {
  final localStorage = ref.watch(localStorageServiceProvider);
  return GameNotifier(localStorage);
});

/// Provider for the current active game
final activeGameProvider = StateProvider<Game?>((ref) => null);

/// Notifier for game state management
class GameNotifier extends StateNotifier<AsyncValue<List<Game>>> {
  final LocalStorageService _localStorage;
  final _uuid = const Uuid();

  GameNotifier(this._localStorage) : super(const AsyncValue.loading()) {
    loadGames();
  }

  /// Load all games from storage
  Future<void> loadGames() async {
    state = const AsyncValue.loading();
    try {
      final games = await _localStorage.getAllGames();
      state = AsyncValue.data(games);
    } catch (e, stack) {
      state = AsyncValue.error(e, stack);
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

      await _localStorage.saveGame(game);
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
      ownerId: 'guest', // Guest user
      createdAt: DateTime.now(),
    );

    await _localStorage.saveGameGroup(newGroup);
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
      await loadGames();
    } catch (e) {
      // Handle error
    }
  }

  /// Delete a game
  Future<void> deleteGame(String gameId) async {
    try {
      await _localStorage.deleteGame(gameId);
      await loadGames();
    } catch (e) {
      // Handle error
    }
  }

  /// Get game by ID
  Future<Game?> getGame(String gameId) async {
    return await _localStorage.getGame(gameId);
  }

  /// Get buy-ins for a game
  Future<List<BuyIn>> getBuyIns(String gameId) async {
    return await _localStorage.getBuyInsByGame(gameId);
  }

  /// Get cash-outs for a game
  Future<List<CashOut>> getCashOuts(String gameId) async {
    return await _localStorage.getCashOutsByGame(gameId);
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

      await _localStorage.saveBuyIn(buyIn);
    } catch (e) {
      // Handle error
    }
  }

  /// Update a buy-in
  Future<void> updateBuyIn(BuyIn buyIn) async {
    try {
      await _localStorage.saveBuyIn(buyIn);
    } catch (e) {
      // Handle error
    }
  }

  /// Delete a buy-in
  Future<void> deleteBuyIn(String buyInId) async {
    try {
      await _localStorage.deleteBuyIn(buyInId);
    } catch (e) {
      // Handle error
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
    } catch (e) {
      // Handle error
    }
  }

  /// Clear all cash-outs for a game (used when editing)
  Future<void> clearCashOuts(String gameId) async {
    try {
      await _localStorage.deleteCashOutsByGame(gameId);
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
      await _localStorage.saveGame(game);
      await loadGames();
    } catch (e) {
      // Handle error
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
