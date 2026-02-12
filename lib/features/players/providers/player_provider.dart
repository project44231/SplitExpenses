import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:uuid/uuid.dart';
// Using Participant model but aliasing for backward compatibility
import '../../../models/participant.dart';
import '../../../services/local_storage_service.dart';
import '../../../services/firestore_service.dart';
import '../../../features/auth/providers/auth_provider.dart';
import '../../game/providers/game_provider.dart';


// Type alias for backward compatibility in existing code

/// Provider for managing participants (keeping name as playerProvider for backward compatibility)
final playerProvider = StateNotifierProvider<ParticipantNotifier, AsyncValue<List<Participant>>>((ref) {
  final localStorage = ref.watch(localStorageServiceProvider);
  final firestoreService = ref.watch(firestoreServiceProvider);
  final authService = ref.watch(authServiceProvider);
  return ParticipantNotifier(localStorage, firestoreService, authService);
});

/// Notifier for participant state management
class ParticipantNotifier extends StateNotifier<AsyncValue<List<Participant>>> {
  final LocalStorageService _localStorage;
  final FirestoreService _firestoreService;
  final dynamic _authService;
  final _uuid = const Uuid();

  ParticipantNotifier(this._localStorage, this._firestoreService, this._authService) 
      : super(const AsyncValue.loading()) {
    loadPlayers();
  }

  /// Get current user ID (returns 'guest' for guest mode, Firebase UID for logged in)
  String get _userId => _authService.currentUserId ?? 'guest';

  /// Load all participants from storage (Firestore + local cache for both guest and authenticated)
  /// Keeping method name as loadPlayers for backward compatibility
  Future<void> loadPlayers() async {
    state = const AsyncValue.loading();
    try {
      // Load from Firestore and cache locally (both guest and authenticated)
      final participants = await _firestoreService.getParticipants(_userId);
      
      // Cache locally for offline access
      for (final participant in participants) {
        await _localStorage.saveParticipant(participant);
      }
      
      state = AsyncValue.data(participants);
    } catch (e, stack) {
      // Fallback to local storage on error (offline mode)
      try {
        final participants = await _localStorage.getAllParticipants();
        state = AsyncValue.data(participants);
      } catch (localError, _) {
        state = AsyncValue.error(e, stack);
      }
    }
  }

  /// Add a new player (participant) - backward compatibility
  Future<Participant?> addPlayer({
    required String name,
    String? email,
    String? phone,
  }) async {
    return addParticipant(name: name, email: email, phone: phone);
  }

  /// Add a new participant
  Future<Participant?> addParticipant({
    required String name,
    String? email,
    String? phone,
  }) async {
    try {
      final participant = Participant(
        id: _uuid.v4(),
        userId: _userId,
        name: name.trim(),
        email: email?.trim(),
        phone: phone?.trim(),
        createdAt: DateTime.now(),
      );

      await _localStorage.saveParticipant(participant);
      
      // Save to Firestore (both guest and authenticated users)
      await _firestoreService.saveParticipant(participant, _userId);
      
      await loadPlayers(); // Reload list

      return participant;
    } catch (e) {
      // Handle error
      return null;
    }
  }

  /// Update a player (participant) - backward compatibility
  Future<void> updatePlayer(Participant participant) async {
    await updateParticipant(participant);
  }

  /// Update an existing participant
  Future<void> updateParticipant(Participant participant) async {
    try {
      final updated = participant.copyWith(updatedAt: DateTime.now());
      await _localStorage.saveParticipant(updated);
      
      // Save to Firestore (both guest and authenticated users)
      await _firestoreService.saveParticipant(updated, _userId);
      
      await loadPlayers();
    } catch (e) {
      // Handle error
    }
  }

  /// Delete a player (participant) - backward compatibility
  Future<void> deletePlayer(String participantId) async {
    await deleteParticipant(participantId);
  }

  /// Delete a participant
  Future<void> deleteParticipant(String participantId) async {
    try {
      await _localStorage.deleteParticipant(participantId);
      
      // Delete from Firestore (both guest and authenticated users)
      await _firestoreService.deleteParticipant(participantId);
      
      await loadPlayers();
    } catch (e) {
      // Handle error
    }
  }

  /// Search players (participants) by name - backward compatibility
  List<Participant> searchPlayers(String query) {
    return searchParticipants(query);
  }

  /// Search participants by name
  List<Participant> searchParticipants(String query) {
    return state.when(
      data: (participants) {
        if (query.isEmpty) return participants;
        final lowerQuery = query.toLowerCase();
        return participants
            .where((p) => p.name.toLowerCase().contains(lowerQuery))
            .toList();
      },
      loading: () => [],
      error: (_, __) => [],
    );
  }

  /// Get player (participant) by ID - backward compatibility
  Participant? getPlayerById(String id) {
    return getParticipantById(id);
  }

  /// Get participant by ID
  Participant? getParticipantById(String id) {
    return state.when(
      data: (participants) => participants.where((p) => p.id == id).firstOrNull,
      loading: () => null,
      error: (_, __) => null,
    );
  }
}

/// Provider for getting a specific participant by ID (keeping name as playerByIdProvider for backward compatibility)
final playerByIdProvider = Provider.family<Participant?, String>((ref, id) {
  final participantsAsync = ref.watch(playerProvider);
  return participantsAsync.when(
    data: (participants) => participants.where((p) => p.id == id).firstOrNull,
    loading: () => null,
    error: (_, __) => null,
  );
});
