import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:uuid/uuid.dart';
import '../../../models/player.dart';
import '../../../services/local_storage_service.dart';
import '../../../services/firestore_service.dart';
import '../../../features/auth/providers/auth_provider.dart';
import '../../game/providers/game_provider.dart';

/// Provider for managing players
final playerProvider = StateNotifierProvider<PlayerNotifier, AsyncValue<List<Player>>>((ref) {
  final localStorage = ref.watch(localStorageServiceProvider);
  final firestoreService = ref.watch(firestoreServiceProvider);
  final authService = ref.watch(authServiceProvider);
  return PlayerNotifier(localStorage, firestoreService, authService);
});

/// Notifier for player state management
class PlayerNotifier extends StateNotifier<AsyncValue<List<Player>>> {
  final LocalStorageService _localStorage;
  final FirestoreService _firestoreService;
  final dynamic _authService;
  final _uuid = const Uuid();

  PlayerNotifier(this._localStorage, this._firestoreService, this._authService) 
      : super(const AsyncValue.loading()) {
    loadPlayers();
  }

  /// Get current user ID (returns 'guest' for guest mode, Firebase UID for logged in)
  String get _userId => _authService.currentUserId ?? 'guest';

  /// Load all players from storage (Firestore + local cache for both guest and authenticated)
  Future<void> loadPlayers() async {
    state = const AsyncValue.loading();
    try {
      // Load from Firestore and cache locally (both guest and authenticated)
      final players = await _firestoreService.getPlayers(_userId);
      
      // Cache locally for offline access
      for (final player in players) {
        await _localStorage.savePlayer(player);
      }
      
      state = AsyncValue.data(players);
    } catch (e, stack) {
      // Fallback to local storage on error (offline mode)
      try {
        final players = await _localStorage.getAllPlayers();
        state = AsyncValue.data(players);
      } catch (localError, _) {
        state = AsyncValue.error(e, stack);
      }
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

      print('DEBUG PlayerProvider: Saving player locally: ${player.id} - ${player.name}');
      await _localStorage.savePlayer(player);
      print('DEBUG PlayerProvider: Saved locally ✓');
      
      // Save to Firestore (both guest and authenticated users)
      print('DEBUG PlayerProvider: Saving to Firestore with userId: $_userId');
      await _firestoreService.savePlayer(player, _userId);
      print('DEBUG PlayerProvider: Saved to Firestore ✓');
      
      print('DEBUG PlayerProvider: Reloading players...');
      await loadPlayers(); // Reload list
      print('DEBUG PlayerProvider: Players reloaded ✓');

      print('DEBUG PlayerProvider: Returning player: ${player.id}');
      return player;
    } catch (e, stack) {
      // Handle error with logging
      print('DEBUG PlayerProvider ERROR: $e');
      print('DEBUG PlayerProvider Stack: $stack');
      return null;
    }
  }

  /// Update an existing player
  Future<void> updatePlayer(Player player) async {
    try {
      final updated = player.copyWith(updatedAt: DateTime.now());
      await _localStorage.savePlayer(updated);
      
      // Save to Firestore (both guest and authenticated users)
      await _firestoreService.savePlayer(updated, _userId);
      
      await loadPlayers();
    } catch (e) {
      // Handle error
    }
  }

  /// Delete a player
  Future<void> deletePlayer(String playerId) async {
    try {
      await _localStorage.deletePlayer(playerId);
      
      // Delete from Firestore (both guest and authenticated users)
      await _firestoreService.deletePlayer(playerId);
      
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
