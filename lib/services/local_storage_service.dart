import 'package:hive_flutter/hive_flutter.dart';
import '../models/event.dart';
import '../models/participant.dart';
import '../models/expense.dart';
import '../models/settlement.dart';
import '../models/event_group.dart';

/// Local storage service using Hive for guest mode and caching
class LocalStorageService {
  static const String _eventsBoxName = 'events';
  static const String _participantsBoxName = 'participants';
  static const String _expensesBoxName = 'expenses';
  static const String _settlementsBoxName = 'settlements';
  static const String _groupsBoxName = 'event_groups';
  static const String _prefsBoxName = 'preferences';

  // Boxes
  late Box<Map> _eventsBox;
  late Box<Map> _participantsBox;
  late Box<Map> _expensesBox;
  late Box<Map> _settlementsBox;
  late Box<Map> _groupsBox;
  late Box<dynamic> _prefsBox;

  /// Initialize Hive and open all boxes
  Future<void> initialize() async {
    await Hive.initFlutter();

    // Open boxes
    _eventsBox = await Hive.openBox<Map>(_eventsBoxName);
    _participantsBox = await Hive.openBox<Map>(_participantsBoxName);
    _expensesBox = await Hive.openBox<Map>(_expensesBoxName);
    _settlementsBox = await Hive.openBox<Map>(_settlementsBoxName);
    _groupsBox = await Hive.openBox<Map>(_groupsBoxName);
    _prefsBox = await Hive.openBox(_prefsBoxName);
  }

  // ==================== Events ====================

  Future<void> saveEvent(Event event) async {
    await _eventsBox.put(event.id, event.toJson());
  }

  Future<Event?> getEvent(String id) async {
    final json = _eventsBox.get(id);
    if (json == null) return null;
    return Event.fromJson(Map<String, dynamic>.from(json));
  }

  Future<List<Event>> getAllEvents() async {
    final events = <Event>[];
    for (var json in _eventsBox.values) {
      events.add(Event.fromJson(Map<String, dynamic>.from(json)));
    }
    // Sort by start time, most recent first
    events.sort((a, b) => b.startTime.compareTo(a.startTime));
    return events;
  }

  Future<List<Event>> getEventsByGroup(String groupId) async {
    final allEvents = await getAllEvents();
    return allEvents.where((event) => event.groupId == groupId).toList();
  }

  Future<void> deleteEvent(String id) async {
    await _eventsBox.delete(id);
    // Also delete associated data
    await _deleteExpensesByEvent(id);
    await _deleteSettlementsByEvent(id);
  }

  // ==================== Participants ====================

  Future<void> saveParticipant(Participant participant) async {
    await _participantsBox.put(participant.id, participant.toJson());
  }

  Future<Participant?> getParticipant(String id) async {
    final json = _participantsBox.get(id);
    if (json == null) return null;
    return Participant.fromJson(Map<String, dynamic>.from(json));
  }

  Future<List<Participant>> getAllParticipants() async {
    final participants = <Participant>[];
    for (var json in _participantsBox.values) {
      participants.add(Participant.fromJson(Map<String, dynamic>.from(json)));
    }
    // Sort by name
    participants.sort((a, b) => a.name.compareTo(b.name));
    return participants;
  }

  Future<void> deleteParticipant(String id) async {
    await _participantsBox.delete(id);
  }

  // ==================== Expenses ====================

  Future<void> saveExpense(Expense expense) async {
    await _expensesBox.put(expense.id, expense.toJson());
  }

  Future<Expense?> getExpense(String expenseId) async {
    final json = _expensesBox.get(expenseId);
    if (json == null) return null;
    return Expense.fromJson(Map<String, dynamic>.from(json));
  }

  Future<List<Expense>> getExpensesByEvent(String eventId) async {
    final expenses = <Expense>[];
    for (var json in _expensesBox.values) {
      final expense = Expense.fromJson(Map<String, dynamic>.from(json));
      if (expense.eventId == eventId) {
        expenses.add(expense);
      }
    }
    // Sort by timestamp
    expenses.sort((a, b) => a.timestamp.compareTo(b.timestamp));
    return expenses;
  }

  Future<void> deleteExpense(String expenseId) async {
    await _expensesBox.delete(expenseId);
  }

  Future<void> _deleteExpensesByEvent(String eventId) async {
    final keysToDelete = <String>[];
    for (var entry in _expensesBox.toMap().entries) {
      final expense = Expense.fromJson(Map<String, dynamic>.from(entry.value));
      if (expense.eventId == eventId) {
        keysToDelete.add(entry.key);
      }
    }
    for (var key in keysToDelete) {
      await _expensesBox.delete(key);
    }
  }

  // ==================== Settlements ====================

  Future<void> saveSettlement(Settlement settlement) async {
    await _settlementsBox.put(settlement.id, settlement.toJson());
  }

  Future<Settlement?> getSettlementByEvent(String eventId) async {
    for (var json in _settlementsBox.values) {
      final settlement = Settlement.fromJson(Map<String, dynamic>.from(json));
      if (settlement.eventId == eventId) {
        return settlement;
      }
    }
    return null;
  }

  Future<List<Settlement>> getSettlementsByEvent(String eventId) async {
    final settlements = <Settlement>[];
    for (var json in _settlementsBox.values) {
      final settlement = Settlement.fromJson(Map<String, dynamic>.from(json));
      if (settlement.eventId == eventId) {
        settlements.add(settlement);
      }
    }
    // Sort by generated time, most recent first
    settlements.sort((a, b) => b.generatedAt.compareTo(a.generatedAt));
    return settlements;
  }

  Future<void> _deleteSettlementsByEvent(String eventId) async {
    final keysToDelete = <String>[];
    for (var entry in _settlementsBox.toMap().entries) {
      final settlement =
          Settlement.fromJson(Map<String, dynamic>.from(entry.value));
      if (settlement.eventId == eventId) {
        keysToDelete.add(entry.key);
      }
    }
    for (var key in keysToDelete) {
      await _settlementsBox.delete(key);
    }
  }

  // ==================== Event Groups ====================

  Future<void> saveEventGroup(EventGroup group) async {
    await _groupsBox.put(group.id, group.toJson());
  }

  Future<EventGroup?> getEventGroup(String id) async {
    final json = _groupsBox.get(id);
    if (json == null) return null;
    return EventGroup.fromJson(Map<String, dynamic>.from(json));
  }

  Future<List<EventGroup>> getAllEventGroups() async {
    final groups = <EventGroup>[];
    for (var json in _groupsBox.values) {
      groups.add(EventGroup.fromJson(Map<String, dynamic>.from(json)));
    }
    // Sort by name
    groups.sort((a, b) => a.name.compareTo(b.name));
    return groups;
  }

  Future<void> deleteEventGroup(String id) async {
    await _groupsBox.delete(id);
  }

  // ==================== Preferences ====================

  Future<void> setString(String key, String value) async {
    await _prefsBox.put(key, value);
  }

  String? getString(String key) {
    return _prefsBox.get(key);
  }

  Future<void> setBool(String key, bool value) async {
    await _prefsBox.put(key, value);
  }

  bool? getBool(String key) {
    return _prefsBox.get(key);
  }

  Future<void> remove(String key) async {
    await _prefsBox.delete(key);
  }

  // ==================== Utility ====================

  /// Clear all local data (for testing or logout)
  Future<void> clearAll() async {
    await _eventsBox.clear();
    await _participantsBox.clear();
    await _expensesBox.clear();
    await _settlementsBox.clear();
    await _groupsBox.clear();
    await _prefsBox.clear();
  }

  /// Get storage statistics
  Map<String, int> getStats() {
    return {
      'events': _eventsBox.length,
      'participants': _participantsBox.length,
      'expenses': _expensesBox.length,
      'settlements': _settlementsBox.length,
      'groups': _groupsBox.length,
    };
  }
}
