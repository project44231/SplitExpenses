import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:uuid/uuid.dart';
import '../../../models/player.dart';
import '../../../services/local_storage_service.dart';
import '../../../features/auth/providers/auth_provider.dart';

/// Provider for managing players
final playerProvider = StateNotifierProvider<PlayerNotifier, AsyncValue<List<Player>>>((ref) {
  final localStorage = ref.watch(localStorageServiceProvider);
  return PlayerNotifier(localStorage);
});

/// Notifier for player state management
class PlayerNotifier extends StateNotifier<AsyncValue<List<Player>>> {
  final LocalStorageService _localStorage;
  final _uuid = const Uuid();

  PlayerNotifier(this._localStorage) : super(const AsyncValue.loading()) {
    loadPlayers();
  }

  /// Load all players from storage
  Future<void> loadPlayers() async {
    state = const AsyncValue.loading();
    try {
      final players = await _localStorage.getAllPlayers();
      state = AsyncValue.data(players);
    } catch (e, stack) {
      state = AsyncValue.error(e, stack);
    }
  }

  /// Add a new player
  Future<Player?> addPlayer({
    required String name,
    String? email,
    String? phone,
  }) async {
    try {
      final player = Player(
        id: _uuid.v4(),
        name: name.trim(),
        email: email?.trim(),
        phone: phone?.trim(),
        createdAt: DateTime.now(),
      );

      await _localStorage.savePlayer(player);
      await loadPlayers(); // Reload list

      return player;
    } catch (e) {
      // Handle error silently, return null
      return null;
    }
  }

  /// Update an existing player
  Future<void> updatePlayer(Player player) async {
    try {
      final updated = player.copyWith(updatedAt: DateTime.now());
      await _localStorage.savePlayer(updated);
      await loadPlayers();
    } catch (e) {
      // Handle error
    }
  }

  /// Delete a player
  Future<void> deletePlayer(String playerId) async {
    try {
      await _localStorage.deletePlayer(playerId);
      await loadPlayers();
    } catch (e) {
      // Handle error
    }
  }

  /// Search players by name
  List<Player> searchPlayers(String query) {
    return state.when(
      data: (players) {
        if (query.isEmpty) return players;
        final lowerQuery = query.toLowerCase();
        return players
            .where((p) => p.name.toLowerCase().contains(lowerQuery))
            .toList();
      },
      loading: () => [],
      error: (_, __) => [],
    );
  }

  /// Get player by ID
  Player? getPlayerById(String id) {
    return state.when(
      data: (players) => players.where((p) => p.id == id).firstOrNull,
      loading: () => null,
      error: (_, __) => null,
    );
  }
}

/// Provider for getting a specific player by ID
final playerByIdProvider = Provider.family<Player?, String>((ref, id) {
  final playersAsync = ref.watch(playerProvider);
  return playersAsync.when(
    data: (players) => players.where((p) => p.id == id).firstOrNull,
    loading: () => null,
    error: (_, __) => null,
  );
});
