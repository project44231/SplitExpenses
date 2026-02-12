import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:uuid/uuid.dart';
// Using Event/Expense models with backward compatibility
import '../../../models/compat.dart'; // This includes all models and compatibility typedefs
import '../../../services/local_storage_service.dart';
import '../../../services/firestore_service.dart';
import '../../../features/auth/providers/auth_provider.dart';
import '../../../core/constants/currency.dart';

/// Provider for Firestore service
final firestoreServiceProvider = Provider<FirestoreService>((ref) {
  return FirestoreService();
});

/// Provider for managing events (keeping name as gameProvider for backward compatibility)
final gameProvider = StateNotifierProvider<EventNotifier, AsyncValue<List<Event>>>((ref) {
  final localStorage = ref.watch(localStorageServiceProvider);
  final firestoreService = ref.watch(firestoreServiceProvider);
  final authService = ref.watch(authServiceProvider);
  return EventNotifier(localStorage, firestoreService, authService);
});

/// Provider for the current active event (keeping name as activeGameProvider for backward compatibility)
final activeGameProvider = StateProvider<Event?>((ref) => null);

/// Notifier for event state management
class EventNotifier extends StateNotifier<AsyncValue<List<Event>>> {
  final LocalStorageService _localStorage;
  final FirestoreService _firestoreService;
  final dynamic _authService;
  final _uuid = const Uuid();

  EventNotifier(this._localStorage, this._firestoreService, this._authService) 
      : super(const AsyncValue.loading()) {
    loadGames();
  }

  /// Get current user ID (returns 'guest' for guest mode, Firebase UID for logged in)
  String get _userId => _authService.currentUserId ?? 'guest';

  /// Load all events from storage (Firestore + local cache for both guest and authenticated)
  /// Keeping method name as loadGames for backward compatibility
  Future<void> loadGames() async {
    state = const AsyncValue.loading();
    try {
      // Load from Firestore and cache locally (both guest and authenticated)
      final events = await _firestoreService.getEvents(_userId);
      
      // Cache locally for offline access
      for (final event in events) {
        await _localStorage.saveEvent(event);
      }
      
      state = AsyncValue.data(events);
    } catch (e, stack) {
      // Fallback to local storage on error (offline mode)
      try {
        final events = await _localStorage.getAllEvents();
        state = AsyncValue.data(events);
      } catch (localError, _) {
        state = AsyncValue.error(e, stack);
      }
    }
  }

  /// Create a new game (event) - backward compatibility
  Future<Event?> createGame({
    required List<String> playerIds,
    String? groupId,
    String currency = 'USD',
    String? notes,
  }) async {
    return createEvent(
      participantIds: playerIds,
      groupId: groupId,
      currency: currency,
      notes: notes,
    );
  }

  /// Create a new event
  Future<Event?> createEvent({
    required List<String> participantIds,
    String? name,
    String? description,
    String? groupId,
    String currency = 'USD',
    String? notes,
  }) async {
    try {
      // Ensure we have a group (create default if needed)
      final actualGroupId = groupId ?? await _ensureDefaultGroup();

      final event = Event(
        id: _uuid.v4(),
        userId: _userId,
        name: name,
        description: description,
        groupId: actualGroupId,
        status: EventStatus.active,
        currency: currency,
        participantIds: participantIds,
        startTime: DateTime.now(),
        notes: notes,
        createdAt: DateTime.now(),
      );

      // Save to local storage
      await _localStorage.saveEvent(event);
      
      // Save to Firestore (both guest and authenticated users)
      await _firestoreService.saveEvent(event, _userId);
      
      await loadGames();

      return event;
    } catch (e) {
      // Handle error
      rethrow;
    }
  }

  /// Ensure default "Quick Events" group exists
  Future<String> _ensureDefaultGroup() async {
    final groups = await _localStorage.getAllEventGroups();
    
    // Check if default group exists
    final defaultGroup = groups.where((g) => g.name == 'Quick Events').firstOrNull;
    if (defaultGroup != null) {
      return defaultGroup.id;
    }

    // Create default group
    final newGroup = EventGroup(
      id: _uuid.v4(),
      name: 'Quick Events',
      ownerId: _userId,
      createdAt: DateTime.now(),
    );

    await _localStorage.saveEventGroup(newGroup);
    
    // Save to Firestore (both guest and authenticated users)
    await _firestoreService.saveEventGroup(newGroup, _userId);
    
    return newGroup.id;
  }

  /// Settle an event
  Future<void> settleEvent(String eventId) async {
    try {
      final event = await _localStorage.getEvent(eventId);
      if (event == null) return;

      final updatedEvent = event.copyWith(
        status: EventStatus.settled,
        endTime: DateTime.now(),
        updatedAt: DateTime.now(),
      );

      await _localStorage.saveEvent(updatedEvent);
      
      // Save to Firestore (both guest and authenticated users)
      await _firestoreService.saveEvent(updatedEvent, _userId);
      
      await loadGames();
    } catch (e) {
      // Handle error
    }
  }

  /// End a game (alias for settleEvent)
  Future<void> endGame(String eventId) async {
    await settleEvent(eventId);
  }

  /// Delete an event
  /// Keeping method name as deleteGame for backward compatibility
  Future<void> deleteGame(String eventId) async {
    try {
      await _localStorage.deleteEvent(eventId);
      
      // Delete from Firestore (both guest and authenticated users)
      await _firestoreService.deleteEvent(eventId);
      
      await loadGames();
    } catch (e) {
      // Handle error
    }
  }

  /// Get event by ID
  /// Keeping method name as getGame for backward compatibility
  Future<Event?> getGame(String eventId) async {
    try {
      // Try Firestore first (both guest and authenticated)
      final event = await _firestoreService.getEvent(eventId);
      if (event != null) {
        await _localStorage.saveEvent(event);
        return event;
      }
      return await _localStorage.getEvent(eventId);
    } catch (e) {
      // Fallback to local storage
      return await _localStorage.getEvent(eventId);
    }
  }

  /// Get expenses for an event
  Future<List<Expense>> getExpenses(String eventId) async {
    try {
      // Try Firestore first (both guest and authenticated)
      final expenses = await _firestoreService.getExpenses(eventId);
      for (final expense in expenses) {
        await _localStorage.saveExpense(expense);
      }
      return expenses;
    } catch (e) {
      // Fallback to local storage
      return await _localStorage.getExpensesByEvent(eventId);
    }
  }

  /// Get buy-ins (expenses) for backward compatibility
  Future<List<Expense>> getBuyIns(String gameId) async {
    return await getExpenses(gameId);
  }

  /// Get cash-outs for backward compatibility (returns empty list - not used in expense model)
  Future<List<dynamic>> getCashOuts(String gameId) async {
    return [];
  }

  /// Add cash-out for backward compatibility (no-op in expense model)
  Future<void> addCashOut({
    required String gameId,
    required String playerId,
    required double amount,
    String? notes,
  }) async {
    // No-op in expense model
  }

  /// Clear cash-outs for backward compatibility (no-op in expense model)
  Future<void> clearCashOuts(String gameId) async {
    // No-op in expense model
  }

  /// Add a buy-in (expense) for backward compatibility
  Future<void> addBuyIn({
    required String gameId,
    required String playerId,
    required double amount,
    String? notes,
    String? description,
    ExpenseCategory? category,
  }) async {
    // Convert to expense with equal split (only payer owes)
    await addExpense(
      eventId: gameId,
      paidByParticipantId: playerId,
      amount: amount,
      description: description ?? notes ?? 'Expense',
      category: category ?? ExpenseCategory.other,
      splitMethod: SplitMethod.equal,
      splitDetails: {playerId: 1.0},
      notes: notes,
    );
  }

  /// Add an expense
  Future<void> addExpense({
    required String eventId,
    required String paidByParticipantId,
    required double amount,
    required String description,
    required ExpenseCategory category,
    required SplitMethod splitMethod,
    required Map<String, double> splitDetails,
    String? receipt,
    String? notes,
  }) async {
    try {
      final expense = Expense(
        id: _uuid.v4(),
        eventId: eventId,
        paidByParticipantId: paidByParticipantId,
        amount: amount,
        description: description,
        timestamp: DateTime.now(),
        category: category,
        splitMethod: splitMethod,
        splitDetails: splitDetails,
        receipt: receipt,
        notes: notes,
      );

      await _localStorage.saveExpense(expense);
      
      // Save to Firestore (both guest and authenticated users)
      await _firestoreService.saveExpense(expense, _userId);
    } catch (e) {
      rethrow;
    }
  }

  /// Update a buy-in (expense) - backward compatibility
  Future<void> updateBuyIn(Expense expense) async {
    await updateExpense(expense);
  }

  /// Update an expense with individual parameters
  Future<void> updateExpenseWithParams({
    required String expenseId,
    required String paidByParticipantId,
    required double amount,
    required String description,
    required ExpenseCategory category,
    required SplitMethod splitMethod,
    required Map<String, double> splitDetails,
    String? notes,
    String? receipt,
  }) async {
    try {
      // Get the existing expense to preserve eventId and timestamp
      final existingExpense = await _localStorage.getExpense(expenseId);
      if (existingExpense == null) {
        throw Exception('Expense not found');
      }

      // Create updated expense
      final updatedExpense = existingExpense.copyWith(
        paidByParticipantId: paidByParticipantId,
        amount: amount,
        description: description,
        category: category,
        splitMethod: splitMethod,
        splitDetails: splitDetails,
        notes: notes,
        receipt: receipt,
      );

      await updateExpense(updatedExpense);
    } catch (e) {
      rethrow;
    }
  }

  /// Update an expense
  Future<void> updateExpense(Expense expense) async {
    try {
      // Save locally
      await _localStorage.saveExpense(expense);
      
      // Save to Firestore (both guest and authenticated users)
      await _firestoreService.saveExpense(expense, _userId);
    } catch (e) {
      rethrow;
    }
  }

  /// Delete a buy-in (expense) - backward compatibility
  Future<void> deleteBuyIn(String expenseId) async {
    await deleteExpense(expenseId);
  }

  /// Delete an expense
  Future<void> deleteExpense(String expenseId) async {
    try {
      await _localStorage.deleteExpense(expenseId);
      
      // Delete from Firestore (both guest and authenticated users)
      await _firestoreService.deleteExpense(expenseId);
    } catch (e) {
      rethrow;
    }
  }

  /// Get active games (events) - backward compatibility
  List<Event> getActiveGames() {
    return getActiveEvents();
  }

  /// Get active events
  List<Event> getActiveEvents() {
    return state.when(
      data: (events) => events.where((e) => e.status == EventStatus.active).toList(),
      loading: () => [],
      error: (_, __) => [],
    );
  }

  /// Get ended games (events) - backward compatibility
  List<Event> getEndedGames() {
    return getSettledEvents();
  }

  /// Get settled events
  List<Event> getSettledEvents() {
    return state.when(
      data: (events) => events.where((e) => e.status == EventStatus.settled).toList(),
      loading: () => [],
      error: (_, __) => [],
    );
  }

  /// Get or create current active game (event)
  Future<Event> getOrCreateCurrentGame() async {
    // Force reload to ensure we have the latest state
    await loadGames();
    
    // Check if there's an active event
    final activeEvents = getActiveEvents();
    if (activeEvents.isNotEmpty) {
      return activeEvents.first;
    }

    // No active event, create a new one with no participants
    try {
      final event = await createEvent(
        participantIds: [], // Start with no participants
        notes: 'Quick event',
      );

      if (event == null) {
        throw Exception('Failed to create new event - createEvent returned null');
      }

      return event;
    } catch (e) {
      // Handle error
      rethrow;
    }
  }

  /// Update a game (event) - backward compatibility
  Future<void> updateGame(Event event) async {
    await updateEvent(event);
  }

  /// Update an existing event
  Future<void> updateEvent(Event event) async {
    try {
      // Save to local storage
      await _localStorage.saveEvent(event);
      
      // Save to Firestore (both guest and authenticated users)
      await _firestoreService.saveEvent(event, _userId);
      
      await loadGames();
    } catch (e) {
      // Handle error
      rethrow;
    }
  }

  /// Get event - internal method
  Future<Event?> getEvent(String eventId) async {
    return await getGame(eventId);
  }

  /// Save settlement for an event
  Future<void> saveSettlement({
    required String eventId,
    required List<SettlementTransaction> transactions,
  }) async {
    try {
      final settlement = Settlement(
        id: _uuid.v4(),
        eventId: eventId,
        transactions: transactions,
        generatedAt: DateTime.now(),
      );

      // Save locally
      await _localStorage.saveSettlement(settlement);
      
      // Save to Firestore (both guest and authenticated users)
      await _firestoreService.saveSettlement(settlement, _userId);
    } catch (e) {
      rethrow;
    }
  }

  /// Get settlements for an event
  Future<List<Settlement>> getSettlements(String eventId) async {
    try {
      // Try Firestore first (both guest and authenticated)
      final settlements = await _firestoreService.getSettlements(eventId);
      
      // Cache locally
      for (final settlement in settlements) {
        await _localStorage.saveSettlement(settlement);
      }
      
      return settlements;
    } catch (e) {
      // Fallback to local storage
      return await _localStorage.getSettlementsByEvent(eventId);
    }
  }

  /// Update game notes - backward compatibility
  Future<Event?> updateGameNotes(String eventId, String notes) async {
    try {
      final event = await getGame(eventId);
      if (event == null) return null;

      final updatedEvent = event.copyWith(
        notes: notes,
        updatedAt: DateTime.now(),
      );

      // Save to local storage
      await _localStorage.saveEvent(updatedEvent);
      
      // Save to Firestore (both guest and authenticated users)
      await _firestoreService.saveEvent(updatedEvent, _userId);

      // Reload events to update state
      await loadGames();

      return updatedEvent;
    } catch (e) {
      rethrow;
    }
  }

  /// Update game name - backward compatibility  
  Future<Event?> updateGameName(String eventId, String name) async {
    try {
      final event = await getGame(eventId);
      if (event == null) return null;

      final updatedEvent = event.copyWith(
        name: name.trim().isEmpty ? null : name.trim(),
        updatedAt: DateTime.now(),
      );

      // Save to local storage
      await _localStorage.saveEvent(updatedEvent);
      
      // Save to Firestore (both guest and authenticated users)
      await _firestoreService.saveEvent(updatedEvent, _userId);

      // Reload events to update state
      await loadGames();

      return updatedEvent;
    } catch (e) {
      rethrow;
    }
  }

  /// Calculate participant results from expenses
  Future<List<ParticipantResult>> calculateParticipantResults(String eventId) async {
    final expenses = await getExpenses(eventId);
    final event = await getGame(eventId);
    if (event == null) return [];

    // Calculate totals for each participant
    final participantTotals = <String, Map<String, double>>{};
    
    for (final participantId in event.participantIds) {
      participantTotals[participantId] = {
        'paid': 0.0,
        'owed': 0.0,
      };
    }

    // Calculate what each participant paid and owes
    for (final expense in expenses) {
      // Add to payer's total paid
      participantTotals[expense.paidByParticipantId]?['paid'] =
          (participantTotals[expense.paidByParticipantId]?['paid'] ?? 0) + expense.amount;

      // Calculate owed amounts based on split method
      final splitAmounts = _calculateSplitAmounts(expense);
      splitAmounts.forEach((participantId, owedAmount) {
        participantTotals[participantId]?['owed'] =
            (participantTotals[participantId]?['owed'] ?? 0) + owedAmount;
      });
    }

    // Create results
    return participantTotals.entries.map((entry) {
      return ParticipantResult(
        participantId: entry.key,
        totalPaid: entry.value['paid'] ?? 0,
        totalOwed: entry.value['owed'] ?? 0,
        expenseCount: expenses.where((e) => e.paidByParticipantId == entry.key).length,
      );
    }).toList();
  }

  /// Calculate split amounts for an expense
  Map<String, double> _calculateSplitAmounts(Expense expense) {
    switch (expense.splitMethod) {
      case SplitMethod.equal:
        // Split equally among all participants in splitDetails
        final participantCount = expense.splitDetails.length;
        if (participantCount == 0) return {};
        final amountPerPerson = expense.amount / participantCount;
        return Map.fromEntries(
          expense.splitDetails.keys.map((id) => MapEntry(id, amountPerPerson)),
        );

      case SplitMethod.percentage:
        // Split by percentage
        return expense.splitDetails.map(
          (id, percentage) => MapEntry(id, expense.amount * (percentage / 100)),
        );

      case SplitMethod.exactAmount:
        // Exact amounts already specified
        return expense.splitDetails;

      case SplitMethod.shares:
        // Split by shares
        final totalShares = expense.splitDetails.values.fold(0.0, (sum, shares) => sum + shares);
        if (totalShares == 0) return {};
        final amountPerShare = expense.amount / totalShares;
        return expense.splitDetails.map(
          (id, shares) => MapEntry(id, amountPerShare * shares),
        );
    }
  }
}

/// Provider for event groups (keeping name as gameGroupProvider for backward compatibility)
final gameGroupProvider = FutureProvider<List<EventGroup>>((ref) async {
  final localStorage = ref.watch(localStorageServiceProvider);
  return await localStorage.getAllEventGroups();
});

/// Provider for default currency
final defaultCurrencyProvider = StateProvider<Currency>((ref) => AppCurrencies.usd);
